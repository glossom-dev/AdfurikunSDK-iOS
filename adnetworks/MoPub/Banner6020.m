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
@end

@implementation Banner6020

+ (NSString *)getAdapterRevisionVersion {
    return @"1";
}

- (instancetype)init {
    self = [super init];
    if (self) {
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
    [super setData:data];
    
    NSString *adUnitId = [data objectForKey:@"ad_unit_id"];
    if ([self isNotNull:adUnitId]) {
        self.adUnitId = [NSString stringWithFormat:@"%@", adUnitId];
    }

}

-(void)initAdnetworkIfNeeded {
    NSLog(@"Banner6020 : initAdnetworkIfNeeded");
    if (![self needsToInit]) {
        return;
    }
    
    @try {
        MPMoPubConfiguration *sdkConfig = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:self.adUnitId];
        
        sdkConfig.globalMediationSettings = @[];
        sdkConfig.loggingLevel = MPBLogLevelInfo;
        
        [[MoPub sharedInstance] initializeSdkWithConfiguration:sdkConfig completion:^{
            NSLog(@"SDK initialization complete");
            [self initCompleteAndRetryStartAdIfNeeded];
        }];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
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
    if (![self canStartAd]) {
        return;
    }

    [super startAd];

    self.isAdLoaded = false;

    if (self.adView) {
        [self.adView removeFromSuperview];
        self.adView = nil;
    }
    @try {
        self.adView = [[MPAdView alloc] initWithAdUnitId:self.adUnitId];
        self.adView.delegate = self;
        self.adView.frame = CGRectZero;
        [self.adView stopAutomaticallyRefreshingContents];
        
        [self.adView loadAdWithMaxAdSize:kMPPresetMaxAdSize50Height];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
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
    [self setCallbackStatus:NativeAdCallbackLoadFinish];
}

- (void)adView:(MPAdView *)view didFailToLoadAdWithError:(NSError *)error {
    NSLog(@"Banner6020 : didFailToLoadAdWithError %@", error);
    if (error) {
        [self setErrorWithMessage:error.localizedDescription code:error.code];
    }
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

- (void)willPresentModalViewForAd:(MPAdView *)view {
    NSLog(@"willPresentModalViewForAd");
    [self setCallbackStatus:NativeAdCallbackClick];
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
        [self.adapter setCallbackStatus:NativeAdCallbackRendering];
        [self.adapter startViewabilityCheck];
    }
}

@end
