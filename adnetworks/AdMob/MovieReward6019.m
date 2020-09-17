//
//  MovieReward6019.m
//  MovieRewardTestApp
//
//  Created by Ren Fujii on 2019/11/13.
//  Copyright © 2019 Glossom, Inc. All rights reserved.
//

#import "MovieReward6019.h"
#import <ADFMovieReward/ADFMovieOptions.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface MovieReward6019 ()<GADRewardedAdDelegate>
@property(nonatomic) GADRewardedAd *rewardedAd;
@property(nonatomic) NSString *unitID;
@property(nonatomic) BOOL testFlg;
@property(nonatomic) BOOL isAdsCompleteShow;
@end

@implementation MovieReward6019

+(NSString *)getAdapterVersion {
    return @"7.64.0.1";
}

-(id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    NSString* admobId = [data objectForKey:@"ad_unit_id"];
    if (admobId != nil && ![admobId isEqual:[NSNull null]]) {
        self.unitID = [[NSString alloc] initWithString:admobId];
    }
    self.testFlg = [[data objectForKey:@"test_flg"] boolValue];
    self.isAdsCompleteShow = NO;
}

- (void)initAdnetworkIfNeeded {
    if (self.testFlg) {
        //GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[@"コンソールに出力されたデバイスIDを入力してください。"]; //詳細　https://developers.google.com/admob/ios/test-ads?hl=ja
    }
    ADFMovieOptions_Sound soundState = [ADFMovieOptions getSoundState];
    if (ADFMovieOptions_Sound_On == soundState) {
        GADMobileAds.sharedInstance.applicationMuted = NO;
    } else if (ADFMovieOptions_Sound_Off == soundState) {
        GADMobileAds.sharedInstance.applicationMuted = YES;
    }
}

- (void)startAd {
    if (!self.rewardedAd || !self.rewardedAd.isReady) {
        self.rewardedAd = [[GADRewardedAd alloc] initWithAdUnitID:self.unitID];
        GADRequest *request = [GADRequest request];
        [self.rewardedAd loadRequest:request completionHandler:^(GADRequestError * _Nullable error) {
            if (error) {
                [self adRequestFailure:error];
            } else {
                [self adRequestSccess];
            }
        }];
    }
}

- (BOOL)isPrepared {
    return self.rewardedAd.isReady;
}

- (void)showAd {
    [self showAdWithPresentingViewController:[self topMostViewController]];
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAdWithPresentingViewController:viewController];

    if (self.rewardedAd.isReady) {
        [self.rewardedAd presentFromRootViewController:[self topMostViewController] delegate:self];
    }
}

- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"GADRewardedAd");
    if (clazz) {
        NSLog(@"Found Class: GADRewardedAd");
    } else {
        NSLog(@"Not found Class: GADRewardedAd");
        return NO;
    }
    return YES;
}

- (void)adRequestSccess {
    NSLog(@"%s", __FUNCTION__);
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

- (void)adRequestFailure:(NSError *)error {
    NSLog(@"%s error: %@", __FUNCTION__, error);
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

#pragma mark - GADRewardedAdDelegate

- (void)rewardedAd:(GADRewardedAd *)rewardedAd userDidEarnReward:(GADAdReward *)reward {
    NSLog(@"%s", __FUNCTION__);
    self.isAdsCompleteShow = YES;
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
}

- (void)rewardedAdDidPresent:(GADRewardedAd *)rewardedAd {
    NSLog(@"%s", __FUNCTION__);
    self.isAdsCompleteShow = NO;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)rewardedAd:(GADRewardedAd *)rewardedAd didFailToPresentWithError:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}

- (void)rewardedAdDidDismiss:(GADRewardedAd *)rewardedAd {
    NSLog(@"%s", __FUNCTION__);
    if (!self.isAdsCompleteShow) {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
    [self setCallbackStatus:MovieRewardCallbackClose];
}

@end
