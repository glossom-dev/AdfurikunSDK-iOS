//
//  AdfurikunAdMobAppOpenAd.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2025/09/25.
//  Copyright © 2025 GREE X, Inc. All rights reserved.
//

#include <stdatomic.h>
#import "AdfurikunAdMobAppOpenAd.h"
#import "AdfurikunAdnetworkExtra.h"
#import <ADFMovieReward/AdfurikunSdk.h>

@interface AdfurikunAdMobAppOpenAd ()
@property(nonatomic, weak, nullable) id<GADMediationAppOpenAdEventDelegate> adEventDelegate;
@property(nonatomic) GADMediationAppOpenLoadCompletionHandler loadCompletionHandler;

@property (nonatomic) NSDictionary *customParameter;
@end

@implementation AdfurikunAdMobAppOpenAd

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
    NSString *versionString = @"2.0.1";
    NSArray *versionComponents = [versionString componentsSeparatedByString:@"."];
    GADVersionNumber version = {0};
    if (versionComponents.count == 3) {
        version.majorVersion = [versionComponents[0] integerValue];
        version.minorVersion = [versionComponents[1] integerValue];
        version.patchVersion = [versionComponents[2] integerValue];
    }
    return version;
}

- (void)loadAppOpenAdForAdConfiguration:(GADMediationAppOpenAdConfiguration *)adConfiguration completionHandler:(GADMediationAppOpenLoadCompletionHandler)completionHandler {
    __block atomic_flag completionHandlerCalled = ATOMIC_FLAG_INIT;
    __block GADMediationAppOpenLoadCompletionHandler originalCompletionHandler = [completionHandler copy];
    self.loadCompletionHandler = ^id<GADMediationAppOpenAdEventDelegate>(_Nullable id<GADMediationAppOpenAd> ad, NSError *_Nullable error) {
        // Only allow completion handler to be called once.
        if (atomic_flag_test_and_set(&completionHandlerCalled)) {
            return nil;
        }
        id<GADMediationAppOpenAdEventDelegate> delegate = nil;
        if (originalCompletionHandler) {
            // Call original handler and hold on to its return value.
            delegate = originalCompletionHandler(ad, error);
        }
        // Release reference to handler. Objects retained by the handler will also be released.
        originalCompletionHandler = nil;
        return delegate;
    };
    NSString *appId = adConfiguration.credentials.settings[@"parameter"];
    float loadTimeout = 0.0;
    self.customParameter = nil;
    
    AdfurikunAdnetworkExtra *extra = (AdfurikunAdnetworkExtra *)adConfiguration.extras;
    if (extra) {
        loadTimeout = extra.loadTimeout;

        [extra adfurikunSDKInitProcessWithTestMode:adConfiguration.isTestRequest];
        
        if (extra.customParameter) {
            self.customParameter = [NSDictionary dictionaryWithDictionary:extra.customParameter];
        }
    }
    if (appId) {
        [ADFmyAppOpenAd initializeWithAppID:appId];
        self.appOpenAd = [ADFmyAppOpenAd getInstance:appId delegate:self];
        if (loadTimeout > 0.0) {
            [self.appOpenAd loadWithTimeout:loadTimeout];
        } else {
            [self.appOpenAd loadWithTimeout:3.0];
        }
    }
}

+ (Class<GADAdNetworkExtras>)networkExtrasClass {
    return AdfurikunAdnetworkExtra.class;
}

- (void)presentFromViewController:(nonnull UIViewController *)viewController {
    if ([self.appOpenAd isPrepared]) {
        [self.appOpenAd playWithPresentingViewController:viewController window:nil];
    } else if (self.adEventDelegate && [self.adEventDelegate respondsToSelector:@selector(didFailToPresentWithError:)]) {
        NSString *message = @"ad was not loaded.";
        NSError *error = [NSError errorWithDomain:@"jp.glossom.adfurikun.error"
                                             code:0
                                         userInfo:@{NSLocalizedDescriptionKey: message,
                                                    NSLocalizedRecoverySuggestionErrorKey: message}];
        [self.adEventDelegate didFailToPresentWithError:error];
    }
}

- (void)AdsFetchCompleted:(NSString *)appID {
    if (self.loadCompletionHandler) {
        self.adEventDelegate = self.loadCompletionHandler(self, nil);
    }
}

- (void)AdsFetchFailed:(NSString *)appID error:(NSError *)error adnetworkError:(NSArray<AdnetworkError *> *)adnetworkError {
    if (self.loadCompletionHandler) {
        self.adEventDelegate = self.loadCompletionHandler(nil, error);
    }
}

- (void)AdsPlayFailed:(NSString *)appID adfError:(ADFError *)adfError adnetworkError:(AdnetworkError *)adnetworkError {
    if (self.adEventDelegate && [self.adEventDelegate respondsToSelector:@selector(didFailToPresentWithError:)]) {
        NSString *errorMessage = @"";
        NSInteger errorCode = 0;
        if (adnetworkError) {
            if (adnetworkError.errorMessage) {
                errorMessage = adnetworkError.errorMessage;
            }
            errorCode = adnetworkError.errorCode;
        } else if (adfError) {
            if (adfError.errorMessage) {
                errorMessage = adfError.errorMessage;
            }
            errorCode = adfError.errorCode;
        }
        NSError *error = [NSError errorWithDomain:@"jp.glossom.adfurikun.error"
                                             code:errorCode
                                         userInfo:@{NSLocalizedDescriptionKey: errorMessage,
                                                    NSLocalizedRecoverySuggestionErrorKey: errorMessage}];
        [self.adEventDelegate didFailToPresentWithError:error];
    }
}

- (void)AdsDidShow:(NSString *)appID adnetworkKey:(NSString *)adnetworkKey {
    if (self.adEventDelegate && [self.adEventDelegate respondsToSelector:@selector(willPresentFullScreenView)]) {
        [self.adEventDelegate willPresentFullScreenView];
    }
    if (self.adEventDelegate && [self.adEventDelegate respondsToSelector:@selector(reportImpression)]) {
        [self.adEventDelegate reportImpression];
    }
}

- (void)AdsDidHide:(NSString *)appID {
    if (self.adEventDelegate && [self.adEventDelegate respondsToSelector:@selector(willDismissFullScreenView)]) {
        [self.adEventDelegate willDismissFullScreenView];
    }
    if (self.adEventDelegate && [self.adEventDelegate respondsToSelector:@selector(didDismissFullScreenView)]) {
        [self.adEventDelegate didDismissFullScreenView];
    }
}

@end
