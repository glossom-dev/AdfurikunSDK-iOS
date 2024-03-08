//
//  Banner6006.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/10/13.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "Banner6006.h"
#import "AdnetworkParam6006.h"

@interface Banner6006()

@property (nonatomic) AdnetworkParam6006 *param;

@property (nonatomic, strong) VungleBanner *bannerAd;
@property (nonatomic) UIView *adView;

@end

@implementation Banner6006

+ (NSString *)getSDKVersion {
    return [VungleAds sdkVersion];
}

+ (NSString *)getAdapterRevisionVersion {
    return @"9";
}

+ (NSString *)adnetworkClassName {
    return @"VungleAdsSDK.VungleBanner";
}

+ (NSString *)adnetworkName {
    return @"Vungle";
}

- (void)setHasUserConsent:(BOOL)hasUserConsent {
    [super setHasUserConsent:hasUserConsent];
    
    [VunglePrivacySettings setGDPRStatus:hasUserConsent];
    AdapterLogP(@"Adnetwork 6006, gdprConsent : %@, sdk setting value : %d", self.hasGdprConsent, (int)(hasUserConsent));
}

- (void)isChildDirected:(BOOL)childDirected {
    [super isChildDirected:childDirected];
    
    [VunglePrivacySettings setCOPPAStatus:childDirected];
    AdapterLogP(@"Adnetwork 6006, childDirected : %@, sdk setting value : %d", self.childDirected, (int)(childDirected));
}

// getinfoから取得したデータを内部変数に保存する
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.param = [[AdnetworkParam6006 alloc] initWithParam:data];
}

- (void)initAdnetworkIfNeeded {
    if (![self.param isValid]) {
        return;
    }
    
    if ([VungleAds isInitialized]) {
        [self initCompleteAndRetryStartAdIfNeeded];
        return;
    }
    
    [VungleAds setDebugLoggingEnabled:[ADFMovieOptions getTestMode]];
    
    self.bannerSize = BannerSizeRegular;
    
    @try {
        [VungleAds initWithAppId:self.param.vungleAppID completion:^(NSError * _Nullable error){
            if (!error) {
                [self initCompleteAndRetryStartAdIfNeeded];
            }
        }];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (BOOL)isPrepared {
    if (!self.param || ![self.param isValid]) {
        return NO;
    }
    return self.isAdLoaded;
}

// SDKのLoading関数を呼び出す
- (void)startAd {
    if (![self canStartAd]) {
        return;
    }
    
    if (![self.param isValid]) {
        return;
    }
    
    [super startAd];
    
    @try {
        if (self.bannerAd) {
            self.bannerAd.delegate = nil;
            self.bannerAd = nil;
        }
        
        [self requireToAsyncRequestAd];
        
        self.bannerAd = [[VungleBanner alloc] initWithPlacementId:self.param.placementID size:self.bannerSize];
        self.bannerAd.delegate = self;
        [self.bannerAd load:nil];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (void)startAdWithOption:(NSDictionary *)option {
    [self startAd];
}

-(void)destroyAdViewIfNeeded {
    AdapterTrace;
    if (self.adView) {
        for (id subview in self.adView.subviews) {
          [subview removeFromSuperview];
        }
        [self.adView removeFromSuperview];
        self.adView = nil;
    }
    
}

- (void)dispose {
    [super dispose];
    
    [self destroyAdViewIfNeeded];
    
    if (self.bannerAd) {
        self.bannerAd.delegate = nil;
        self.bannerAd = nil;
    }
}

#pragma mark - VungleBanner Delegate Methods
// Ad load Events
- (void)bannerAdDidLoad:(VungleBanner *)banner {
    AdapterTrace;
    CGRect viewSize = CGRectMake(0.0, 0.0, 300.0, 250.0);
    if (self.bannerSize == BannerSizeRegular) {
        viewSize = CGRectMake(0.0, 0.0, 320.0, 50.0);
    }
    
    [self destroyAdViewIfNeeded];
    
    self.adView = [[UIView alloc] initWithFrame:viewSize];
    [self.bannerAd presentOn:self.adView];
    AdapterLog(@"vungle 6006 addAdViewToView complete");
    NativeAdInfo6006 *info = [[NativeAdInfo6006 alloc] initWithVideoUrl:nil
                                                                  title:@""
                                                            description:@""
                                                           adnetworkKey:@"6006"];
    info.mediaType = ADFNativeAdType_Image;
    info.adapter = self;
    [info setupMediaView:self.adView];
    self.adInfo = info;
    
    [self setCustomMediaview:self.adView];
    
    [self setCallbackStatus:NativeAdCallbackLoadFinish];
}

- (void)bannerAdDidFailToLoad:(VungleBanner *)banner
                    withError:(NSError *)withError {
    AdapterTraceP(@"error : %@", withError);
    [self setLastError:withError];
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

// Ad Lifecycle Events
- (void)bannerAdWillPresent:(VungleBanner *)banner {
    AdapterTrace;
}

- (void)bannerAdDidPresent:(VungleBanner *)banner {
    AdapterTrace;
}

- (void)bannerAdDidFailToPresent:(VungleBanner *)banner
                       withError:(NSError *)withError {
    AdapterTraceP(@"error : %@", withError);
    [self setLastError:withError];
    [self setCallbackStatus:NativeAdCallbackPlayFail];
}

- (void)bannerAdDidTrackImpression:(VungleBanner *)banner {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackPlayStart];
}

- (void)bannerAdDidClick:(VungleBanner *)banner {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackClick];
}

- (void)bannerAdWillLeaveApplication:(VungleBanner *)banner {
    AdapterTrace;
}

- (void)bannerAdWillClose:(VungleBanner *)banner {
    AdapterTrace;
}

- (void)bannerAdDidClose:(VungleBanner *)banner {
    AdapterTrace;
}

@end

@implementation NativeAdInfo6006

- (void)playMediaView {
    if (self.adapter) {
        [self.adapter setCallbackStatus:NativeAdCallbackRendering];
    }
}

@end
