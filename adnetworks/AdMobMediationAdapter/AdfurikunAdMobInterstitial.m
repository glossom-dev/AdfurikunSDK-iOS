//
//  AdfurikunAdMobInterstitial.m
//
//  Copyright © 2019 Glossom.Inc. All rights reserved.
//

#import "AdfurikunAdMobInterstitial.h"
#include <stdatomic.h>
#import <ADFMovieReward/AdfurikunSdk.h>

@interface AdfurikunAdMobInterstitial ()
@property(nonatomic, weak, nullable) id<GADMediationInterstitialAdEventDelegate> adEventDelegate;
@property(nonatomic) GADMediationInterstitialLoadCompletionHandler loadCompletionHandler;
@end

@implementation AdfurikunAdMobInterstitial

- (void)loadInterstitialForAdConfiguration:(GADMediationInterstitialAdConfiguration *)adConfiguration completionHandler:(GADMediationInterstitialLoadCompletionHandler)completionHandler {
    __block atomic_flag completionHandlerCalled = ATOMIC_FLAG_INIT;
    __block GADMediationInterstitialLoadCompletionHandler originalCompletionHandler = [completionHandler copy];
    
    self.loadCompletionHandler = ^id<GADMediationInterstitialAdEventDelegate>(_Nullable id<GADMediationInterstitialAd> ad, NSError *_Nullable error) {
        // Only allow completion handler to be called once.
        if (atomic_flag_test_and_set(&completionHandlerCalled)) {
            return nil;
        }
        
        id<GADMediationInterstitialAdEventDelegate> delegate = nil;
        if (originalCompletionHandler) {
            // Call original handler and hold on to its return value.
            delegate = originalCompletionHandler(ad, error);
        }
        
        // Release reference to handler. Objects retained by the handler will also
        // be released.
        originalCompletionHandler = nil;
        
        return delegate;
    };
    NSString *appId = adConfiguration.credentials.settings[@"parameter"];
    if (appId) {
        self.interstitialAd = [ADFmyInterstitial getInstance:appId delegate:self];
        [self.interstitialAd load];
    }
}

+ (GADVersionNumber)adSDKVersion { 
    NSString *versionString = AdfurikunSdk.version;
    NSMutableArray *versionComponents = [[versionString componentsSeparatedByString:@"."] mutableCopy];
    GADVersionNumber version = {0};
    if (versionComponents.count == 3) {
        [versionComponents addObject:@"0"];
    }
    if (versionComponents.count == 4) {
        version.majorVersion = [versionComponents[0] integerValue];
        version.minorVersion = [versionComponents[1] integerValue];
        
        // Adapter versions have 2 patch versions. Multiply the first patch by 100.
        version.patchVersion = [versionComponents[2] integerValue] * 100
        + [versionComponents[3] integerValue];
    }
    return version;
}


+ (GADVersionNumber)adapterVersion { 
    NSString *versionString = @"1.0.3";
    NSArray *versionComponents = [versionString componentsSeparatedByString:@"."];
    GADVersionNumber version = {0};
    if (versionComponents.count == 3) {
        version.majorVersion = [versionComponents[0] integerValue];
        version.minorVersion = [versionComponents[1] integerValue];
        version.patchVersion = [versionComponents[2] integerValue];
    }
    return version;
}


+ (nullable Class<GADAdNetworkExtras>)networkExtrasClass { 
    return nil;
}


- (void)presentFromViewController:(UIViewController *)viewController {
    if ([self.interstitialAd isPrepared]) {
        [self.interstitialAd play];
    } else if (self.adEventDelegate && [self.adEventDelegate respondsToSelector:@selector(didFailToPresentWithError:)]) {
        NSString *message = @"ad was not loaded.";
        NSError *error = [NSError errorWithDomain:@"jp.glossom.adfurikun.error"
                                             code:0
                                         userInfo:@{NSLocalizedDescriptionKey: message,
                                                    NSLocalizedRecoverySuggestionErrorKey: message}];
        [self.adEventDelegate didFailToPresentWithError:error];
    }
}

- (void)AdsFetchCompleted:(NSString *)appID isTestMode:(BOOL)isTestMode_inApp {
    NSLog(@"%s", __FUNCTION__);
    if (self.loadCompletionHandler) {
        self.adEventDelegate = self.loadCompletionHandler(self, nil);
    }
}

- (void)AdsFetchFailed:(NSString *)appID error:(NSError *)error adnetworkError:(NSArray<AdnetworkError *> *)adnetworkError {
    NSLog(@"%s", __FUNCTION__);
    if (self.loadCompletionHandler) {
        self.adEventDelegate = self.loadCompletionHandler(nil, error);
    }
}

- (void)AdsPlayFailed:(NSString *)appID adnetworkError:(AdnetworkError *)adnetworkError {
    if (self.adEventDelegate && [self.adEventDelegate respondsToSelector:@selector(didFailToPresentWithError:)]) {
        NSString *errorMessage = @"";
        NSInteger errorCode = 0;
        if (adnetworkError) {
            if (adnetworkError.errorMessage) {
                errorMessage = adnetworkError.errorMessage;
            }
            errorCode = adnetworkError.errorCode;
        }
        NSError *error = [NSError errorWithDomain:@"jp.glossom.adfurikun.error"
                                             code:errorCode
                                         userInfo:@{NSLocalizedDescriptionKey: errorMessage,
                                                    NSLocalizedRecoverySuggestionErrorKey: errorMessage}];
        [self.adEventDelegate didFailToPresentWithError:error];
    }
}

- (void)AdsDidShow:(NSString *)appID adnetworkKey:(NSString *)adnetworkKey {
    NSLog(@"%s", __FUNCTION__);
    if (self.adEventDelegate && [self.adEventDelegate respondsToSelector:@selector(willPresentFullScreenView)]) {
        [self.adEventDelegate willPresentFullScreenView];
    }
    if (self.adEventDelegate && [self.adEventDelegate respondsToSelector:@selector(reportImpression)]) {
        [self.adEventDelegate reportImpression];
    }
}

- (void)AdsDidCompleteShow:(NSString *)appID {
    NSLog(@"%s", __FUNCTION__);
}

- (void)AdsDidHide:(NSString *)appID isRewarded:(_Bool)rewarded {
    NSLog(@"%s", __FUNCTION__);
    if (self.adEventDelegate && [self.adEventDelegate respondsToSelector:@selector(willDismissFullScreenView)]) {
        [self.adEventDelegate willDismissFullScreenView];
    }
    if (self.adEventDelegate && [self.adEventDelegate respondsToSelector:@selector(didDismissFullScreenView)]) {
        [self.adEventDelegate didDismissFullScreenView];
    }
}

@end
