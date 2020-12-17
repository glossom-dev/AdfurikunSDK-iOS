//
//  Banner6000.m
//
//  Created by Ren Fujii on 2019/07/26.
//  Copyright © 2019 ADFULLY Inc.
//
#import <AppLovinSDK/AppLovinSDK.h>
#import "Banner6000.h"

@interface Banner6000 () <ALAdLoadDelegate, ALAdDisplayDelegate>
@property (nonatomic, strong)ALAdView *adView;
@property (nonatomic, strong)NSString *zoneIdentifier;
@property (nonatomic, strong)NSString* appLovinSdkKey;
@end

@implementation Banner6000

- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"ALAdView");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: ALAdView");
        return NO;
    }
    return YES;
}

- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    NSString *data_sdkKey = [data objectForKey:@"sdk_key"];
    if ([self isNotNull:data_sdkKey]) {
        self.appLovinSdkKey = [NSString stringWithFormat:@"%@", data_sdkKey];
    }
    NSString *data_zoneID = [data objectForKey:@"zone_id"];
    if ([self isNotNull:data_zoneID]) {
        self.zoneIdentifier = [NSString stringWithFormat:@"%@", data_zoneID];
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
    if (!self.adView && self.appLovinSdkKey && self.zoneIdentifier) {
        @try {
            self.adView = [[ALAdView alloc] initWithSdk:[ALSdk sharedWithKey:self.appLovinSdkKey]
                                                   size:ALAdSize.banner
                                         zoneIdentifier:self.zoneIdentifier];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
        
        self.adView.adLoadDelegate = self;
        self.adView.adDisplayDelegate = self;
    }
}

- (void)startAd {
    [super startAd];
    
    self.isAdLoaded = NO;
    if (self.adView) {
        @try {
            [self.adView loadNextAd];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    }
}

-(void)setHasUserConsent:(BOOL)hasUserConsent {
    [super setHasUserConsent:hasUserConsent];
    [ALPrivacySettings setHasUserConsent:hasUserConsent];
}

#pragma mark - Ad Load Delegate

- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad {
    NSLog(@"%s", __FUNCTION__);
    self.isAdLoaded = YES;
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadFinish:)]) {
            NativeAdInfo6000 *info = [[NativeAdInfo6000 alloc] initWithVideoUrl:nil
                                                                          title:@""
                                                                    description:@""
                                                                   adnetworkKey:@"6000"];
            info.mediaType = ADFNativeAdType_Image;
            info.adapter = self;
            [info setupMediaView:self.adView];
            self.adInfo = info;
            
            [self.delegate onNativeMovieAdLoadFinish:self.adInfo];
            
        } else {
            NSLog(@"Banner6000: %s onNativeMovieAdLoadFinish selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"Banner6000: %s Delegate is not setting", __FUNCTION__);
    }
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code {
    NSLog(@"%s", __FUNCTION__);
    self.isAdLoaded = NO;
    NSLog(@"AppLovin Banner load error :%d", code);
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadError:)]) {
            if (code) {
                [self setErrorWithMessage:nil code:code];
            }
            [self.delegate onNativeMovieAdLoadError:self];
        } else {
            NSLog(@"Banner6000: selector onNativeMovieAdLoadError is not responding");
        }
    } else {
        NSLog(@"Banner6000: delegate is not set");
    }
}

#pragma mark - Ad Display Delegate

- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view {
    NSLog(@"%s", __FUNCTION__);
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view {
    NSLog(@"%s", __FUNCTION__);
}

- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view {
    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewClick)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewClick];
        } else {
            NSLog(@"Banner6000: %s onADFMediaViewClick selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"Banner6000: %s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

@end

@implementation NativeAdInfo6000

- (void)playMediaView {
    if (self.adapter) {
        if (self.mediaView.adapterInnerDelegate) {
            if ([self.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewRendering)]) {
                [self.mediaView.adapterInnerDelegate onADFMediaViewRendering];
            }
        }
        [self.adapter setCustomMediaview:self.mediaView];
        [self.adapter startViewabilityCheck];
    }
}

@end
