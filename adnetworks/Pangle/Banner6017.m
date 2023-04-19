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

@interface Banner6017()<BUNativeExpressBannerViewDelegate>

@property (nonatomic) BUNativeExpressBannerView *adView;
@property (nonatomic) BOOL didInvokeImpression;
@property (nonatomic) AdnetworkParam6017 *adParam;

@end

@implementation Banner6017

+ (NSString *)getSDKVersion {
    return BUAdSDKManager.SDKVersion;
}

+ (NSString *)getAdapterRevisionVersion {
    return @"5";
}

- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"BUNativeExpressBannerView");
    if (clazz) {
    } else {
        AdapterLog(@"Not found Class: BUNativeExpressBannerView");
        return NO;
    }
    return YES;
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
        
        [MovieConfigure6017.sharedInstance configureWithAppId:self.adParam.appID gdprStatus:self.hasGdprConsent completion:^{
            [self initCompleteAndRetryStartAdIfNeeded];
        }];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
    
    self.adSize = CGSizeMake(320.0, 50.0);
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
    
    if (self.adView) {
        self.adView = nil;
    }
    
    @try {
        [self requireToAsyncRequestAd];
        
        self.adView = [[BUNativeExpressBannerView alloc] initWithSlotID:self.adParam.slotID
                                                     rootViewController:topMostVC
                                                                 adSize:self.adSize];
        self.adView.frame = CGRectMake(0.0, 0.0, self.adSize.width, self.adSize.height);
        self.adView.delegate = self;
        [self.adView loadAdData];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (void)startAdWithOption:(NSDictionary *)option {
    [self startAd];
}

- (void)nativeExpressBannerAdViewDidLoad:(BUNativeExpressBannerView *)bannerAdView {
    AdapterTrace;
    for (UIView *subview in bannerAdView.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"BUNativeExpressAdView")]) {
            [subview setTranslatesAutoresizingMaskIntoConstraints:false];
            [bannerAdView addConstraints:@[
                [NSLayoutConstraint constraintWithItem:subview
                                             attribute:NSLayoutAttributeCenterX
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:bannerAdView
                                             attribute:NSLayoutAttributeCenterX
                                            multiplier:1.0
                                              constant:0.0],
                [NSLayoutConstraint constraintWithItem:subview
                                             attribute:NSLayoutAttributeCenterY
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:bannerAdView
                                             attribute:NSLayoutAttributeCenterY
                                            multiplier:1.0
                                              constant:0.0],
                [NSLayoutConstraint constraintWithItem:subview
                                             attribute:NSLayoutAttributeWidth
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:nil
                                             attribute:NSLayoutAttributeWidth
                                            multiplier:1.0
                                              constant:self.adSize.width],
                [NSLayoutConstraint constraintWithItem:subview
                                             attribute:NSLayoutAttributeHeight
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:nil
                                             attribute:NSLayoutAttributeHeight
                                            multiplier:1.0
                                              constant:self.adSize.height],
            ]];
            break;
        }
    }

    NativeAdInfo6017 *info = [[NativeAdInfo6017 alloc] initWithVideoUrl:nil
                                                                  title:@""
                                                            description:@""
                                                           adnetworkKey:@"6017"];
    info.mediaType = ADFNativeAdType_Image;
    [info setupMediaView:self.adView];
    [self setCustomMediaview:self.adView];
    
    info.adapter = self;
    info.isCustomComponentSupported = false;
    self.adInfo = info;
    self.didInvokeImpression = false;
    
    [self setCallbackStatus:NativeAdCallbackLoadFinish];
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView didLoadFailWithError:(NSError *)error {
    AdapterTraceP(@"error : %@", error);
    if (error) {
        [self setErrorWithMessage:error.localizedDescription code:error.code];
    }
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

- (void)nativeExpressBannerAdViewRenderSuccess:(BUNativeExpressBannerView *)bannerAdView {
    AdapterTrace;
}

- (void)nativeExpressBannerAdViewRenderFail:(BUNativeExpressBannerView *)bannerAdView error:(NSError *)error {
    AdapterTraceP(@"error : %@", error);
    if (error) {
        [self setErrorWithMessage:error.localizedDescription code:error.code];
    }
    [self setCallbackStatus:NativeAdCallbackPlayFail];
}

- (void)nativeExpressBannerAdViewWillBecomVisible:(BUNativeExpressBannerView *)bannerAdView {
    AdapterTrace;
    if (!self.didInvokeImpression) {
        [self setCallbackStatus:NativeAdCallbackRendering];
        [self startViewabilityCheck];
        self.didInvokeImpression = true;
    }
}

- (void)nativeExpressBannerAdViewDidClick:(BUNativeExpressBannerView *)bannerAdView {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackClick];
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView dislikeWithReason:(NSArray<BUDislikeWords *> *)filterwords {
    AdapterTrace;
}

- (void)nativeExpressBannerAdViewDidCloseOtherController:(BUNativeExpressBannerView *)bannerAdView interactionType:(BUInteractionType)interactionType {
    AdapterTrace;
}

@end

@implementation NativeAdInfo6017

@end
