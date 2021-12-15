//
//  Banner6017.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2021/01/14.
//  Copyright © 2021 Glossom, Inc. All rights reserved.
//

#import "Banner6017.h"
#import "MovieReward6017.h"

@interface Banner6017()<BUNativeExpressBannerViewDelegate>

@property (nonatomic) NSString *pangleAppID;
@property (nonatomic) NSString *pangleSlotID;
@property (nonatomic) BUNativeExpressBannerView *adView;
@property (nonatomic) BOOL didInvokeImpression;
@end

@implementation Banner6017

+ (NSString *)getSDKVersion {
    return BUAdSDKManager.SDKVersion;
}

+ (NSString *)getAdapterRevisionVersion {
    return @"4";
}

- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"BUNativeExpressBannerView");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: BUNativeExpressBannerView");
        return NO;
    }
    return YES;
}

- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    NSString *appID = [data objectForKey:@"appid"];
    if ([self isNotNull:appID]) {
        self.pangleAppID = [NSString stringWithFormat:@"%@", appID];
    }
    NSString *slotID = [data objectForKey:@"ad_slot_id"];
    if ([self isNotNull:slotID]) {
        self.pangleSlotID = [NSString stringWithFormat:@"%@", slotID];
    }
}

-(void)initAdnetworkIfNeeded {
    if (![self needsToInit]) {
        return;
    }

    NSLog(@"Banner6017 initAdnetworkIfNeeded");
    if (self.pangleAppID) {
        NSLog(@"%s", __FUNCTION__);
        @try {
            [self requireToAsyncInit];
            
            [MovieConfigure6017.sharedInstance configureWithAppId:self.pangleAppID completion:^{
                [self initCompleteAndRetryStartAdIfNeeded];
            }];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    }

    self.adSize = CGSizeMake(320.0, 50.0);
}

- (void)clearStatusIfNeeded {
}

- (BOOL)isPrepared {
    return self.isAdLoaded;
}

- (void)startAd {
    NSLog(@"%s called", __FUNCTION__);
    if (![self canStartAd]) {
        return;
    }

    if (self.pangleSlotID == nil) {
        return;
    }
    
    UIViewController *topMostVC = [self topMostViewController];
    if (topMostVC == nil) {
        NSLog(@"%s TopMostViewController is nil", __FUNCTION__);
        return;
    }
    
    [super startAd];
    
    if (self.adView) {
        self.adView = nil;
    }
    
    self.isAdLoaded = false;
    
    @try {
        [self requireToAsyncRequestAd];
        
        self.adView = [[BUNativeExpressBannerView alloc] initWithSlotID:self.pangleSlotID
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
    NSLog(@"%s called", __FUNCTION__);
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
    self.isAdLoaded = true;
    self.didInvokeImpression = false;
    
    [self setCallbackStatus:NativeAdCallbackLoadFinish];
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView didLoadFailWithError:(NSError *)error {
    NSLog(@"%s called, error : %@", __FUNCTION__, error);
    if (error) {
        [self setErrorWithMessage:error.localizedDescription code:error.code];
    }
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

- (void)nativeExpressBannerAdViewRenderSuccess:(BUNativeExpressBannerView *)bannerAdView {
    NSLog(@"%s called", __FUNCTION__);
}

- (void)nativeExpressBannerAdViewRenderFail:(BUNativeExpressBannerView *)bannerAdView error:(NSError *)error {
    NSLog(@"%s called, error : %@", __FUNCTION__, error);
    if (error) {
        [self setErrorWithMessage:error.localizedDescription code:error.code];
    }
    [self setCallbackStatus:NativeAdCallbackPlayFail];
}

- (void)nativeExpressBannerAdViewWillBecomVisible:(BUNativeExpressBannerView *)bannerAdView {
    NSLog(@"%s called", __FUNCTION__);
    if (!self.didInvokeImpression) {
        [self setCallbackStatus:NativeAdCallbackRendering];
        [self startViewabilityCheck];
        self.didInvokeImpression = true;
    }
}

- (void)nativeExpressBannerAdViewDidClick:(BUNativeExpressBannerView *)bannerAdView {
    NSLog(@"%s called", __FUNCTION__);
    [self setCallbackStatus:NativeAdCallbackClick];
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView dislikeWithReason:(NSArray<BUDislikeWords *> *)filterwords {
    NSLog(@"%s called", __FUNCTION__);
}

- (void)nativeExpressBannerAdViewDidCloseOtherController:(BUNativeExpressBannerView *)bannerAdView interactionType:(BUInteractionType)interactionType {
    NSLog(@"%s called", __FUNCTION__);
}

@end

@implementation NativeAdInfo6017

@end
