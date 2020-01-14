//
//  MovieInterstitial6017.m
//  MovieRewardTestApp
//
//  Created by Ren Fujii on 2019/08/20.
//  Copyright © 2019 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import "MovieInterstitial6017.h"
#import <ADFMovieReward/ADFMovieOptions.h>
#import <BUAdSDK/BUFullscreenVideoAd.h>
#import <BUAdSDK/BUAdSDKManager.h>

@interface MovieInterstitial6017 ()<BUFullscreenVideoAdDelegate>
@property (nonatomic, strong) BUFullscreenVideoAd *fullscreenVideoAd;
@property (nonatomic, strong) NSString *tiktokAppID;
@property (nonatomic, strong) NSString *tiktokSlotID;
@property (nonatomic) BOOL didInitAdnetwork;
@property (nonatomic) BOOL isAdLoaded;
@end

@implementation MovieInterstitial6017

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
    if (self.fullscreenVideoAd) {
        self.fullscreenVideoAd = nil;
    }
    if (self.didInitAdnetwork && self.tiktokSlotID) {
        self.fullscreenVideoAd = [[BUFullscreenVideoAd alloc] initWithSlotID:self.tiktokSlotID];
        self.fullscreenVideoAd.delegate = self;
        [self.fullscreenVideoAd loadAdData];
    }
}

- (void)showAd {
    [self showAdWithPresentingViewController:[self topMostViewController]];
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [self.fullscreenVideoAd showAdFromRootViewController:viewController];
    self.isAdLoaded = NO;
}

- (BOOL)isClassReference {
    NSLog(@"MovieInterstitial6017 isClassReference");
    Class clazz = NSClassFromString(@"BUFullscreenVideoAd");
    if (clazz) {
        NSLog(@"found Class: BUFullscreenVideoAd");
        return YES;
    } else {
        NSLog(@"Not found Class: BUFullscreenVideoAd");
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

#pragma BUFullscreenVideoAdDelegate

- (void)fullscreenVideoMaterialMetaAdDidLoad:(BUFullscreenVideoAd *)fullscreenVideoAd {
    NSLog(@"%s", __func__);
}

- (void)fullscreenVideoAd:(BUFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
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

- (void)fullscreenVideoAdVideoDataDidLoad:(BUFullscreenVideoAd *)fullscreenVideoAd {
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

- (void)fullscreenVideoAdWillVisible:(BUFullscreenVideoAd *)fullscreenVideoAd {
    NSLog(@"%s", __func__);
}

- (void)fullscreenVideoAdDidVisible:(BUFullscreenVideoAd *)fullscreenVideoAd {
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

- (void)fullscreenVideoAdDidClick:(BUFullscreenVideoAd *)fullscreenVideoAd {
    NSLog(@"%s", __func__);
}

- (void)fullscreenVideoAdWillClose:(BUFullscreenVideoAd *)fullscreenVideoAd {
    NSLog(@"%s", __func__);
}

- (void)fullscreenVideoAdDidClose:(BUFullscreenVideoAd *)fullscreenVideoAd {
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

- (void)fullscreenVideoAdDidPlayFinish:(BUFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
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

- (void)fullscreenVideoAdDidClickSkip:(BUFullscreenVideoAd *)fullscreenVideoAd {
    NSLog(@"%s", __func__);
}

@end
