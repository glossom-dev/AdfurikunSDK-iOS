//
//  Banner6020.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/06/17.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "Banner6020.h"
#import <MoPub/MoPub.h>

@interface Banner6020() <MPAdViewDelegate>

@property (nonatomic, strong) NSString *adUnitId;
@property (nonatomic) MPAdView *adView;
@property (nonatomic) BOOL hasPendedLoad;
@end

@implementation Banner6020

- (instancetype)init {
    self = [super init];
    if (self) {
        self.hasPendedLoad = false;
        self.adSize = kMPPresetMaxAdSize50Height;
    }
    return self;
}

- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"MPAdView");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: MPAdView");
        return NO;
    }
    return YES;
}

- (void)setData:(NSDictionary *)data {
    NSLog(@"Banner6020 : setData");

    NSString *adUnitId = [data objectForKey:@"ad_unit_id"];
    if (adUnitId && ![adUnitId isEqual:[NSNull null]]) {
        self.adUnitId = [NSString stringWithString:adUnitId];
    }

    NSNumber *pixelRateNumber = data[@"pixelRate"];
    if (pixelRateNumber && ![[NSNull null] isEqual:pixelRateNumber]) {
        self.viewabilityPixelRate = pixelRateNumber.intValue;
    }
    NSNumber *displayTimeNumber = data[@"displayTime"];
    if (displayTimeNumber && ![[NSNull null] isEqual:displayTimeNumber]) {
        self.viewabilityDisplayTime = displayTimeNumber.intValue;
    }
    NSNumber *timerIntervalNumber = data[@"timerInterval"];
    if (timerIntervalNumber && ![[NSNull null] isEqual:timerIntervalNumber]) {
        self.viewabilityTimerInterval = timerIntervalNumber.intValue;
    }
}

-(void)initAdnetworkIfNeeded {
    NSLog(@"Banner6020 : initAdnetworkIfNeeded");

    MPMoPubConfiguration *sdkConfig = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:self.adUnitId];

    sdkConfig.globalMediationSettings = @[];
    sdkConfig.loggingLevel = MPBLogLevelInfo;

    [[MoPub sharedInstance] initializeSdkWithConfiguration:sdkConfig completion:^{
        NSLog(@"SDK initialization complete");
        if (self.hasPendedLoad) {
            self.hasPendedLoad = false;
            [self startAd];
        }
    }];
}

- (BOOL)isPrepared {
    NSLog(@"Banner6020 : isPrepared");
    return self.isAdLoaded;
}

// SDKのLoading関数を呼び出す
- (void)startAd {
    NSLog(@"Banner6020 : startAd");
    if (self.adUnitId == nil) {
        return;
    }
    if (![MoPub sharedInstance].isSdkInitialized) {
        self.hasPendedLoad = true;
    }

    [super startAd];

    self.hasPendedLoad = false;
    self.isAdLoaded = false;

    if (self.adView) {
        [self.adView removeFromSuperview];
        self.adView = nil;
    }
    self.adView = [[MPAdView alloc] initWithAdUnitId:self.adUnitId];
    self.adView.delegate = self;
    self.adView.frame = CGRectZero;
    [self.adView stopAutomaticallyRefreshingContents];

    [self.adView loadAdWithMaxAdSize:kMPPresetMaxAdSize50Height];
}

- (void)startAdWithOption:(NSDictionary *)option {
    [self startAd];
}

- (void)adViewDidLoadAd:(MPAdView *)view adSize:(CGSize)adSize {
    NSLog(@"Banner6020 : adViewDidLoadAd");
    self.isAdLoaded = true;

    NativeAdInfo6020 *info = [[NativeAdInfo6020 alloc] initWithVideoUrl:nil
                                                                  title:@""
                                                            description:@""
                                                           adnetworkKey:@"6020"];

    info.mediaType = ADFNativeAdType_Image;
    info.adapter = self;
    [info setupMediaView:view];
    self.adInfo = info;

    [self setCustomMediaview:view];

    if (self.delegate) {
        if ([self.delegate respondsToSelector: @selector(onNativeMovieAdLoadFinish:)]) {
            [self.delegate onNativeMovieAdLoadFinish:self.adInfo];
        } else {
            NSLog(@"Banner6020: %s onNativeMovieAdLoadFinish selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"Banner6020: %s Delegate is not setting", __FUNCTION__);
    }
}

- (void)adView:(MPAdView *)view didFailToLoadAdWithError:(NSError *)error {
    NSLog(@"Banner6020 : didFailToLoadAdWithError %@", error);
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadError:)]) {
            if (error) {
                [self setErrorWithMessage:error.localizedDescription code:error.code];
            }
            [self.delegate onNativeMovieAdLoadError: self];
        } else {
            NSLog(@"Banner6020: selector onNativeMovieAdLoadError is not responding");
        }
    } else {
        NSLog(@"Banner6020: %s Delegate is not setting", __FUNCTION__);
    }
}

- (void)willPresentModalViewForAd:(MPAdView *)view {
    NSLog(@"willPresentModalViewForAd");
    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewClick)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewClick];
        } else {
            NSLog(@"Banner6020: %s onADFMediaViewClick selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"Banner6020: %s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

- (void)didDismissModalViewForAd:(MPAdView *)view {
    NSLog(@"didDismissModalViewForAd");
}

- (void)willLeaveApplicationFromAd:(MPAdView *)view {
    NSLog(@"willLeaveApplicationFromAd");
}

- (UIViewController *)viewControllerForPresentingModalView {
    return [self topMostViewController];
}

@end

@implementation NativeAdInfo6020

- (void)playMediaView {
    if (self.adapter) {
        [self.adapter startViewabilityCheck];
    }
}

@end
