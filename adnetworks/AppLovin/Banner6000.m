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
@property (nonatomic)BOOL impFlag;
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
    NSString *data_sdkKey = [data objectForKey:@"sdk_key"];
    if (data_sdkKey && ![data_sdkKey isEqual:[NSNull null]]) {
        self.appLovinSdkKey = [NSString stringWithFormat:@"%@", data_sdkKey];
    }
    NSString *data_zoneID = [data objectForKey:@"zone_id"];
    if (data_zoneID && ![data_zoneID isEqual:[NSNull null]]) {
        self.zoneIdentifier = [NSString stringWithFormat:@"%@", data_zoneID];
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
    if (!self.adView) {
        self.adView = [[ALAdView alloc] initWithSdk:[ALSdk sharedWithKey:self.appLovinSdkKey]
                                               size:ALAdSize.banner
                                     zoneIdentifier:self.zoneIdentifier];
        self.adView.adLoadDelegate = self;
        self.adView.adDisplayDelegate = self;
    }
}

- (void)startAd {
    self.isAdLoaded = NO;
    self.impFlag = YES;
    if (self.adView) {
        [self.adView loadNextAd];
    }
}

-(void)setHasUserConsent:(BOOL)hasUserConsent {
    [super setHasUserConsent:hasUserConsent];
    [ALPrivacySettings setHasUserConsent:hasUserConsent];
}

#pragma mark - Ad Load Delegate

- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad {
    self.isAdLoaded = YES;
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadFinish:)]) {
            NativeAdInfo6000 *info = [[NativeAdInfo6000 alloc] initWithVideoUrl:nil
                                                                          title:@""
                                                                    description:@""
                                                                   adnetworkKey:@"6000"];
            info.adapter = self;
            [info setupMediaView:self.adView];
            self.adInfo = info;
        } else {
            NSLog(@"%s onNativeMovieAdLoadFinish selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code {
    self.isAdLoaded = NO;
    NSLog(@"AppLovin Banner load error :%d", code);
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadError:)]) {
            if (code) {
                [self setErrorWithMessage:nil code:code];
            }
            [self.delegate onNativeMovieAdLoadError:self];
        } else {
            NSLog(@"Banner6001: selector onNativeMovieAdLoadError is not responding");
        }
    } else {
        NSLog(@"Banner6001: delegate is not set");
    }
}

#pragma mark - Ad Display Delegate

- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view {
    NSLog(@"%s", __FUNCTION__);
    if (self.impFlag == NO) {
        return;
    }
    self.impFlag = NO;

    [self setCustomMediaview:view];
    [self startViewabilityCheck];

    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewRendering)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewRendering];
        } else {
            NSLog(@"MovieNative6016: %s onADFMediaViewRendering selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"MovieNative6016: %s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view {
    NSLog(@"%s", __FUNCTION__);
}

- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view {
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

@end

@implementation NativeAdInfo6000

@end
