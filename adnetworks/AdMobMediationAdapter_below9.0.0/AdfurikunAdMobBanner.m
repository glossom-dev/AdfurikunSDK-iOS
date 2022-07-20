//
//  AdfurikunAdMobBanner.m
//
//  Copyright © 2019 Glossom.Inc. All rights reserved.
//

#import "AdfurikunAdMobBanner.h"

@implementation AdfurikunAdMobBanner
@synthesize delegate;

- (void)requestBannerAd:(GADAdSize)adSize parameter:(NSString *)serverParameter label:(NSString *)serverLabel request:(GADCustomEventRequest *)request {
    [ADFmyBanner initializeWithAppID:serverParameter];
    self.bannerAd = [ADFmyBanner getInstance:serverParameter];
    [self.bannerAd loadAndNotifyTo:self];
    self.bannerSize = CGRectMake(0, 0, 320, 50);
}

- (void)onNativeAdLoadFinish:(ADFNativeAdInfo *)info appID:(NSString *)appID {
    if (info.mediaView) {
        [info playMediaView];
        info.mediaView.mediaViewDelegate = self;
        info.mediaView.frame = self.bannerSize;
        [self.delegate customEventBanner:self didReceiveAd:info.mediaView];
    }
}

- (void)onNativeAdLoadError:(ADFMovieError *)error appID:(NSString *)appID {
    [self.delegate customEventBanner:self didFailAd:nil];
}

- (void)onADFMediaViewPlayStart {
    NSLog(@"%s", __FUNCTION__);
}

- (void)onADFMediaViewPlayFinish {
    NSLog(@"%s", __FUNCTION__);
}

- (void)onADFMediaViewPlayFail {
    NSLog(@"%s", __FUNCTION__);
}

- (void)onADFMediaViewLoadFinish {
    NSLog(@"%s", __FUNCTION__);
}

- (void)onADFMediaViewLoadFail {
    NSLog(@"%s", __FUNCTION__);
}

- (void)onADFMediaViewRendering {
    NSLog(@"%s", __FUNCTION__);
}

- (void)onADFMediaViewClick {
    NSLog(@"%s", __FUNCTION__);
    [self.delegate customEventBannerWasClicked:self];
}

@end
