//
//  ADFAdMobNativeAd.m
//
//  Copyright © 2019 Glossom.Inc. All rights reserved.
//

#import "AdfurikunAdMobNativeAd.h"

@interface ADFAdMobNativeAdCustomInfo ()
@property(nonatomic) ADFNativeAdInfo *adInfo;
@end

@implementation ADFAdMobNativeAdCustomInfo

- (id)initWithADFNativeAdInfo:(ADFNativeAdInfo *)adInfo {
    if (self = [super init]) {
        self.adInfo = adInfo;
        self.adInfo.mediaView.mediaViewDelegate = self;
    }
    return self;
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

- (void)didRenderInView:(UIView *)view clickableAssetViews:(NSDictionary<GADUnifiedNativeAssetIdentifier,UIView *> *)clickableAssetViews nonclickableAssetViews:(NSDictionary<GADUnifiedNativeAssetIdentifier,UIView *> *)nonclickableAssetViews viewController:(UIViewController *)viewController {
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
    [GADMediatedUnifiedNativeAdNotificationSource mediatedNativeAdWillPresentScreen:self];
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

@implementation AdfurikunAdMobNativeAd
@synthesize delegate;

- (void)requestNativeAdWithParameter:(NSString *)serverParameter
                             request:(GADCustomEventRequest *)request
                             adTypes:(NSArray *)adTypes
                             options:(NSArray *)options
                  rootViewController:(UIViewController *)rootViewController {
    [ADFmyNativeAd initializeWithAppID:serverParameter];
    self.nativeAd = [ADFmyNativeAd getInstance:serverParameter];
    [self.nativeAd loadAndNotifyTo:self];
}

- (BOOL)handlesUserClicks {
    return NO;
}

- (BOOL)handlesUserImpressions {
    return NO;
}

- (void)onNativeAdLoadFinish:(nonnull ADFNativeAdInfo *)info appID:(nonnull NSString *)appID {
    ADFAdMobNativeAdCustomInfo *mediationAdInfo = [[ADFAdMobNativeAdCustomInfo alloc] initWithADFNativeAdInfo:info];
    [self.delegate customEventNativeAd:self didReceiveMediatedUnifiedNativeAd:mediationAdInfo];
}

- (void)onNativeAdLoadError:(ADFMovieError *)error appID:(NSString *)appID {
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey: error.errorMessage
    };
    NSError *err = [[NSError alloc] initWithDomain:@"jp.glossom.adfurikun.error" code:error.errorCode userInfo:userInfo];
    [self.delegate customEventNativeAd:self didFailToLoadWithError:err];
}

@end
