//
//  AdfurikunMoPubBanner.m
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "AdfurikunMoPubBanner.h"

@interface AdfurikunMoPubBanner ()
@property (nonatomic, copy)NSString *appId;
@property (nonatomic)ADFmyBanner *banner;
@property (nonatomic)CGRect adViewRect;
@end

@implementation AdfurikunMoPubBanner

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    self.adViewRect = CGRectMake(0, 0, 320, 50);
    self.appId = info[@"appid"];
    self.banner = [ADFmyBanner getInstance:self.appId];
    [self.banner loadAndNotifyTo:self];
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.appId);
}

- (void)onNativeAdLoadFinish:(ADFNativeAdInfo *)info appID:(NSString *)appID {
    [info playMediaView];
    ADFMediaView *adView = info.mediaView;
    adView.frame = self.adViewRect;
    adView.mediaViewDelegate = self;
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], appID);
    [self.delegate bannerCustomEvent:self didLoadAd:adView];
}

- (void)onNativeAdLoadError:(ADFMovieError *)error appID:(NSString *)appID {
    NSError *err = [[NSError alloc] initWithDomain:@"jp.glossom.adfurikun.error" code:error.errorCode userInfo:@{NSLocalizedDescriptionKey: error.errorMessage}];
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:err], appID);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:err];
}

- (void)onADFMediaViewRendering {
}

- (void)onADFMediaViewRenderingFail {
}

- (void)onADFMediaViewPlayStart {
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.appId);
    [self.delegate trackImpression];
}

- (void)onADFMediaViewPlayFail {
}

- (void)onADFMediaViewReloaded {
}

- (void)onADFMediaViewClick {
    MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], self.appId);
    [self.delegate trackClick];
}

@end
