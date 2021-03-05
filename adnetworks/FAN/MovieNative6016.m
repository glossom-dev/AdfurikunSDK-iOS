//
//  MovieNative6016.m
//  MovieRewardSampleDev
//
//  Created by Amin Al on 2018/09/10.
//  Copyright © 2018 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
#import "MovieNative6016.h"
#import "Rectangle6016.h"

#define kFANNativeAdPlacementTypeNative 1
#define kFANNativeAdPlacementTypeNativeBanner 2

@interface MovieNative6016()<FBNativeAdDelegate, FBMediaViewDelegate, FBNativeBannerAdDelegate>
@property (nonatomic, strong) NSString *placement_id;
@property (nonatomic, assign) int banner_type;
@property (nonatomic) BOOL test_flg;
@property (nonatomic, strong) FBNativeAd *nativeAd;
@property (nonatomic, strong) FBNativeBannerAd *nativeBannerAd;
@end

@implementation MovieNative6016

+ (NSString *)getAdapterRevisionVersion {
    return @"1";
}

- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"FBNativeAd");
    if (clazz) {
    } else {
        NSLog(@"MovieNative6016: Not found Class: FBNativeAd");
        return NO;
    }
    clazz = NSClassFromString(@"FBNativeBannerAd");
    if (clazz) {
    } else {
        NSLog(@"Rectangle6016: Not found Class: FBNativeBannerAd");
        return NO;
    }
    return YES;
}

- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    NSString *placementId = [data objectForKey:@"placement_id"];
    if ([self isNotNull:placementId]) {
        self.placement_id = [NSString stringWithFormat:@"%@", placementId];
    }

    self.banner_type = kFANNativeAdPlacementTypeNative;
    NSNumber *type = [data objectForKey:@"banner_type"];
    if ([self isNotNull:type] && ([type isKindOfClass:[NSNumber class]] || [type isKindOfClass:[NSString class]])) {
        if (type.intValue == kFANNativeAdPlacementTypeNative || type.intValue == kFANNativeAdPlacementTypeNativeBanner) {
            self.banner_type = type.intValue;
        }
    }
}

- (void)initAdnetworkIfNeeded {
    static dispatch_once_t adfFANOnceToken;
    dispatch_once(&adfFANOnceToken, ^{
        @try {
            if (self.test_flg) {
                [FBAdSettings addTestDevice:[FBAdSettings testDeviceHash]];
            } else {
                [FBAdSettings clearTestDevices];
            }
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    });
}

- (void)startAd {
    if (self.placement_id) {
        [super startAd];
        
        @try {
            if (_banner_type == kFANNativeAdPlacementTypeNative) {
                FBNativeAd *nativeAd = [[FBNativeAd alloc] initWithPlacementID: self.placement_id];
                nativeAd.delegate = self;
                [nativeAd loadAd];
            } else if (_banner_type == kFANNativeAdPlacementTypeNativeBanner) {
                FBNativeBannerAd *nativeBannerAd = [[FBNativeBannerAd alloc] initWithPlacementID:self.placement_id];
                nativeBannerAd.delegate = self;
                [nativeBannerAd loadAd];
            }
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    }
}

- (BOOL)isPrepared {
    if (_banner_type == kFANNativeAdPlacementTypeNative) {
        return self.nativeAd && [self.nativeAd isAdValid] && self.isAdLoaded;
    } else if (_banner_type == kFANNativeAdPlacementTypeNativeBanner) {
        return self.nativeBannerAd && [self.nativeBannerAd isAdValid] && self.isAdLoaded;
    }
    return NO;
}

-(void)findMediaViewRecursive:(UIView*)uiView {
    for (UIView *view in uiView.subviews) {
        NSString *className = NSStringFromClass(view.class);
        if ([className isEqualToString:@"FBMediaView"]) {
            FBMediaView *v = (FBMediaView *)view;
            v.delegate = self;
        }
    }
}

- (void)sendOnNativeMovieAdLoadFinish {
    NSLog(@"FAN sendOnNativeMovieAdLoadFinish");
    [self setCallbackStatus:NativeAdCallbackLoadFinish];
}

- (void)sendOnNativeMovieAdLoadError:(NSError *)error {
    NSLog(@"FAN NativeAd load error :\n%@", error);
    if (error) {
        [self setErrorWithMessage:error.localizedDescription code:error.code];
    }
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

- (void)sendOnADFMediaViewClick {
    [self setCallbackStatus:NativeAdCallbackClick];
}

- (void)sendOnADFMediaViewPlayStart {
    if (self.adInfo.mediaType == ADFNativeAdType_Movie) {
        [self setCallbackStatus:NativeAdCallbackPlayStart];
    } else {
        [self startViewabilityCheck];
        [self setCallbackStatus:NativeAdCallbackRendering];
    }
}

#pragma mark - FBNativeAdDelegate delegates
- (void)nativeAdDidLoad:(FBNativeAd *)nativeAd {
    NSLog(@"MovieNative6016: NativeAd Loaded");
    if (self.nativeAd) {
        [self.nativeAd unregisterView];
        self.nativeAd = nil;
    }
    if (nativeAd && nativeAd.isAdValid) {
        self.nativeAd = nativeAd;
        MovieNativeAdInfo6016 *info = [[MovieNativeAdInfo6016 alloc] initWithVideoUrl:nil
                                                                                title:nativeAd.advertiserName
                                                                          description:nativeAd.bodyText
                                                                         adnetworkKey:@"6016"];
        if (nativeAd.adFormatType == FBAdFormatTypeImage) {
            info.mediaType = ADFNativeAdType_Image;
        } else if (nativeAd.adFormatType == FBAdFormatTypeVideo) {
            info.mediaType = ADFNativeAdType_Movie;
        }

        FBNativeAdViewAttributes *attributes = [[FBNativeAdViewAttributes alloc] init];
        attributes.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        attributes.buttonColor = [UIColor colorWithRed:66/255.0 green:108/255.0 blue:173/255.0 alpha:1];
        attributes.buttonTitleColor = [UIColor whiteColor];
        attributes.titleColor = [UIColor blackColor];
        attributes.descriptionColor = [UIColor blackColor];

        FBNativeAdView *adView = [FBNativeAdView nativeAdViewWithNativeAd: nativeAd
                                                                 withType: FBNativeAdViewTypeGenericHeight300
                                                           withAttributes: attributes];
        //delegateがFBAdGenericHeight300Viewに変わったのでselfに戻す。
        nativeAd.delegate = self;

        for (UIView *view in adView.subviews) {
            [self findMediaViewRecursive: view];
        }

        [info setupMediaView: adView];

        //---creating fan components for user assembly]
        info.isCustomComponentSupported = YES;
        info.nativeAd = nativeAd;

        info.fbAdTitleLabel = [[UILabel alloc] init];
        info.fbAdTitleLabel.text = nativeAd.advertiserName;

        info.fbAdBodyLabel = [[UILabel alloc] init];
        [info.fbAdBodyLabel setText: nativeAd.bodyText];

        info.fbSocialContextLabel = [[UILabel alloc] init];
        [info.fbSocialContextLabel setText: nativeAd.socialContext];

        info.fbCallToActionButton = [[UIButton alloc] init];
        [info.fbCallToActionButton setTitle: nativeAd.callToAction forState: UIControlStateNormal];

        info.fbAdChoicesView = [[FBAdChoicesView alloc] init];
        info.fbAdChoicesView.nativeAd = nativeAd;
        
        info.fbAdSponsoredLabel = [[UILabel alloc] init];
        info.fbAdSponsoredLabel.text = nativeAd.sponsoredTranslation;

        info.fbMediaView = [[FBMediaView alloc] init];
        info.fbMediaView.delegate = self;

        info.fbAdIconView = [[FBMediaView alloc] init];
        //-------------------------------------------------

        info.adapter = self;
        [info setCustomMediaView:adView];
        self.adInfo = info;
        self.isAdLoaded = true;
        [self sendOnNativeMovieAdLoadFinish];
    } else {
        [self sendOnNativeMovieAdLoadError:nil];
    }
}

- (void)nativeAdDidClick:(FBNativeAd *)nativeAd {
    NSLog(@"%s", __func__);
    NSLog(@"MovieNative6016: NativeAdDidClick");
    [self sendOnADFMediaViewClick];
}

- (void)nativeAdWillLogImpression:(FBNativeAd *)nativeAd {
    NSLog(@"MovieNative6016: NativeAd will log impression");
    [self sendOnADFMediaViewPlayStart];
}

- (void)nativeAd:(FBNativeAd *)nativeAd didFailWithError:(NSError *)error {
    [self sendOnNativeMovieAdLoadError:error];
}

#pragma mark - FBNativeBannerAdDelegate delegates

- (void)nativeBannerAdDidLoad:(FBNativeBannerAd *)nativeBannerAd {
    NSLog(@"Rectangle6016: NativeBannerAd Loaded");
    if (self.nativeBannerAd) {
        [self.nativeBannerAd unregisterView];
        self.nativeBannerAd = nil;
    }
    if (nativeBannerAd && nativeBannerAd.isAdValid) {
        self.nativeBannerAd = nativeBannerAd;
        RectangleAdInfo6016 *info = [[RectangleAdInfo6016 alloc] initWithVideoUrl:nil
                                                                            title:nativeBannerAd.advertiserName
                                                                      description:nativeBannerAd.bodyText
                                                                     adnetworkKey:@"6016"];
        if (nativeBannerAd.adFormatType == FBAdFormatTypeImage) {
            info.mediaType = ADFNativeAdType_Image;
        } else if (nativeBannerAd.adFormatType == FBAdFormatTypeVideo) {
            info.mediaType = ADFNativeAdType_Movie;
        }

        FBNativeAdViewAttributes *attributes = [[FBNativeAdViewAttributes alloc] init];
        attributes.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        attributes.buttonColor = [UIColor colorWithRed:66/255.0 green:108/255.0 blue:173/255.0 alpha:1];
        attributes.buttonTitleColor = [UIColor whiteColor];
        attributes.titleColor = [UIColor blackColor];
        attributes.descriptionColor = [UIColor blackColor];
        FBNativeBannerAdView *adView = [FBNativeBannerAdView nativeBannerAdViewWithNativeBannerAd:nativeBannerAd         withType:FBNativeBannerAdViewTypeGenericHeight100 withAttributes:attributes];
        //    //nativeBannerAd.delegateがFBAdGenericHeight100Viewに変わったのでselfに戻す。
        nativeBannerAd.delegate = self;
        [info setupMediaView:adView];

        //---creating fan components for user assembly]
        info.isCustomComponentSupported = YES;
        info.nativeBannerAd = nativeBannerAd;

        info.fbAdIconView = [[FBMediaView alloc] init];

        info.fbAdChoicesView = [[FBAdChoicesView alloc] init];
        info.fbAdChoicesView.nativeAd = nativeBannerAd;

        info.fbAdAdvertiserNameLabel = [[UILabel alloc] init];
        info.fbAdAdvertiserNameLabel.text = nativeBannerAd.advertiserName;

        info.fbAdSponsoredLabel = [[UILabel alloc] init];
        info.fbAdSponsoredLabel.text = nativeBannerAd.sponsoredTranslation;

        info.fbCallToActionButton = [[UIButton alloc] init];
        [info.fbCallToActionButton setTitle:nativeBannerAd.callToAction forState:UIControlStateNormal];

        info.adapter = self;
        [info setCustomMediaView:adView];
        self.adInfo = info;
        self.isAdLoaded = true;
        [self sendOnNativeMovieAdLoadFinish];
    } else {
        [self sendOnNativeMovieAdLoadError:nil];
    }
}

- (void)nativeBannerAd:(FBNativeBannerAd *)nativeBannerAd didFailWithError:(NSError *)error {
    [self sendOnNativeMovieAdLoadError:error];
}

- (void)nativeBannerAdDidClick:(FBNativeBannerAd *)nativeBannerAd {
    NSLog(@"%s", __func__);
    NSLog(@"Rectangle6016: RectangleDidClick");
    [self sendOnADFMediaViewClick];
}

- (void)nativeBannerAdDidFinishHandlingClick:(FBNativeBannerAd *)nativeBannerAd {
    NSLog(@"%s", __func__);
}

- (void)nativeBannerAdWillLogImpression:(FBNativeBannerAd *)nativeBannerAd {
    NSLog(@"Rectangle6016: RectangleAd will log impression");
    [self sendOnADFMediaViewPlayStart];
}

#pragma mark - FBMediaViewDelegate delegates

- (void)mediaViewDidLoad:(FBMediaView *)mediaView {
    NSLog(@"MovieNative6016: Media View did load");
    NSLog(@"%s", __func__);

}

- (void)mediaViewVideoDidPlay:(FBMediaView *)mediaView {
    NSLog(@"MovieNative6016: MediaView play");
}

- (void)mediaViewVideoDidPause:(FBMediaView *)mediaView {
    NSLog(@"MovieNative6016: MediaView pause");
}

- (void)mediaViewVideoDidComplete:(FBMediaView *)mediaView {
    NSLog(@"MovieNative6016: MediaView finished playing");

    [self setCallbackStatus:NativeAdCallbackPlayFinish];
}

@end

@implementation MovieNativeAdInfo6016
- (void)playMediaView {
    NSLog(@"%s", __func__);
}

- (void)registerInteractionViews:(NSArray<__kindof UIView *> *)views {
    if (self.adapter) {
        [self registerViewForInteraction:[self.adapter topMostViewController].view
                          viewController:[self.adapter topMostViewController]
                          clickableViews:views];
    }
}

- (void)registerViewForInteraction:(UIView *)view viewController:(UIViewController *)viewController clickableViews:(NSArray<UIView *> *)clickableViews {
    if (self.nativeAd) {
        [self.nativeAd registerViewForInteraction:view
                                        mediaView:self.fbMediaView
                                         iconView:self.fbAdIconView
                                   viewController:viewController
                                   clickableViews:clickableViews];
    } else if (self.nativeBannerAd) {
        [self.nativeBannerAd registerViewForInteraction:view
                                               iconView:self.fbAdIconView
                                         viewController:viewController
                                         clickableViews:clickableViews];
    }
}

- (NSDictionary *)getCustomNativeAdComponents {
    if (self.nativeAd) {
        return @{
                 @"adInfo": self.nativeAd,
                 @"adTitleLabel": self.fbAdTitleLabel,
                 @"adMediaView": self.fbMediaView,
                 @"adIconView": self.fbAdIconView,
                 @"adChoicesView": self.fbAdChoicesView,
                 @"adCallToActionButton": self.fbCallToActionButton,
                 @"adSocialContextLabel": self.fbSocialContextLabel,
                 @"adSponsoredLabel": self.fbAdSponsoredLabel,
                 @"adBodyLabel": self.fbAdBodyLabel };
    } else if (self.nativeBannerAd) {
        return @{
                 @"adInfo": self.nativeBannerAd,
                 @"adIconView": self.fbAdIconView,
                 @"adChoicesView": self.fbAdChoicesView,
                 @"adAdvertiserNameLabel": self.fbAdAdvertiserNameLabel,
                 @"adSponsoredLabel": self.fbAdSponsoredLabel,
                 @"adCallToActionButton": self.fbCallToActionButton };
    }
    return nil;
}

- (void)updateAdChoicesFrame {
    [self.fbAdChoicesView updateFrameFromSuperview:UIRectCornerTopLeft];
}

@end

@implementation MovieNative6040

@end

@implementation MovieNative6041

@end
