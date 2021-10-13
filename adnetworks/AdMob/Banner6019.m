//
//  Banner6019.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/02/10.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "Banner6019.h"
#import <WebKit/WebKit.h>

#import <ADFMovieReward/ADFMovieOptions.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@implementation Banner6019

+ (NSString *)getAdapterRevisionVersion {
    return @"5";
}

- (void)setData:(NSDictionary *)data {
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    [super setData:data];
    
    NSString* admobId = [data objectForKey:@"ad_unit_id"];
    if ([self isNotNull:admobId]) {
        self.unitID = [[NSString alloc] initWithFormat:@"%@", admobId];
    }
    NSNumber *testFlg = [data objectForKey:@"test_flg"];
    if ([self isNotNull:testFlg] && [testFlg isKindOfClass:[NSNumber class]]) {
        self.testFlg = [testFlg boolValue];
    }
}

- (void)initAdnetworkIfNeeded {
    if (self.testFlg) {
        // GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[@"コンソールに出力されたデバイスIDを入力してください。"];
        //詳細　https://developers.google.com/admob/ios/test-ads?hl=ja
    }
    [self initCompleteAndRetryStartAdIfNeeded];
    self.adSize = kGADAdSizeBanner;
}

- (void)startAd {
    [self startAdWithOption:nil];
}

- (void)startAdWithOption:(NSDictionary *)option {
    NSLog(@"%s called", __func__);
    if (![self canStartAd]) {
        return;
    }

    [super startAd];

    self.isAdLoaded = false;
    self.isBannerViewLoaded = false;
    
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
        
        GADRequest *request = [GADRequest request];
        if (option) {
            NSLog(@"custom event option : %@", option);
            NSString *label = option[@"label"];
            if (label) {
                GADCustomEventExtras *extras = [[GADCustomEventExtras alloc] init];
                [extras setExtras:option forLabel:label];
                [request registerAdNetworkExtras:extras];
            }
        }
        [self.bannerView loadRequest:request];
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
    [self setCallbackStatus:NativeAdCallbackClick];
}

- (void)dealloc {
    if (self.bannerView) {
        [self.bannerView removeFromSuperview];
        self.bannerView = nil;
    }
}

#pragma mark - GADBannerViewDelegate

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"%s called", __func__);
    if (self.isBannerViewLoaded) {
        return;
    }
    self.isAdLoaded = true;
    self.isBannerViewLoaded = true;
    
    BannerAdInfo6019 *info = [[BannerAdInfo6019 alloc] initWithVideoUrl:nil
                                                                  title:@""
                                                            description:@""
                                                           adnetworkKey:@"6019"];
    info.mediaType = ADFNativeAdType_Image;
    info.adapter = self;
    [info setupMediaView:self.bannerView];
    self.adInfo = info;

    [self setCustomMediaview:self.bannerView];
    
    [self setCallbackStatus:NativeAdCallbackLoadFinish];
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"%s error: %@", __FUNCTION__, error);
    if (error) {
        [self setErrorWithMessage:error.localizedDescription code:error.code];
    }
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
    NSLog(@"%s called", __func__);
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {
    NSLog(@"%s called", __func__);
}

- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {
    NSLog(@"%s called", __func__);
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {
    NSLog(@"%s called", __func__);
}

- (void)bannerViewDidRecordClick:(GADBannerView *)bannerView {
    NSLog(@"%s called", __func__);
    [self setCallbackStatus:NativeAdCallbackClick];
}

@end

@implementation Banner6060

@end

@implementation BannerAdInfo6019

- (void)playMediaView {
    if (self.adapter) {
        [self.adapter setCallbackStatus:NativeAdCallbackRendering];
        [self.adapter startViewabilityCheck];
    }
}

@end
