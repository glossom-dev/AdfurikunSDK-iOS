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
@property (nonatomic, strong) UADSBannerView *bannerView;
@end

@implementation Banner6001

+ (NSString *)getSDKVersion {
    return UnityServices.getVersion;
}

+ (NSString *)getAdapterRevisionVersion {
    return @"4";
}

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
}

-(void)initAdnetworkIfNeeded {
    if (![UnityServices isInitialized] && self.gameId) {
        @try {
            [UnityAds initialize:self.gameId testMode:self.testFlg];
            [self initCompleteAndRetryStartAdIfNeeded];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    }
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd {
    if (![self canStartAd]) {
        return;
    }

    @try {
        [super startAd];
        
        [self requireToAsyncRequestAd];
        
        self.isAdLoaded = false;
        
        if (self.bannerView) {
            self.bannerView = nil;
        }
        if (self.placementId) {
            self.bannerView = [[UADSBannerView alloc] initWithPlacementId:self.placementId size:CGSizeMake(320.0, 50.0)];
        }
        
        if (self.bannerView) {
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
    [self setCallbackStatus:NativeAdCallbackLoadFinish];
}

-(void)bannerViewDidClick:(UADSBannerView *)bannerView {
    NSLog(@"%s called", __func__);
    [self setCallbackStatus:NativeAdCallbackClick];
}

-(void)bannerViewDidLeaveApplication:(UADSBannerView *)bannerView {
    NSLog(@"%s called", __func__);
}

-(void)bannerViewDidError:(UADSBannerView *)bannerView error:(UADSBannerError *)error {
    NSLog(@"%s called", __func__);
    NSLog(@"UnityAds Banner load error :%ld", error.code);
    if (error) {
        [self setErrorWithMessage:@"" code:error.code];
    }
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

@end


@implementation NativeAdInfo6001

-(void)playMediaView {
    if (self.adapter) {
        [self.adapter setCallbackStatus:NativeAdCallbackRendering];
    }
}

@end

@implementation Banner6030

@end

@implementation Banner6031

@end
