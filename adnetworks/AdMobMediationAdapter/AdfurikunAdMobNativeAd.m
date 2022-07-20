//
//  ADFAdMobNativeAd.m
//
//  Copyright © 2019 Glossom.Inc. All rights reserved.
//

#import "AdfurikunAdMobNativeAd.h"
#import <ADFMovieReward/ADFMovieOptions.h>

@interface AdfurikunAdMobNativeAd ()

@property(nonatomic, weak, nullable) id<GADMediationAdEventDelegate> delegate;
@property(nonatomic) GADMediationNativeLoadCompletionHandler closure;

@property(nonatomic) ADFNativeAdInfo *adInfo;

@end

@implementation AdfurikunAdMobNativeAd

+ (GADVersionNumber)adSDKVersion {
    NSString *versionString = ADFMovieOptions.version;
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
    NSString *versionString = @"1.0.0";
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
    return nil;
}

- (void)loadNativeAdForAdConfiguration:(nonnull GADMediationNativeAdConfiguration *)adConfiguration
                     completionHandler:(nonnull GADMediationNativeLoadCompletionHandler)completionHandler {
    self.closure = completionHandler;
    NSString *adUnit = adConfiguration.credentials.settings[@"parameter"];
    if (adUnit) {
        [ADFmyNativeAd initializeWithAppID:adUnit];
        self.nativeAd = [ADFmyNativeAd getInstance:adUnit];
        [self.nativeAd loadAndNotifyTo:self];
    }
}

- (BOOL)handlesUserClicks {
    return true;
}

- (BOOL)handlesUserImpressions {
    return true;
}

- (void)onNativeAdLoadFinish:(nonnull ADFNativeAdInfo *)info appID:(nonnull NSString *)appID {
    if (self.closure) {
        self.adInfo = info;
        self.adInfo.mediaView.mediaViewDelegate = self;
        self.delegate = self.closure(self, nil);
    }
}

- (void)onNativeAdLoadError:(ADFMovieError *)error appID:(NSString *)appID {
    if (self.closure) {
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: error.errorMessage
        };
        NSError *err = [[NSError alloc] initWithDomain:@"jp.glossom.adfurikun.error" code:error.errorCode userInfo:userInfo];
        self.closure(nil, err);
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

- (void)presentFromViewController:(nonnull UIViewController *)viewController {
    [self.adInfo playMediaView];
}

# pragma ADFMediaViewDelegate

- (void)onADFMediaViewPlayStart {
    NSLog(@"%s", __FUNCTION__);
}

- (void)onADFMediaViewPlayFail {
    NSLog(@"%s", __FUNCTION__);
}

- (void)onADFMediaViewClick {
    NSLog(@"%s", __FUNCTION__);
    if (self.delegate && [self.delegate respondsToSelector:@selector(reportClick)]) {
        [self.delegate reportClick];
    }
}

- (void)onADFMediaViewLoadFail {
    NSLog(@"%s", __FUNCTION__);
}

- (void)onADFMediaViewRendering {
    NSLog(@"%s", __FUNCTION__);
}

- (void)onADFMediaViewPlayFinish {
    NSLog(@"%s", __FUNCTION__);
}
@end
