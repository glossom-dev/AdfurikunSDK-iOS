//
//  AdfurikunMoPubInterstitial.m
//  Created by Ren Fujii on 2020/05/11.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "AdfurikunMoPubInterstitial.h"
#import <ADFMovieReward/ADFmyInterstitial.h>

@interface AdfurikunMoPubInterstitial ()<ADFmyMovieRewardDelegate>
@property (nonatomic, copy)NSString *appId;
@property (nonatomic)ADFmyInterstitial *interstitial;
@end

@implementation AdfurikunMoPubInterstitial

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    self.appId = info[@"appid"];
    self.interstitial = [ADFmyInterstitial getInstance:self.appId delegate:self];
    [self.interstitial load];
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.appId);
}

- (BOOL)hasAdAvailable {
    return self.interstitial ? self.interstitial.isPrepared : NO;
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    if ([self hasAdAvailable]) {
        MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.appId);
        [self.interstitial playWithPresentingViewController:rootViewController];
    } else {
        [self AdsPlayFailed:self.appId];
    }
}

- (void)AdsFetchCompleted:(NSString *)appID isTestMode:(BOOL)isTestMode_inApp {
    [self.delegate interstitialCustomEvent:self didLoadAd:appID];
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], appID);
}

- (void)AdsFetchFailed:(NSString *)appID error:(NSError *)error {
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], appID);
}

- (void)AdsDidShow:(NSString *)appID adNetworkKey:(NSString *)adNetworkKey {
    [self.delegate interstitialCustomEventWillAppear:self];
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], appID);
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], appID);

    [self.delegate interstitialCustomEventDidAppear:self];
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], appID);
}

- (void)AdsPlayFailed:(NSString *)appID {
    NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], appID);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)AdsDidCompleteShow:(NSString *)appID {
    
}

- (void)AdsDidHide:(NSString *)appID {
    [self.delegate interstitialCustomEventWillDisappear:self];
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], appID);

    [self.delegate interstitialCustomEventDidDisappear:self];
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], appID);
}
@end
