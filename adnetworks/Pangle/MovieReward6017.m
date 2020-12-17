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

+ (NSString *)getSDKVersion {
    return BUAdSDKManager.SDKVersion;
}

+(NSString *)getAdapterVersion {
    return @"3.3.0.5.2";
}

- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    NSString *data_appID = [data objectForKey:@"appid"];
    if ([self isNotNull:data_appID]) {
        self.tiktokAppID = [NSString stringWithFormat:@"%@", data_appID];
    }
    NSString *data_slotID = [data objectForKey:@"ad_slot_id"];
    if ([self isNotNull:data_slotID]) {
        self.tiktokSlotID = [NSString stringWithFormat:@"%@", data_slotID];
    }
}

- (BOOL)isPrepared {
    return self.isAdLoaded;
}

- (void)initAdnetworkIfNeeded {
    if (!self.didInitAdnetwork && self.tiktokAppID) {
        @try {
            [BUAdSDKManager setAppID:self.tiktokAppID];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
        self.didInitAdnetwork = YES;
    }
}

- (void)startAd {
    self.isAdLoaded = NO;
    if (self.rewardedVideoAd) {
        self.rewardedVideoAd = nil;
    }
    if (self.didInitAdnetwork && self.tiktokSlotID) {
        @try {
            BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
            self.rewardedVideoAd = [[BURewardedVideoAd alloc] initWithSlotID:self.tiktokSlotID rewardedVideoModel:model];
            self.rewardedVideoAd.delegate = self;
            [self.rewardedVideoAd loadAdData];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    }
}

- (void)showAd {
    [self showAdWithPresentingViewController:[self topMostViewController]];
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    if (self.rewardedVideoAd) {
        [super showAdWithPresentingViewController:viewController];
        
        @try {
            [self.rewardedVideoAd showAdFromRootViewController:viewController];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
        self.isAdLoaded = NO;
    }
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

#pragma mark - BURewardedVideoAdDelegate

- (void)rewardedVideoAdDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"%s", __func__);
}


- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    NSLog(@"didFailToLoadAdWithError : %@", error);
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

- (void)rewardedVideoAdVideoDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    self.isAdLoaded = YES;
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

- (void)rewardedVideoAdWillVisible:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"%s", __func__);
}

- (void)rewardedVideoAdDidVisible:(BURewardedVideoAd *)rewardedVideoAd {
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)rewardedVideoAdWillClose:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"%s", __func__);
}

- (void)rewardedVideoAdDidClose:(BURewardedVideoAd *)rewardedVideoAd {
    [self setCallbackStatus:MovieRewardCallbackClose];
}

- (void)rewardedVideoAdDidClick:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"%s", __func__);
}

- (void)rewardedVideoAdDidPlayFinish:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
}

- (void)rewardedVideoAdDidClickSkip:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"%s", __func__);
}

@end
