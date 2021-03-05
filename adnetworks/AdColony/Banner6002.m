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
@property (nonatomic) NSArray *allZones;
@property (nonatomic) BOOL test_flg;

@property (nonatomic, weak) AdColonyAdView *banner;

@end

@implementation Banner6002

+ (NSString *)getSDKVersion {
    return AdColony.getSDKVersion;
}

+ (NSString *)getAdapterRevisionVersion {
    return @"1";
}

- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"AdColonyAdView");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: AdColonyAdView");
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
    
    NSArray *colonyAllZones = [data objectForKey:@"all_zones"];
    if ([self isNotNull:colonyAllZones] && [colonyAllZones isKindOfClass:[NSArray class]]) {
        self.allZones = [NSArray arrayWithArray:colonyAllZones];
    }
    
    if (colonyAllZones == nil && self.adShowZoneId != nil) {
        self.allZones = @[self.adShowZoneId];
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
    static dispatch_once_t adfAdColonyOnceToken;
    dispatch_once(&adfAdColonyOnceToken, ^{
        @try {
            AdColonyAppOptions *options = nil;
            if (self.hasGdprConsent != nil) {
                options = [AdColonyAppOptions new];
                options.testMode = self.test_flg;
            }
            [AdColony configureWithAppID:self.adColonyAppId zoneIDs:self.allZones options:options completion:^(NSArray<AdColonyZone *> * _Nonnull zones) {
                [self initCompleteAndRetryStartAdIfNeeded];
            }];
        } @catch (NSException *exception) {
            NSLog(@"adcolony configuration exception %@", exception);
        }
    });
    
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
    NSLog(@"adColonyAdViewDidFailToLoad with %@", message);
    [self setErrorWithMessage:message code:error.code];
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

- (void)adColonyAdViewWillOpen:(AdColonyAdView *)adView {
    NSLog(@"AdView will open fullscreen view");
}

- (void)adColonyAdViewDidClose:(AdColonyAdView *)adView {
    NSLog(@"AdView did close fullscreen views");
}

- (void)adColonyAdViewWillLeaveApplication:(AdColonyAdView *)adView {
    NSLog(@"AdView will send used outside the app");
}

- (void)adColonyAdViewDidReceiveClick:(AdColonyAdView *)adView {
    NSLog(@"AdView received a click");
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
