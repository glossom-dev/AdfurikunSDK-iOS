//
//  Banner6019.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/02/10.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "Banner6019.h"

#import <ADFMovieReward/ADFMovieOptions.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@implementation Banner6019

- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    NSString* admobId = [data objectForKey:@"ad_unit_id"];
    if ([self isNotNull:admobId]) {
        self.unitID = [[NSString alloc] initWithFormat:@"%@", admobId];
    }
    NSNumber *testFlg = [data objectForKey:@"test_flg"];
    if ([self isNotNull:testFlg] && [testFlg isKindOfClass:[NSNumber class]]) {
        self.testFlg = [testFlg boolValue];
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

- (void)initAdnetworkIfNeeded {
    if (self.testFlg) {
        // GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[@"コンソールに出力されたデバイスIDを入力してください。"];
        //詳細　https://developers.google.com/admob/ios/test-ads?hl=ja
    }
    self.adSize = kGADAdSizeBanner;
}

- (void)startAd {
    [self startAdWithOption:nil];
}

- (void)startAdWithOption:(NSDictionary *)option {
    NSLog(@"%s called", __func__);
    [super startAd];

    self.isAdLoaded = false;

    if (self.unitID == nil) {
        return;
    }

    if (self.bannerView) {
        [self.bannerView removeFromSuperview];
        self.bannerView = nil;
    }
    @try {
        self.bannerView = [[GADBannerView alloc] initWithAdSize:self.adSize];
        self.bannerView.adUnitID = self.unitID;
        self.bannerView.rootViewController = [self topMostViewController];
        self.bannerView.delegate = self;
        
        GADRequest *request = [GADRequest new];
        if (option) {
            NSLog(@"custom event option : %@", option);
            NSString *label = option[@"label"];
            if (label) {
                GADCustomEventExtras *extras = [[GADCustomEventExtras alloc] init];
                [extras setExtras:option forLabel:label];
                [request registerAdNetworkExtras:extras];
            }
            [self.bannerView loadRequest:request];
        }
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"GADBannerView");
    if (clazz) {
        NSLog(@"Found Class: GADBannerView");
    } else {
        NSLog(@"Not found Class: GADBannerView");
        return NO;
    }
    return YES;
}

- (void)callbackClick {
    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewClick)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewClick];
        } else {
            NSLog(@"Banner6019: %s onADFMediaViewClick selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"Banner6019: %s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

- (void)dealloc {
    if (self.bannerView) {
        [self.bannerView removeFromSuperview];
        self.bannerView = nil;
    }
}

#pragma mark - GADBannerViewDelegate

/// Tells the delegate an ad request loaded an ad.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"%s called", __func__);
    if (self.isAdLoaded) {
        return;
    }
    
    self.isAdLoaded = true;
    MovieNativeAdInfo6019 *info = [[MovieNativeAdInfo6019 alloc] initWithVideoUrl:nil
                                                                            title:@""
                                                                      description:@""
                                                                     adnetworkKey:@"6019"];
    info.mediaType = ADFNativeAdType_Image;
    info.adapter = self;
    [info setupMediaView:adView];
    self.adInfo = info;

    [self setCustomMediaview:adView];

    if (self.delegate) {
        if ([self.delegate respondsToSelector: @selector(onNativeMovieAdLoadFinish:)]) {
            [self.delegate onNativeMovieAdLoadFinish:self.adInfo];
        } else {
            NSLog(@"Banner6019: %s onNativeMovieAdLoadFinish selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"Banner6019: %s Delegate is not setting", __FUNCTION__);
    }
}

/// Tells the delegate an ad request failed.
- (void)adView:(GADBannerView *)adView didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"%s error: %@", __FUNCTION__, error);
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadError:)]) {
            if (error) {
                [self setErrorWithMessage:error.localizedDescription code:error.code];
            }
            [self.delegate onNativeMovieAdLoadError: self];
        } else {
            NSLog(@"Banner6019: selector onNativeMovieAdLoadError is not responding");
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

/// Tells the delegate that a full-screen view will be presented in response
/// to the user clicking on an ad.
- (void)adViewWillPresentScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillPresentScreen");
    [self callbackClick];
}

/// Tells the delegate that the full-screen view will be dismissed.
- (void)adViewWillDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewWillDismissScreen");
}

/// Tells the delegate that the full-screen view has been dismissed.
- (void)adViewDidDismissScreen:(GADBannerView *)adView {
    NSLog(@"adViewDidDismissScreen");
}

/// Tells the delegate that a user click will open another app (such as
/// the App Store), backgrounding the current app.
- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
    NSLog(@"adViewWillLeaveApplication");
    [self callbackClick];
}

@end

@implementation Banner6060

@end
