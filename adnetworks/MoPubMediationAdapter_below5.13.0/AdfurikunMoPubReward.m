//
//  AdfurikunMoPubReward.m
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "AdfurikunMoPubReward.h"
#import <ADFMovieReward/ADFmyMovieReward.h>

@interface AdfurikunMoPubReward ()<ADFmyMovieRewardDelegate>
@property (nonatomic, copy)NSString *appId;
@property (nonatomic)ADFmyMovieReward *reward;
@end

@implementation AdfurikunMoPubReward

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    self.appId = info[@"appid"];
    self.reward = [ADFmyMovieReward getInstance:self.appId delegate:self];
    [self.reward load];
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.appId);
}

- (BOOL)hasAdAvailable {
    return self.reward ? self.reward.isPrepared : NO;
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController {
    if ([self hasAdAvailable]) {
        MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], self.appId);
        [self.reward playWithPresentingViewController:viewController];
    } else {
        [self AdsPlayFailed:self.appId];
    }
}

- (void)handleCustomEventInvalidated {
    if (self.reward) {
        [self.reward dispose];
    }
}

- (void)AdsFetchCompleted:(NSString *)appID isTestMode:(BOOL)isTestMode_inApp {
    MPLogInfo(@"Adfurikun rewarded video content is ready");
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], appID);
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}

- (void)AdsFetchFailed:(NSString *)appID error:(NSError *)error {
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error], appID);
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
}

- (void)AdsDidShow:(NSString *)appID adNetworkKey:(NSString *)adNetworkKey {
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], appID);
    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], appID);
    MPLogAdEvent([MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)], appID);
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
}

- (void)AdsPlayFailed:(NSString *)appID {
    NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
    MPLogAdEvent([MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error], appID);
    [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
}

- (void)AdsDidCompleteShow:(NSString *)appID {}

- (void)AdsDidHide:(NSString *)appID {
    MPLogAdEvent([MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)], appID);
    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
    MPLogAdEvent([MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)], appID);
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
    
}
@end
