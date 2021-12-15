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

+ (NSString *)getSDKVersion {
    return ALSdk.version;
}

+ (NSString *)getAdapterRevisionVersion {
    return @"3";
}

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
        [self initCompleteAndRetryStartAdIfNeeded];
    }
}

- (void)startAd {
    if (![self canStartAd]) {
        return;
    }

    [super startAd];
    
    self.isAdLoaded = NO;
    if (self.adView) {
        @try {
            [self requireToAsyncRequestAd];
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
            
            [self setCallbackStatus:NativeAdCallbackLoadFinish];
            
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
    if (code) {
        [self setErrorWithMessage:nil code:code];
    }
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

#pragma mark - Ad Display Delegate

- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view {
    NSLog(@"%s", __FUNCTION__);
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view {
    NSLog(@"%s", __FUNCTION__);
}

- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view {
    [self setCallbackStatus:NativeAdCallbackClick];
}

@end

@implementation NativeAdInfo6000

- (void)playMediaView {
    if (self.adapter) {
        [self.adapter setCallbackStatus:NativeAdCallbackRendering];
        [self.adapter setCustomMediaview:self.mediaView];
        [self.adapter startViewabilityCheck];
    }
}

@end
