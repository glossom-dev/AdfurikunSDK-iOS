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
    self.placement_id = [NSString stringWithFormat:@"%@", [data objectForKey:@"placement_id"]];
    self.banner_type = kFANNativeAdPlacementTypeNative;
    NSNumber *type = [data objectForKey:@"banner_type"];
    if (type) {
        self.banner_type = type.intValue;
    }

    NSNumber *pixelRateNumber = data[@"pixelRate"];
    if (pixelRateNumber && ![[NSNull null] isEqual:pixelRateNumber]) {
        self.viewabilityPixelRate = pixelRateNumber.intValue;
    }
    NSNumber *displayTimeNumber = data[@"displayTime"];
    if (displayTimeNumber && ![[NSNull null] isEqual:displayTimeNumber]) {
        self.viewabilityDisplayTime = displayTimeNumber.intValue;
    }
    NSNumber *timerIntervalNumber = data[@"timerInterval"];
    if (timerIntervalNumber && ![[NSNull null] isEqual:timerIntervalNumber]) {
        self.viewabilityTimerInterval = timerIntervalNumber.intValue;
    }
}

- (void)initAdnetworkIfNeeded {
    static dispatch_once_t adfAdColonyOnceToken;
    dispatch_once(&adfAdColonyOnceToken, ^{
        if (self.test_flg) {
            [FBAdSettings addTestDevice:[FBAdSettings testDeviceHash]];
        } else {
            [FBAdSettings clearTestDevices];
        }
    });
}

- (void)startAd {
    if (_banner_type == kFANNativeAdPlacementTypeNative) {
        FBNativeAd *nativeAd = [[FBNativeAd alloc] initWithPlacementID: self.placement_id];
        nativeAd.delegate = self;
        [nativeAd loadAd];
    } else if (_banner_type == kFANNativeAdPlacementTypeNativeBanner) {
        FBNativeBannerAd *nativeBannerAd = [[FBNativeBannerAd alloc] initWithPlacementID:self.placement_id];
        nativeBannerAd.delegate = self;
        [nativeBannerAd loadAd];
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
    if (self.delegate) {
        if ([self.delegate respondsToSelector: @selector(onNativeMovieAdLoadFinish:)]) {
            [self.delegate onNativeMovieAdLoadFinish: self.adInfo];
        } else {
            NSLog(@"MovieNative6016: %s onNativeMovieAdLoadFinish selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"MovieNative6016: %s Delegate is not setting", __FUNCTION__);
    }
}

- (void)sendOnNativeMovieAdLoadError:(NSError *)error {
    NSLog(@"FAN NativeAd load error :\n%@", error);
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadError:)]) {
            if (error) {
                [self setErrorWithMessage:error.localizedDescription code:error.code];
            }
            [self.delegate onNativeMovieAdLoadError: self];
        } else {
            NSLog(@"MovieNative6016: selector onNativeMovieAdLoadError is not responding");
        }
    } else {
        NSLog(@"MovieNative6016: delegate is not set");
    }
}

- (void)sendOnADFMediaViewClick {
    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewClick)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewClick];
        } else {
            NSLog(@"MovieNative6016: %s onADFMediaViewClick selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"MovieNative6016: %s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

- (void)sendOnADFMediaViewPlayStart {
    [self startViewabilityCheck];

    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewRendering)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewRendering];
        } else {
            NSLog(@"MovieNative6016: %s onADFMediaViewRendering selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"MovieNative6016: %s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
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

        info.fbMediaView = [[FBMediaView alloc] init];
        info.fbMediaView.delegate = self;

        info.fbAdIconView = [[FBAdIconView alloc] init];
        //-------------------------------------------------

        info.adapter = self;
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

        info.fbAdIconView = [[FBAdIconView alloc] init];

        info.fbAdChoicesView = [[FBAdChoicesView alloc] init];
        info.fbAdChoicesView.nativeAd = nativeBannerAd;

        info.fbAdAdvertiserNameLabel = [[UILabel alloc] init];
        info.fbAdAdvertiserNameLabel.text = nativeBannerAd.advertiserName;

        info.fbAdSponsoredLabel = [[UILabel alloc] init];
        info.fbAdSponsoredLabel.text = nativeBannerAd.sponsoredTranslation;

        info.fbCallToActionButton = [[UIButton alloc] init];
        [info.fbCallToActionButton setTitle:nativeBannerAd.callToAction forState:UIControlStateNormal];

        info.adapter = self;
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

    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewPlayFinish)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewPlayFinish];
        } else {
            NSLog(@"MovieNative6016: %s onADFMediaViewPlayFinish selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"MovieNative6016: %s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

@end

@implementation MovieNativeAdInfo6016
- (void)playMediaView {
    NSLog(@"%s", __func__);
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

@end
