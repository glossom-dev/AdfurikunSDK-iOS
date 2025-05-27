//
//  AdfurikunAdMobReward.m
//
//  Copyright © 2019 Glossom.Inc. All rights reserved.
//

#import "AdfurikunAdMobReward.h"
#include <stdatomic.h>
#import <ADFMovieReward/AdfurikunSdk.h>

@interface AdfurikunAdMobReward ()
@property(nonatomic, weak, nullable) id<GADMediationRewardedAdEventDelegate> adEventDelegate;
@property(nonatomic) GADMediationRewardedLoadCompletionHandler loadCompletionHandler;
@end

@implementation AdfurikunAdMobReward

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
    NSString *versionString = @"1.0.2";
    NSArray *versionComponents = [versionString componentsSeparatedByString:@"."];
    GADVersionNumber version = {0};
    if (versionComponents.count == 3) {
        version.majorVersion = [versionComponents[0] integerValue];
        version.minorVersion = [versionComponents[1] integerValue];
        version.patchVersion = [versionComponents[2] integerValue];
    }
    return version;
}

- (void)loadRewardedAdForAdConfiguration:(GADMediationRewardedAdConfiguration *)adConfiguration completionHandler:(GADMediationRewardedLoadCompletionHandler)completionHandler {
    
    __block atomic_flag completionHandlerCalled = ATOMIC_FLAG_INIT;
    __block GADMediationRewardedLoadCompletionHandler originalCompletionHandler = [completionHandler copy];
    self.loadCompletionHandler = ^id<GADMediationRewardedAdEventDelegate>(_Nullable id<GADMediationRewardedAd> ad, NSError *_Nullable error) {
        // Only allow completion handler to be called once.
        if (atomic_flag_test_and_set(&completionHandlerCalled)) {
            return nil;
        }
        id<GADMediationRewardedAdEventDelegate> delegate = nil;
        if (originalCompletionHandler) {
            // Call original handler and hold on to its return value.
            delegate = originalCompletionHandler(ad, error);
        }
        // Release reference to handler. Objects retained by the handler will also be released.
        originalCompletionHandler = nil;
        return delegate;
    };
    
    NSString *appId = adConfiguration.credentials.settings[@"parameter"];
    if (appId) {
        self.movieReward = [ADFmyMovieReward getInstance:appId delegate:self];
        [self.movieReward load];
    }
}

+ (Class<GADAdNetworkExtras>)networkExtrasClass {
    return nil;
}

- (void)presentFromViewController:(nonnull UIViewController *)viewController {
    if ([self.movieReward isPrepared]) {
        [self.movieReward play];
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
    if (self.loadCompletionHandler) {
        self.adEventDelegate = self.loadCompletionHandler(self, nil);
    }
}

- (void)AdsFetchFailed:(NSString *)appID error:(NSError *)error adnetworkError:(NSArray<AdnetworkError *> *)adnetworkError {
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
    if (self.adEventDelegate && [self.adEventDelegate respondsToSelector:@selector(didStartVideo)]) {
        [self.adEventDelegate didStartVideo];
    }
}

- (void)AdsDidCompleteShow:(NSString *)appID {
    NSLog(@"%s", __FUNCTION__);
    if (self.adEventDelegate && [self.adEventDelegate respondsToSelector:@selector(didEndVideo)]) {
        [self.adEventDelegate didEndVideo];
    }
}

- (void)AdsDidHide:(NSString *)appID {
    NSLog(@"%s", __FUNCTION__);
    if (self.adEventDelegate && [self.adEventDelegate respondsToSelector:@selector(willDismissFullScreenView)]) {
        [self.adEventDelegate willDismissFullScreenView];
    }
    if (self.adEventDelegate && [self.adEventDelegate respondsToSelector:@selector(didDismissFullScreenView)]) {
        [self.adEventDelegate didDismissFullScreenView];
    }
}

@end
