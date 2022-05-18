//
//  Banner6002.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/10/08.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "Banner6002.h"

@interface Banner6002() <AdColonyAdViewDelegate>

@property (nonatomic) NSString *adColonyAppId;
@property (nonatomic) NSString *adShowZoneId;
@property (nonatomic) BOOL test_flg;

@property (nonatomic, weak) AdColonyAdView *banner;

@end

@implementation Banner6002

+ (NSString *)getSDKVersion {
    return AdColony.getSDKVersion;
}

+ (NSString *)getAdapterRevisionVersion {
    return @"4";
}

- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"AdColonyAdView");
    if (clazz) {
    } else {
        AdapterLog(@"Not found Class: AdColonyAdView");
        return NO;
    }
    return YES;
}

- (void)dispose {
    [super dispose];
    if (self.banner) {
        [self.banner destroy];
        self.banner = nil;
    }
}

// getinfoから取得したデータを内部変数に保存する
- (void)setData:(NSDictionary *)data {
    [super setData:data];

    NSString *adColonyAppId = [data objectForKey:@"app_id"];
    if ([self isNotNull:adColonyAppId]) {
        self.adColonyAppId = [NSString stringWithFormat:@"%@", adColonyAppId];
    }
    NSString *adShowZoneId = [data objectForKey:@"zone_id"];
    if ([self isNotNull:adShowZoneId]) {
        self.adShowZoneId = [NSString stringWithFormat:@"%@", adShowZoneId];
    }
    
    if (ADFMovieOptions.getTestMode) {
        self.test_flg = YES;
    } else {
        NSNumber *testFlg = [data objectForKey:@"test_flg"];
        if ([self isNotNull:testFlg] && [testFlg isKindOfClass:[NSNumber class]]) {
            self.test_flg = [testFlg boolValue];
        }
    }
}

// SDKの初期化ロジックを入れる。ただし、Instance化を毎回する必要がある場合にはこちらではなくてstartAdで行うこと
-(void)initAdnetworkIfNeeded {
    if (![self needsToInit]) {
        return;
    }
    @try {
        AdColonyAppOptions *options = [AdColonyAppOptions new];
        options.testMode = self.test_flg;
        if (self.hasGdprConsent != nil) {
            NSString *consent =  self.hasGdprConsent.boolValue ? @"1" : @"0";
            [options setPrivacyFrameworkOfType:ADC_GDPR isRequired:YES];
            [options setPrivacyConsentString:consent forType:ADC_GDPR];
            AdapterLogP(@"Adnetwork 6002, gdprConsent : %@, sdk setting value : %@", self.hasGdprConsent, consent);
        }
        [self requireToAsyncInit];
        [AdColony configureWithAppID:self.adColonyAppId options:options completion:^(NSArray<AdColonyZone *> * _Nonnull zones) {
            [self initCompleteAndRetryStartAdIfNeeded];
        }];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
    
    self.adSize = kAdColonyAdSizeBanner;
}

- (void)clearStatusIfNeeded {

}

- (BOOL)isPrepared {
    return self.isAdLoaded;
}

// SDKのLoading関数を呼び出す
- (void)startAd {
    if (![self canStartAd]) {
        return;
    }
    
    [super startAd];

    self.isAdLoaded = false;
    
    UIViewController *vc = [self topMostViewController];
    if (vc && self.adShowZoneId) {
        @try {
            [self requireToAsyncRequestAd];
            [AdColony requestAdViewInZone:self.adShowZoneId
                                 withSize:self.adSize
                           viewController:vc
                              andDelegate:self];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    }
}

- (void)startAdWithOption:(NSDictionary *)option {
    [self startAd];
}

#pragma mark - AdColony AdView Delegate

// handle new banner
- (void)adColonyAdViewDidLoad:(AdColonyAdView *)adView {
    AdapterTrace;
    self.isAdLoaded = true;
    NativeAdInfo6002 *info = [[NativeAdInfo6002 alloc] initWithVideoUrl:nil
                                                                  title:@""
                                                            description:@""
                                                           adnetworkKey:@"6002"];
    info.mediaType = ADFNativeAdType_Image;
    info.adapter = self;
    [info setupMediaView:adView];
    self.adInfo = info;

    [self setCustomMediaview:adView];

    if (self.banner) {
        [self.banner destroy];
    }
    self.banner = adView;

    [self setCallbackStatus:NativeAdCallbackLoadFinish];
}

// handler banner loading failure
- (void)adColonyAdViewDidFailToLoad:(AdColonyAdRequestError *)error {
    NSString *message = [NSString stringWithFormat:@"error: %@ and suggestion: %@",error.localizedDescription, error.localizedRecoverySuggestion];
    AdapterTraceP(@"adColonyAdViewDidFailToLoad with %@", message);
    [self setErrorWithMessage:message code:error.code];
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

- (void)adColonyAdViewWillOpen:(AdColonyAdView *)adView {
    AdapterTrace;
}

- (void)adColonyAdViewDidClose:(AdColonyAdView *)adView {
    AdapterTrace;
}

- (void)adColonyAdViewWillLeaveApplication:(AdColonyAdView *)adView {
    AdapterTrace;
}

- (void)adColonyAdViewDidReceiveClick:(AdColonyAdView *)adView {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackClick];
}

@end

@implementation NativeAdInfo6002

- (void)playMediaView {
    if (self.adapter) {
        [self.adapter setCallbackStatus:NativeAdCallbackRendering];
        [self.adapter startViewabilityCheck];
    }
}

@end
