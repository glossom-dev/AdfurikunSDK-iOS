//
//  AdfurikunAdMobBanner.m
//
//  Copyright © 2019 Glossom.Inc. All rights reserved.
//

#import "AdfurikunAdMobBanner.h"
#import "AdfurikunAdnetworkExtra.h"
#include <stdatomic.h>
#import <ADFMovieReward/AdfurikunSdk.h>

@interface AdfurikunAdMobBanner ()
@property(nonatomic, weak, nullable) id<GADMediationBannerAdEventDelegate> adEventDelegate;
@property(nonatomic) GADMediationBannerLoadCompletionHandler loadCompletionHandler;
@property(nonatomic) ADFNativeAdInfo *adInfo;
@end

@implementation AdfurikunAdMobBanner

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

+ (Class<GADAdNetworkExtras>)networkExtrasClass {
    return AdfurikunAdnetworkExtra.class;
}

- (void)loadBannerForAdConfiguration:(GADMediationBannerAdConfiguration *)adConfiguration
                   completionHandler:(GADMediationBannerLoadCompletionHandler)completionHandler {
    __block atomic_flag completionHandlerCalled = ATOMIC_FLAG_INIT;
    __block GADMediationBannerLoadCompletionHandler originalCompletionHandler = [completionHandler copy];
    
    self.loadCompletionHandler = ^id<GADMediationBannerAdEventDelegate>(_Nullable id<GADMediationBannerAd> ad, NSError *_Nullable error) {
        // Only allow completion handler to be called once.
        if (atomic_flag_test_and_set(&completionHandlerCalled)) {
            return nil;
        }
        
        id<GADMediationBannerAdEventDelegate> delegate = nil;
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
    float loadTimeout = 0.0;
    NSDictionary *customParameter = nil;
    
    AdfurikunAdnetworkExtra *extra = (AdfurikunAdnetworkExtra *)adConfiguration.extras;
    if (extra) {
        loadTimeout = extra.loadTimeout;

        [extra adfurikunSDKInitProcessWithTestMode:adConfiguration.isTestRequest];
        
        if (extra.customParameter) {
            customParameter = [NSDictionary dictionaryWithDictionary:extra.customParameter];
        }
    }

    if (appId) {
        self.bannerAd = [self createADFBanner:appId];
        if (loadTimeout > 0.0) {
            [self.bannerAd setLoadingTimeout:loadTimeout];
        }
        [self.bannerAd loadAndNotifyTo:self customParam:customParameter];
    }
}

- (ADFmyBanner *)createADFBanner:(NSString *)appId {
    self.bannerSize = CGRectMake(0, 0, 320, 50);
    return [ADFmyBanner getInstance:appId];
}

- (BOOL)handlesUserClicks {
    return true;
}

- (BOOL)handlesUserImpressions {
    return true;
}

- (void)onNativeAdLoadFinish:(nonnull ADFNativeAdInfo *)info appID:(nonnull NSString *)appID {
    if (self.loadCompletionHandler && info.mediaView) {
        self.adInfo = info;
        self.adInfo.mediaView.frame = self.bannerSize;
        self.adInfo.mediaView.mediaViewDelegate = self;
        [self.adInfo playMediaView];
        self.adEventDelegate = self.loadCompletionHandler(self, nil);
        [self.adInfo playMediaView];
    }
}

- (void)onNativeAdLoadError:(NSString *)appID adfError:(ADFError *)adfError adnetworkError:(NSArray<AdnetworkError *> *)adnetworkError {
    if (self.loadCompletionHandler) {
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: adfError.errorMessage
        };
        NSError *err = [[NSError alloc] initWithDomain:@"jp.glossom.adfurikun.error" code:adfError.errorCode userInfo:userInfo];
        self.adEventDelegate = self.loadCompletionHandler(nil, err);
    }
}

- (UIView *)view {
    return self.adInfo.mediaView;
}

# pragma ADFMediaViewDelegate

- (void)onADFMediaViewPlayStart {
    if (self.adEventDelegate && [self.adEventDelegate respondsToSelector:@selector(reportImpression)]) {
        [self.adEventDelegate reportImpression];
    }
}

- (void)onADFMediaViewPlayFail {
    if (self.adEventDelegate && [self.adEventDelegate respondsToSelector:@selector(didFailToPresentWithError:)]) {
        NSError *error = [NSError errorWithDomain:@"jp.glossom.adfurikun.error"
                                             code:0
                                         userInfo:@{NSLocalizedDescriptionKey: @"",
                                                    NSLocalizedRecoverySuggestionErrorKey: @""}];
        [self.adEventDelegate didFailToPresentWithError:error];
    }
}

- (void)onADFMediaViewClick {
    if (self.adEventDelegate && [self.adEventDelegate respondsToSelector:@selector(reportClick)]) {
        [self.adEventDelegate reportClick];
    }
}

- (void)onADFMediaViewLoadFail {
}

- (void)onADFMediaViewRendering {
}

- (void)onADFMediaViewPlayFinish {
}

@end
