//
//  Banner6001.m
//  MovieRewardTestApp
//
//  Created by Ren Fujii on 2019/07/25.
//  Copyright © 2019 Sungil Kim. All rights reserved.
//
#import <UnityAds/UnityAds.h>
#import <ADFMovieReward/ADFMovieOptions.h>
#import "Banner6001.h"

#define kRetryTimeForStartAd 5.0f

@interface Banner6001 () <UnityAdsBannerDelegate>
@property (nonatomic, assign)BOOL test_flg;
@property (nonatomic, strong)NSString *gameId;
@property (nonatomic, strong)NSString *placement_id;
@property (nonatomic)NSTimer *loadTimer;
@end

@implementation Banner6001
-(void)setData:(NSDictionary *)data {
    if (ADFMovieOptions.getTestMode) {
        self.test_flg = YES;
    } else {
        self.test_flg = [[data objectForKey:@"test_flg"] boolValue];
    }
    [UnityServices setDebugMode:self.test_flg];
    NSString *data_game_id = [data objectForKey:@"game_id"];
    if (data_game_id && ![data_game_id isEqual:[NSNull null]]) {
        self.gameId = [NSString stringWithFormat:@"%@", data_game_id];
    }
    NSString *data_placement_id = [data objectForKey:@"placement_id"];
    if (data_placement_id && ![data_placement_id isEqual:[NSNull null]]) {
        self.placement_id = [NSString stringWithFormat:@"%@",data_placement_id];
    }
}

-(void)initAdnetworkIfNeeded {
    [UnityAdsBanner setDelegate: self];
    if (![UnityServices isInitialized] && self.gameId) {
        [UnityAds initialize:self.gameId delegate:nil testMode:self.test_flg];
    }
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd {
    if (self.loadTimer && [self.loadTimer isValid]) {
        [self.loadTimer invalidate];
        self.loadTimer = nil;
    }
    if ([UnityAds isReady:self.placement_id]) {
        [UnityAdsBanner setDelegate:self];
        [UnityAdsBanner setBannerPosition:kUnityAdsBannerPositionTopCenter];
        [UnityAdsBanner loadBanner:self.placement_id];
    } else {
        self.loadTimer = [NSTimer scheduledTimerWithTimeInterval:kRetryTimeForStartAd target:self selector:@selector(retryStartAdIfNeeded:) userInfo:nil repeats:NO];
    }
}

- (void)retryStartAdIfNeeded:(NSTimer *)timer {
    if ([UnityAds isReady:self.placement_id]) {
        [self.loadTimer invalidate];
        self.loadTimer = nil;
        [self startAd];
    } else {
        [self sendLoadErrorEvent:nil];
    }
}

/**
 * 対象のクラスがあるかどうか？
 */
-(BOOL)isClassReference {
    NSLog(@"Banner6001 isClassReference");
    Class clazz = NSClassFromString(@"UnityAdsBanner");
    if (clazz) {
        NSLog(@"found Class: UnityAdsBanner");
        return YES;
    }
    else {
        NSLog(@"Not found Class: UnityAdsBanner");
        return NO;
    }
}

-(void)setHasUserConsent:(BOOL)hasUserConsent {
    [super setHasUserConsent:hasUserConsent];
    UADSMetaData *gdprConsentMetaData = [[UADSMetaData alloc] init];
    [gdprConsentMetaData set:@"gdpr.consent" value:hasUserConsent ? @YES : @NO];
    [gdprConsentMetaData commit];
}

-(void)dealloc {
    _gameId = nil;
    _placement_id = nil;
    if (_loadTimer.isValid) {
        [_loadTimer invalidate];
    }
}

- (void)sendLoadErrorEvent:(NSString *)message {
    NSLog(@"UnityAds Banner load error :%@", message);
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadError:)]) {
            if (message) {
                [self setErrorWithMessage:message code:0];
            }
            [self.delegate onNativeMovieAdLoadError:self];
        } else {
            NSLog(@"Banner6001: selector onNativeMovieAdLoadError is not responding");
        }
    } else {
        NSLog(@"Banner6001: delegate is not set");
    }
}

#pragma mark - UnityAdsBannerDelegate

- (void)unityAdsBannerDidClick:(nonnull NSString *)placementId {
    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewClick)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewClick];
        } else {
            NSLog(@"Banner6001: %s onADFMediaViewClick selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"Banner6001: %s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

- (void)unityAdsBannerDidError:(nonnull NSString *)message {
    [self sendLoadErrorEvent:message];
}

- (void)unityAdsBannerDidHide:(nonnull NSString *)placementId {
    NSLog(@"%s", __FUNCTION__);
}

- (void)unityAdsBannerDidLoad:(nonnull NSString *)placementId view:(nonnull UIView *)view {
    self.isAdLoaded = YES;
    NativeAdInfo6001 *info = [[NativeAdInfo6001 alloc] initWithVideoUrl:nil
                                                                  title:@""
                                                            description:@""
                                                           adnetworkKey:@"6001"];
    info.adapter = self;
    [info setupMediaView:view];
    self.adInfo = info;
    if (self.delegate) {
        if ([self.delegate respondsToSelector: @selector(onNativeMovieAdLoadFinish:)]) {
            [self.delegate onNativeMovieAdLoadFinish:self.adInfo];
        } else {
            NSLog(@"Banner6001: %s onNativeMovieAdLoadFinish selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"Banner6001: %s Delegate is not setting", __FUNCTION__);
    }
}

- (void)unityAdsBannerDidShow:(nonnull NSString *)placementId {
    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewPlayStart)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewPlayStart];
        } else {
            NSLog(@"Banner6001: %s onADFMediaViewPlayStart selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"Banner6001: %s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

- (void)unityAdsBannerDidUnload:(nonnull NSString *)placementId {
    NSLog(@"%s", __FUNCTION__);
}

@end

@implementation NativeAdInfo6001

@end
