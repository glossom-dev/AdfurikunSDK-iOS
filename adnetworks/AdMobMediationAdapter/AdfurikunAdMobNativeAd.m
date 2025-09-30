//
//  ADFAdMobNativeAd.m
//
//  Copyright © 2019 Glossom.Inc. All rights reserved.
//

#import "AdfurikunAdMobNativeAd.h"
#import "AdfurikunAdnetworkExtra.h"
#include <stdatomic.h>
#import <ADFMovieReward/AdfurikunSdk.h>

@interface AdfurikunAdMobNativeAd ()

@property(nonatomic, weak, nullable) id<GADMediationNativeAdEventDelegate> adEventDelegate;
@property(nonatomic) GADMediationNativeLoadCompletionHandler loadCompletionHandler;
@property(nonatomic) ADFNativeAdInfo *adInfo;

@end

@implementation AdfurikunAdMobNativeAd

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
    NSString *versionString = @"2.0.0";
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

- (void)loadNativeAdForAdConfiguration:(nonnull GADMediationNativeAdConfiguration *)adConfiguration
                     completionHandler:(nonnull GADMediationNativeLoadCompletionHandler)completionHandler {
    __block atomic_flag completionHandlerCalled = ATOMIC_FLAG_INIT;
    __block GADMediationNativeLoadCompletionHandler originalCompletionHandler = [completionHandler copy];
    
    self.loadCompletionHandler = ^id<GADMediationNativeAdEventDelegate>(_Nullable id<GADMediationNativeAd> ad, NSError *_Nullable error) {
        // Only allow completion handler to be called once.
        if (atomic_flag_test_and_set(&completionHandlerCalled)) {
            return nil;
        }
        
        id<GADMediationNativeAdEventDelegate> delegate = nil;
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
        self.nativeAd = [ADFmyNativeAd getInstance:appId];
        if (loadTimeout > 0.0) {
            [self.nativeAd setLoadingTimeout:loadTimeout];
        }
        [self.nativeAd loadAndNotifyTo:self customParam:customParameter];
    }
}

- (BOOL)handlesUserClicks {
    return true;
}

- (BOOL)handlesUserImpressions {
    return true;
}

- (void)onNativeAdLoadFinish:(nonnull ADFNativeAdInfo *)info appID:(nonnull NSString *)appID {
    if (self.loadCompletionHandler) {
        self.adInfo = info;
        self.adInfo.mediaView.mediaViewDelegate = self;
        self.adEventDelegate = self.loadCompletionHandler(self, nil);
        [self.adInfo playMediaView];
    }
}

- (void)onNativeAdLoadError:(ADFMovieError *)error appID:(NSString *)appID adnetworkError:(NSArray<AdnetworkError *> *)adnetworkError {
    if (self.loadCompletionHandler) {
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: error.errorMessage
        };
        NSError *err = [[NSError alloc] initWithDomain:@"jp.glossom.adfurikun.error" code:error.errorCode userInfo:userInfo];
        self.adEventDelegate = self.loadCompletionHandler(nil, err);
    }
}

- (BOOL)hasVideoContent {
    return true;
}

- (NSString *)headline {
    return self.adInfo.title;
}

- (NSString *)body {
    return self.adInfo.desc;
}

- (UIView *)mediaView {
  return self.adInfo.mediaView;
}

- (NSArray *)images {
    return nil;
}

- (GADNativeAdImage *)icon {
    return nil;
}

- (NSString *)callToAction {
    return nil;
}

- (NSDecimalNumber *)starRating {
    return nil;
}

- (NSString *)store {
    return nil;
}

- (NSString *)price {
    return nil;
}

- (NSString *)advertiser {
    return nil;
}

- (NSDictionary *)extraAssets {
    return nil;
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
