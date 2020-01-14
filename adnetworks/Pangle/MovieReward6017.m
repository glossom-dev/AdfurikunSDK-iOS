//
//  MovieReward6017.m
//  MovieRewardTestApp
//
//  Created by Ren Fujii on 2019/08/20.
//  Copyright © 2019 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import "MovieReward6017.h"
#import <ADFMovieReward/ADFMovieOptions.h>
#import <BUAdSDK/BURewardedVideoAd.h>
#import <BUAdSDK/BURewardedVideoModel.h>
#import <BUAdSDK/BUAdSDKManager.h>

@interface MovieReward6017 ()<BURewardedVideoAdDelegate>
@property (nonatomic, strong) BURewardedVideoAd *rewardedVideoAd;
@property (nonatomic, strong) NSString *tiktokAppID;
@property (nonatomic, strong) NSString *tiktokSlotID;
@property (nonatomic) BOOL didInitAdnetwork;
@property (nonatomic) BOOL isAdLoaded;
@end

@implementation MovieReward6017

- (void)setData:(NSDictionary *)data {
    NSString *data_appID = [data objectForKey:@"appid"];
    if (data_appID && ![data_appID isEqual:[NSNull null]]) {
        self.tiktokAppID = data_appID;
    }
    NSString *data_slotID = [data objectForKey:@"ad_slot_id"];
    if (data_slotID && ![data_slotID isEqual:[NSNull null]]) {
        self.tiktokSlotID = data_slotID;
    }
}

- (BOOL)isPrepared {
    return self.isAdLoaded;
}

- (void)initAdnetworkIfNeeded {
    if (!self.didInitAdnetwork && self.tiktokAppID) {
        [BUAdSDKManager setAppID:self.tiktokAppID];
        [self setTargeting];
        self.didInitAdnetwork = YES;
    }
}

- (void)startAd {
    self.isAdLoaded = NO;
    if (self.rewardedVideoAd) {
        self.rewardedVideoAd = nil;
    }
    if (self.didInitAdnetwork && self.tiktokSlotID) {
        self.rewardedVideoAd = [[BURewardedVideoAd alloc] initWithSlotID:self.tiktokSlotID rewardedVideoModel:nil];
        self.rewardedVideoAd.delegate = self;
        [self.rewardedVideoAd loadAdData];
    }
}

- (void)showAd {
    [self showAdWithPresentingViewController:[self topMostViewController]];
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [self.rewardedVideoAd showAdFromRootViewController:viewController];
    self.isAdLoaded = NO;
}

- (BOOL)isClassReference {
    NSLog(@"MovieReward6017 isClassReference");
    Class clazz = NSClassFromString(@"BURewardedVideoAd");
    if (clazz) {
        NSLog(@"found Class: BURewardedVideoAd");
        return YES;
    } else {
        NSLog(@"Not found Class: BURewardedVideoAd");
        return NO;
    }
}

- (void)setTargeting {
    // 年齢
    int age = [ADFMovieOptions getUserAge];
    if (age > 0) {
        [BUAdSDKManager setUserAge:age];
    }
    // 性別
    ADFMovieOptions_Gender gender = [ADFMovieOptions getUserGender];
    if (ADFMovieOptions_Gender_Male == gender) {
        [BUAdSDKManager setUserGender:BUUserGenderMan];
    } else if (ADFMovieOptions_Gender_Female == gender) {
        [BUAdSDKManager setUserGender:BUUserGenderWoman];
    } else {
        [BUAdSDKManager setUserGender:BUUserGenderUnknown];
    }
}

#pragma mark - BURewardedVideoAdDelegate

- (void)rewardedVideoAdDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"%s", __func__);
}


- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    NSLog(@"didFailToLoadAdWithError : %@", error);
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsFetchError:)]) {
            [self setErrorWithMessage:error.localizedDescription code:error.code];
            [self.delegate AdsFetchError:self];
        } else {
            NSLog(@"%s AdsFetchError selector is not responding", __FUNCTION__);
        }
    }
}

- (void)rewardedVideoAdVideoDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    self.isAdLoaded = YES;
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsFetchCompleted:)]) {
            [self.delegate AdsFetchCompleted:self];
        } else {
            NSLog(@"adsFetchCompleted is not responding");
        }
    } else {
        NSLog(@"adsFetchCompleted is not set");
    }
}

- (void)rewardedVideoAdWillVisible:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"%s", __func__);
}

- (void)rewardedVideoAdDidVisible:(BURewardedVideoAd *)rewardedVideoAd {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidShow:)]) {
            [self.delegate AdsDidShow:self];
        } else {
            NSLog(@"adsDidShow is not responding");
        }
    } else {
        NSLog(@"adsDidShow is not set");
    }
}

- (void)rewardedVideoAdWillClose:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"%s", __func__);
}

- (void)rewardedVideoAdDidClose:(BURewardedVideoAd *)rewardedVideoAd {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidHide:)]) {
            [self.delegate AdsDidHide:self];
        } else {
            NSLog(@"adsDidHide is not responding");
        }
    } else {
        NSLog(@"adsDidHide is not set");
    }
}

- (void)rewardedVideoAdDidClick:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"%s", __func__);
}

- (void)rewardedVideoAdDidPlayFinish:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidCompleteShow:)]) {
            [self.delegate AdsDidCompleteShow:self];
        } else {
            NSLog(@"adsDidCompleteShow is not responding");
        }
    } else {
        NSLog(@"adsDidCompleteShow is not set");
    }
}

- (void)rewardedVideoAdDidClickSkip:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"%s", __func__);
}

@end
