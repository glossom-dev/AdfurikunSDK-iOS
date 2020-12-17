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

@interface Banner6001 () <UADSBannerViewDelegate>
@property (nonatomic, assign) BOOL testFlg;
@property (nonatomic, strong) NSString *gameId;
@property (nonatomic, strong) NSString *placementId;
@property (nonatomic) BOOL isInitialized;
@property (nonatomic, strong) UADSBannerView *bannerView;
@end

@implementation Banner6001

-(void)setData:(NSDictionary *)data {
    [super setData:data];
    
    if (ADFMovieOptions.getTestMode) {
        self.testFlg = YES;
    } else {
        NSNumber *testFlg = [data objectForKey:@"test_flg"];
        if ([self isNotNull:testFlg] && [testFlg isKindOfClass:[NSNumber class]]) {
            self.testFlg = [testFlg boolValue];
        }
    }
    [UnityServices setDebugMode:self.testFlg];

    NSString *dataGameId = [data objectForKey:@"game_id"];
    if ([self isNotNull:dataGameId]) {
        self.gameId = [NSString stringWithFormat:@"%@", dataGameId];
    }
    NSString *dataPlacementId = [data objectForKey:@"placement_id"];
    if ([self isNotNull:dataPlacementId]) {
        self.placementId = [NSString stringWithFormat:@"%@",dataPlacementId];
    }

    NSNumber *pixelRateNumber = data[@"pixelRate"];
    if ([self isNotNull:pixelRateNumber] && [pixelRateNumber isKindOfClass:[NSNumber class]]) {
        self.viewabilityPixelRate = pixelRateNumber.intValue;
    }
    NSNumber *displayTimeNumber = data[@"displayTime"];
    if ([self isNotNull:displayTimeNumber] && [displayTimeNumber isKindOfClass:[NSNumber class]]) {
        self.viewabilityDisplayTime = displayTimeNumber.intValue;
    }
    NSNumber *timerIntervalNumber = data[@"timerInterval"];
    if ([self isNotNull:timerIntervalNumber] && [timerIntervalNumber isKindOfClass:[NSNumber class]]) {
        self.viewabilityTimerInterval = timerIntervalNumber.intValue;
    }
}

-(void)initAdnetworkIfNeeded {
    if (![UnityServices isInitialized] && self.gameId) {
        @try {
            [UnityAds initialize:self.gameId testMode:self.testFlg];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    }
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd {
    @try {
        [super startAd];
        
        self.isAdLoaded = false;
        
        if (self.bannerView) {
            self.bannerView = nil;
        }
        if (self.placementId) {
            self.bannerView = [[UADSBannerView alloc] initWithPlacementId:self.placementId size:CGSizeMake(320.0, 50.0)];
        }
        
        BOOL isReady = [UnityAds isReady:self.placementId];
        NSLog(@"%s unityAds placement id : %@, is ready : %@", __func__, self.placementId, (isReady ? @"true" : @"false"));
        if (isReady && self.bannerView) {
            self.bannerView.delegate = self;
            [self.bannerView load];
        }
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

/**
 * 対象のクラスがあるかどうか？
 */
-(BOOL)isClassReference {
    NSLog(@"Banner6001 isClassReference");
    Class clazz = NSClassFromString(@"UADSBannerView");
    if (clazz) {
        NSLog(@"found Class: UADSBannerView");
        return YES;
    }
    else {
        NSLog(@"Not found Class: UADSBannerView");
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
    _placementId = nil;
    _bannerView = nil;
}

#pragma mark - UADSBannerViewDelegate

-(void)bannerViewDidLoad:(UADSBannerView *)bannerView {
    NSLog(@"%s called", __func__);
    self.isAdLoaded = true;
    NativeAdInfo6001 *info = [[NativeAdInfo6001 alloc] initWithVideoUrl:nil
                                                                  title:@""
                                                            description:@""
                                                           adnetworkKey:@"6001"];
    info.mediaType = ADFNativeAdType_Image;

    info.adapter = self;
    [info setupMediaView:bannerView];
    self.adInfo = info;

    [self setCustomMediaview:bannerView];
    [self startViewabilityCheck];

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

-(void)bannerViewDidClick:(UADSBannerView *)bannerView {
    NSLog(@"%s called", __func__);
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

-(void)bannerViewDidLeaveApplication:(UADSBannerView *)bannerView {
    NSLog(@"%s called", __func__);
}

-(void)bannerViewDidError:(UADSBannerView *)bannerView error:(UADSBannerError *)error {
    NSLog(@"%s called", __func__);
    NSLog(@"UnityAds Banner load error :%ld", error.code);
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadError:)]) {
            if (error) {
                [self setErrorWithMessage:@"" code:error.code];
            }
            [self.delegate onNativeMovieAdLoadError:self];
        } else {
            NSLog(@"Banner6001: selector onNativeMovieAdLoadError is not responding");
        }
    } else {
        NSLog(@"Banner6001: delegate is not set");
    }
}

@end


@implementation NativeAdInfo6001

-(void)playMediaView {
    if (self.mediaView.adapterInnerDelegate) {
        if ([self.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewRendering)]) {
            [self.mediaView.adapterInnerDelegate onADFMediaViewRendering];
        } else {
            NSLog(@"NativeAdInfo6001: %s onADFMediaViewRendering selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"NativeAdInfo6001: %s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

@end

@implementation Banner6030

@end

@implementation Banner6031

@end
