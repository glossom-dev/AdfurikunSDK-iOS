//
//  Banner6017.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2021/01/14.
//  Copyright © 2021 Glossom, Inc. All rights reserved.
//

#import "Banner6017.h"
#import "MovieReward6017.h"
#import "AdnetworkParam6017.h"

@interface Banner6017()<PAGBannerAdDelegate>

@property (nonatomic) PAGBannerAd *bannerAd;
@property (nonatomic) BOOL didInvokeImpression;
@property (nonatomic) AdnetworkParam6017 *adParam;

@end

@implementation Banner6017

+ (NSString *)getSDKVersion {
    return PAGSdk.SDKVersion;
}

+ (NSString *)getAdapterRevisionVersion {
    return @"9";
}

+ (NSString *)adnetworkClassName {
    return @"PAGBannerAd";
}

- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6017 alloc] initWithParam:data];
}

-(void)initAdnetworkIfNeeded {
    if (![self needsToInit]) {
        return;
    }
    if (!self.adParam || ![self.adParam isValid]) {
        return;
    }
    
    AdapterLog(@"Banner6017 initAdnetworkIfNeeded");
    @try {
        [self requireToAsyncInit];
        
        [MovieConfigure6017.sharedInstance configureWithAppId:self.adParam.appID
                                                   gdprStatus:self.hasGdprConsent
                                                childDirected:self.childDirected
                                                 appLogoImage:nil
                                                   completion:^{
            [self initCompleteAndRetryStartAdIfNeeded];
        }];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
    
    self.adSize = kPAGBannerSize320x50;
}

- (void)clearStatusIfNeeded {
}

- (BOOL)isPrepared {
    return self.isAdLoaded;
}

- (void)startAd {
    AdapterTrace;
    if (![self canStartAd]) {
        return;
    }
    if (!self.adParam || ![self.adParam isValid]) {
        return;
    }
    
    UIViewController *topMostVC = [self topMostViewController];
    if (topMostVC == nil) {
        AdapterLog(@"TopMostViewController is nil");
        return;
    }
    
    [super startAd];
    
    if (self.bannerAd) {
        self.bannerAd = nil;
    }
    
    @try {
        [self requireToAsyncRequestAd];
        
        PAGBannerRequest *request = [PAGBannerRequest requestWithBannerSize:self.adSize];
        
        [PAGBannerAd loadAdWithSlotID:self.adParam.slotID
                              request:request
                    completionHandler:^(PAGBannerAd * _Nullable bannerAd, NSError * _Nullable error) {
            if (error) {
                [self setErrorWithMessage:error.localizedDescription code:error.code];
                [self setCallbackStatus:NativeAdCallbackLoadError];
                return;
            } else if (bannerAd == nil) {
                NSString *errorMsg = @"bannerAd is nil";
                AdapterTraceP(@"error : %@", errorMsg);
                [self setErrorWithMessage:errorMsg code:0];
                [self setCallbackStatus:NativeAdCallbackLoadError];
                return;
            }
            [self loadProcess:bannerAd];
        }];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (void)startAdWithOption:(NSDictionary *)option {
    [self startAd];
}

- (void)loadProcess:(PAGBannerAd *)bannerAd {
    self.bannerAd = bannerAd;
    self.bannerAd.delegate = self;
    self.bannerAd.rootViewController = [self topMostViewController];
    
    NativeAdInfo6017 *info = [[NativeAdInfo6017 alloc] initWithVideoUrl:nil
                                                                  title:@""
                                                            description:@""
                                                           adnetworkKey:@"6017"];
    info.mediaType = ADFNativeAdType_Image;
    [info setupMediaView:self.bannerAd.bannerView];
    [self setCustomMediaview:self.bannerAd.bannerView];

    info.adapter = self;
    info.isCustomComponentSupported = false;
    self.adInfo = info;
    self.didInvokeImpression = false;
    
    [self setCallbackStatus:NativeAdCallbackLoadFinish];
}

#pragma mark PAGBannerAdDelegate

- (void)adDidShow:(PAGBannerAd *)ad {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackRendering];
    [self startViewabilityCheck];
}

- (void)adDidClick:(PAGBannerAd *)ad {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackClick];
}

- (void)adDidDismiss:(PAGBannerAd *)ad {
    AdapterTrace;
}

@end

@implementation NativeAdInfo6017

@end

@implementation Banner6090
@end

@implementation Banner6091
@end

@implementation Banner6092
@end

@implementation Banner6093
@end

@implementation Banner6094
@end
