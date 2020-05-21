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

+ (NSString *)getSDKVersion {
    return BUAdSDKManager.SDKVersion;
}

-(id)init {
    self = [super init];
    if (self) {
        [self setCancellable];
    }
    return self;
}

- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
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
    [super showAdWithPresentingViewController:viewController];

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

#pragma BUFullscreenVideoAdDelegate

- (void)fullscreenVideoMaterialMetaAdDidLoad:(BUFullscreenVideoAd *)fullscreenVideoAd {
    NSLog(@"%s", __func__);
}

- (void)fullscreenVideoAd:(BUFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    NSLog(@"didFailToLoadAdWithError : %@", error);
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

- (void)fullscreenVideoAdVideoDataDidLoad:(BUFullscreenVideoAd *)fullscreenVideoAd {
    self.isAdLoaded = YES;
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

- (void)fullscreenVideoAdWillVisible:(BUFullscreenVideoAd *)fullscreenVideoAd {
    NSLog(@"%s", __func__);
}

- (void)fullscreenVideoAdDidVisible:(BUFullscreenVideoAd *)fullscreenVideoAd {
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)fullscreenVideoAdDidClick:(BUFullscreenVideoAd *)fullscreenVideoAd {
    NSLog(@"%s", __func__);
}

- (void)fullscreenVideoAdWillClose:(BUFullscreenVideoAd *)fullscreenVideoAd {
    NSLog(@"%s", __func__);
}

- (void)fullscreenVideoAdDidClose:(BUFullscreenVideoAd *)fullscreenVideoAd {
    [self setCallbackStatus:MovieRewardCallbackClose];
}

- (void)fullscreenVideoAdDidPlayFinish:(BUFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
}

- (void)fullscreenVideoAdDidClickSkip:(BUFullscreenVideoAd *)fullscreenVideoAd {
    NSLog(@"%s", __func__);
}

@end
