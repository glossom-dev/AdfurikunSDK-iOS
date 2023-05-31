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
    return @"10";
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
    self.adSize = GADAdSizeBanner;
}

- (void)startAd {
    [self startAdWithOption:nil];
}

- (void)startAdWithOption:(NSDictionary *)option {
    AdapterTrace;
    if (![self canStartAd]) {
        return;
    }

    [super startAd];

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
            AdapterLogP(@"custom event option : %@", option);
            NSString *label = option[@"label"];
            if (label) {
                GADCustomEventExtras *extras = [[GADCustomEventExtras alloc] init];
                [extras setExtras:option forLabel:label];
                [request registerAdNetworkExtras:extras];
            }
        }
        if (self.hasGdprConsent) {
            GADExtras *extras = [[GADExtras alloc] init];
            extras.additionalParameters = @{@"npa": self.hasGdprConsent.boolValue ? @"1" : @"0"};
            [request registerAdNetworkExtras:extras];
            AdapterLogP(@"[ADF] Adnetwork 6019, gdprConsent : %@, sdk setting value : %@", self.hasGdprConsent, extras.additionalParameters);
        }
        [self requireToAsyncRequestAd];
        [self.bannerView loadRequest:request];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"GADBannerView");
    if (clazz) {
        AdapterLog(@"Found Class: GADBannerView");
    } else {
        AdapterLog(@"Not Found Class: GADBannerView");
        return NO;
    }
    return YES;
}

- (void)isChildDirected:(BOOL)childDirected {
    [super isChildDirected:childDirected];
    [GADMobileAds.sharedInstance.requestConfiguration tagForChildDirectedTreatment:childDirected];
    AdapterLogP(@"Adnetwork %@, childDirected : %@, input parameter : %d", self.adnetworkKey, self.childDirected, (int)childDirected);
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
    AdapterTrace;
    if (self.isBannerViewLoaded) {
        return;
    }
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
    AdapterTraceP(@"error: %@", error);
    if (error) {
        [self setErrorWithMessage:error.localizedDescription code:error.code];
    }
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
    AdapterTrace;
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {
    AdapterTrace;
}

- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {
    AdapterTrace;
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {
    AdapterTrace;
}

- (void)bannerViewDidRecordClick:(GADBannerView *)bannerView {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackClick];
}

@end

@implementation BannerAdInfo6019

- (void)playMediaView {
    if (self.adapter) {
        [self.adapter setCallbackStatus:NativeAdCallbackRendering];
        [self.adapter startViewabilityCheck];
    }
}

@end

@implementation Banner6160
@end

@implementation Banner6161
@end

@implementation Banner6162
@end

@implementation Banner6163
@end

@implementation Banner6164
@end

@implementation Banner6060
@end
