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

- (void)setData:(NSDictionary *)data {
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

- (BOOL)isPrepared {
    return self.rewardedAd.isReady;
}

- (void)showAd {
    [self showAdWithPresentingViewController:[self topMostViewController]];
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
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
}

- (void)adRequestFailure:(NSError *)error {
    NSLog(@"%s error: %@", __FUNCTION__, error);
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsFetchError:)]) {
            [self setErrorWithMessage:error.localizedDescription code:error.code];
            [self.delegate AdsFetchError:self];
        } else {
            NSLog(@"%s AdsFetchError selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

#pragma mark - GADRewardedAdDelegate

- (void)rewardedAd:(GADRewardedAd *)rewardedAd userDidEarnReward:(GADAdReward *)reward {
    NSLog(@"%s", __FUNCTION__);
    self.isAdsCompleteShow = YES;
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidCompleteShow:)]) {
            [self.delegate AdsDidCompleteShow:self];
        } else {
            NSLog(@"%s AdsDidCompleteShow selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

- (void)rewardedAdDidPresent:(GADRewardedAd *)rewardedAd {
    NSLog(@"%s", __FUNCTION__);
    self.isAdsCompleteShow = NO;
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidShow:)]) {
            [self.delegate AdsDidShow:self];
        } else {
            NSLog(@"%s AdsDidShow selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

- (void)rewardedAd:(GADRewardedAd *)rewardedAd didFailToPresentWithError:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsPlayFailed:)]) {
            [self.delegate AdsPlayFailed:self];
        } else {
            NSLog(@"%s AdsPlayFailed selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

- (void)rewardedAdDidDismiss:(GADRewardedAd *)rewardedAd {
    NSLog(@"%s", __FUNCTION__);
    if (self.delegate) {
        if (!self.isAdsCompleteShow) {
            if ([self.delegate respondsToSelector:@selector(AdsPlayFailed:)]) {
                [self.delegate AdsPlayFailed:self];
            } else {
                NSLog(@"%s Skip AdMob RewardAd", __FUNCTION__);
            }
        }
        if ([self.delegate respondsToSelector:@selector(AdsDidHide:)]) {
            [self.delegate AdsDidHide:self];
        } else {
            NSLog(@"%s AdsDidHide selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

@end
