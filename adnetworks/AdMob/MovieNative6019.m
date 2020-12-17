//
//  MovieNative6019.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/02/10.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "MovieNative6019.h"

#import <ADFMovieReward/ADFMovieOptions.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface MovieNative6019 ()<GADUnifiedNativeAdLoaderDelegate, GADUnifiedNativeAdDelegate, GADVideoControllerDelegate>

@property (nonatomic, nullable) NSString *unitID;
@property (nonatomic) GADAdLoader *adLoader;
@property (nonatomic) BOOL testFlg;
@property (nonatomic) BOOL sendPlayCallback;
@property (nonatomic) BOOL sendFinishCallback;

@end

@implementation MovieNative6019

- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    NSString* admobId = [data objectForKey:@"ad_unit_id"];
    if ([self isNotNull:admobId]) {
        self.unitID = [[NSString alloc] initWithFormat:@"%@", admobId];
    }
    NSNumber *testFlg = [data objectForKey:@"test_flg"];
    if ([self isNotNull:testFlg] && [testFlg isKindOfClass:[NSNumber class]]) {
        self.testFlg = [testFlg boolValue];
    }

    NSNumber *pixelRateNumber = data[@"pixelRate"];
    if ([self isNotNull:pixelRateNumber] && [pixelRateNumber isKindOfClass:[NSNumber class]]) {
        self.viewabilityPixelRate = pixelRateNumber.intValue;
    }
    NSNumber *displayTimeNumber = data[@"displayTime"];
    if ([self isNotNull:displayTimeNumber] && [displayTimeNumber isKindOfClass:[NSNumber class]]) {
        self.viewabilityDisplayTime = displayTimeNumber.intValue;
    }
    NSNumber *timerIntervalNumber = data[@"timerInterval"];
    if ([self isNotNull:timerIntervalNumber] && [timerIntervalNumber isKindOfClass:[NSNumber class]]) {
        self.viewabilityTimerInterval = timerIntervalNumber.intValue;
    }
}

- (void)initAdnetworkIfNeeded {
    @try {
        if (self.testFlg) {
            // GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[@"コンソールに出力されたデバイスIDを入力してください。"];
            //詳細　https://developers.google.com/admob/ios/test-ads?hl=ja
        }
        if (self.adLoader == nil && self.unitID != nil) {
            self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:self.unitID
                                               rootViewController:nil
                                                          adTypes:@[kGADAdLoaderAdTypeUnifiedNative]
                                                          options:nil];
            self.adLoader.delegate = self;
        }
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (void)startAd {
    [self startAdWithOption:nil];
}

- (void)startAdWithOption:(NSDictionary *)option {
    if (self.adLoader == nil) {
        return;
    }

    [super startAd];

    self.isAdLoaded = false;
    @try {
        [self.adLoader loadRequest:[GADRequest request]];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"GADAdLoader");
    if (clazz) {
        NSLog(@"Found Class: GADAdLoader");
    } else {
        NSLog(@"Not found Class: GADAdLoader");
        return NO;
    }
    return YES;
}

- (void)callbackRender {
    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewRendering)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewRendering];
        } else {
            NSLog(@"MovieNative6019: %s onADFMediaViewRendering selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"MovieNative6019: %s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

- (void)callbackImpression {
    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewPlayStart)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewPlayStart];
        } else {
            NSLog(@"MovieNative6019: %s onADFMediaViewPlayStart selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"MovieNative6019: %s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

- (void)callbackFinish {
    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewPlayFinish)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewPlayFinish];
        } else {
            NSLog(@"MovieNative6019: %s onADFMediaViewPlayFinish selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"MovieNative6019: %s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

- (void)callbackClick {
    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewClick)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewClick];
        } else {
            NSLog(@"MovieNative6019: %s onADFMediaViewClick selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"MovieNative6019: %s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

- (void)dealloc {
}

#pragma mark - GADUnifiedNativeAdLoaderDelegate

- (void)adLoader:(nonnull GADAdLoader *)adLoader didReceiveUnifiedNativeAd:(nonnull GADUnifiedNativeAd *)nativeAd {
    NSLog(@"%s called", __func__);
    self.isAdLoaded = true;
    self.sendPlayCallback = false;
    self.sendFinishCallback = false;

    MovieNativeAdView6019 *nativeAdView = [[MovieNativeAdView6019 alloc] initWithFrame:CGRectZero];
    nativeAd.mediaContent.videoController.delegate = self;
    nativeAd.delegate = self;
    [nativeAdView setupAdView:nativeAd];

    MovieNativeAdInfo6019 *info = [[MovieNativeAdInfo6019 alloc] initWithVideoUrl:nil
                                                                            title:@""
                                                                      description:@""
                                                                     adnetworkKey:@"6019"];


    info.mediaType = [nativeAdView isVideoContents] ? ADFNativeAdType_Movie : ADFNativeAdType_Image;
    info.isCustomComponentSupported = true;
    info.adapter = self;
    info.nativeAdView = nativeAdView;
    [info setupMediaView:nativeAdView];
    self.adInfo = info;

    [self setCustomMediaview:nativeAdView];

    if (self.delegate) {
        if ([self.delegate respondsToSelector: @selector(onNativeMovieAdLoadFinish:)]) {
            [self.delegate onNativeMovieAdLoadFinish:self.adInfo];
        } else {
            NSLog(@"MovieNative6019: %s onNativeMovieAdLoadFinish selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"MovieNative6019: %s Delegate is not setting", __FUNCTION__);
    }
}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"%s error: %@", __FUNCTION__, error);
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadError:)]) {
            if (error) {
                [self setErrorWithMessage:error.localizedDescription code:error.code];
            }
            [self.delegate onNativeMovieAdLoadError: self];
        } else {
            NSLog(@"MovieNative6019: selector onNativeMovieAdLoadError is not responding");
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

#pragma mark - GADVideoControllerDelegate

/// Tells the delegate that the video controller has began or resumed playing a video.
- (void)videoControllerDidPlayVideo:(nonnull GADVideoController *)videoController {
    NSLog(@"%s called", __func__);
    if (self.sendPlayCallback == false) {
        self.sendPlayCallback = true;
        [self callbackImpression];
    }
}

/// Tells the delegate that the video controller has paused video.
- (void)videoControllerDidPauseVideo:(nonnull GADVideoController *)videoController {
    NSLog(@"%s called", __func__);
}

/// Tells the delegate that the video controller's video playback has ended.
- (void)videoControllerDidEndVideoPlayback:(nonnull GADVideoController *)videoController {
    NSLog(@"%s called", __func__);
    if (self.sendFinishCallback == false) {
        self.sendFinishCallback = true;
        [self callbackFinish];
    }
}

/// Tells the delegate that the video controller has muted video.
- (void)videoControllerDidMuteVideo:(nonnull GADVideoController *)videoController {
    NSLog(@"%s called", __func__);
}

/// Tells the delegate that the video controller has unmuted video.
- (void)videoControllerDidUnmuteVideo:(nonnull GADVideoController *)videoController {
    NSLog(@"%s called", __func__);
}


#pragma mark - GADUnifiedNativeAdDelegate

- (void)nativeAdDidRecordImpression:(GADUnifiedNativeAd *)nativeAd {
    NSLog(@"%s called", __func__);
    if (self.adInfo.mediaType == ADFNativeAdType_Image) {
        [self callbackRender];
    }
}

- (void)nativeAdDidRecordClick:(GADUnifiedNativeAd *)nativeAd {
  // The native ad was clicked on.
    NSLog(@"%s called", __func__);
    [self callbackClick];
}

- (void)nativeAdWillPresentScreen:(GADUnifiedNativeAd *)nativeAd {
  // The native ad will present a full screen view.
    NSLog(@"%s called", __func__);
}

- (void)nativeAdWillDismissScreen:(GADUnifiedNativeAd *)nativeAd {
  // The native ad will dismiss a full screen view.
    NSLog(@"%s called", __func__);
}

- (void)nativeAdDidDismissScreen:(GADUnifiedNativeAd *)nativeAd {
  // The native ad did dismiss a full screen view.
    NSLog(@"%s called", __func__);
}

- (void)nativeAdWillLeaveApplication:(GADUnifiedNativeAd *)nativeAd {
  // The native ad will cause the application to become inactive and
  // open a new application.
    NSLog(@"%s called", __func__);
}

@end

#pragma mark MovieNativeAdView6019

@interface MovieNativeAdView6019()

@property (weak, nonatomic) IBOutlet UIView *_view;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *headlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *advertisedLabel;
@property (weak, nonatomic) IBOutlet UIView *adMediaView;
@property (weak, nonatomic) IBOutlet UILabel *callToActionLabel;

@end


@implementation MovieNativeAdView6019

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self makeSubviews];
    }
    return self;
}

- (void)makeSubviews {
    NSArray <UIView *>*result = [[UINib nibWithNibName:@"MovieNativeAdView6019" bundle:nil] instantiateWithOwner:self options:nil];
    UIView *_view = result.firstObject;
    [self viewSetted:_view];
}

- (void)viewSetted:(UIView *)_view {
    _view.frame = self.bounds;
    [self addSubview:_view];
    _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)setupAdView:(GADUnifiedNativeAd *)nativeAd {
    self.nativeAd = nativeAd;

    GADMediaView *tempMediaView = [[GADMediaView alloc] initWithFrame:self.adMediaView.bounds];
    tempMediaView.mediaContent = nativeAd.mediaContent;
    tempMediaView.contentMode = UIViewContentModeScaleAspectFit;
    [self.adMediaView addSubview:tempMediaView];
    [tempMediaView setTranslatesAutoresizingMaskIntoConstraints: false];
    [self.adMediaView addConstraints:@[
        [NSLayoutConstraint constraintWithItem:tempMediaView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.adMediaView
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:tempMediaView
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.adMediaView
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:tempMediaView
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.adMediaView
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1.0
                                      constant:0.0],
        [NSLayoutConstraint constraintWithItem:tempMediaView
                                     attribute:NSLayoutAttributeRight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.adMediaView
                                     attribute:NSLayoutAttributeRight
                                    multiplier:1.0
                                      constant:0.0],

    ]];
    self.mediaView = tempMediaView;

    self.headlineLabel.text = nativeAd.headline;
    self.headlineView = self.headlineLabel;

    self.callToActionLabel.text = nativeAd.callToAction;
    self.callToActionView = self.callToActionLabel;

    if (nativeAd.icon.image) {
        self.iconImageView.image = nativeAd.icon.image;
        self.iconView = self.iconImageView;
    }
    self.advertisedLabel.text = nativeAd.advertiser;
    
    [self.nativeAd registerAdView:self
              clickableAssetViews:@{
                  GADUnifiedNativeHeadlineAsset: self.headlineLabel,
                  GADUnifiedNativeCallToActionAsset: self.callToActionLabel,
                  GADUnifiedNativeIconAsset: self.iconImageView}
           nonclickableAssetViews:@{}
     ];
}

- (BOOL)isVideoContents {
    if (self.mediaView.mediaContent) {
        return self.mediaView.mediaContent.hasVideoContent;
    }
    return false;
}

@end

@interface MovieNativeAdInfo6019()

@property (nonatomic) BOOL isCustomNativeAdComponents;

@end

@implementation MovieNativeAdInfo6019

- (void)playMediaView {
    if (self.adapter && self.nativeAdView.isVideoContents == false) {
        // UI組立方式では静止画のImpression Callbackが来ないため、PlayMediaViewが呼ばれるタイミングでRender Eventを発生させる
        if (self.isCustomNativeAdComponents && self.mediaView.adapterInnerDelegate) {
            if ([self.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewRendering)]) {
                [self.mediaView.adapterInnerDelegate onADFMediaViewRendering];
            }
        }

        [self.adapter startViewabilityCheck];
    }
}

- (NSDictionary *)getCustomNativeAdComponents {
    if (self.nativeAdView && self.nativeAdView.nativeAd) {
        GADUnifiedNativeAd *nativeAd = self.nativeAdView.nativeAd;
        NSMutableDictionary *result = [NSMutableDictionary new];
        result[@"adInfo"] = nativeAd;

        GADMediaView *mediaView = [[GADMediaView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 180.0)];
        mediaView.mediaContent = nativeAd.mediaContent;
        mediaView.contentMode = UIViewContentModeScaleAspectFit;
        result[@"adMediaView"] = mediaView;

        if (nativeAd.headline) {
            result[@"adTitle"] = nativeAd.headline;
        }
        if (nativeAd.icon && nativeAd.icon.image) {
            result[@"adIcon"] = nativeAd.icon.image;
        }
        if (nativeAd.callToAction) {
            result[@"adCallToAction"] = nativeAd.callToAction;
        }
        if (nativeAd.advertiser) {
            result[@"adSponsored"] = nativeAd.advertiser;
        }
        if (nativeAd.body) {
            result[@"adBody"] = nativeAd.body;
        }
        self.isCustomNativeAdComponents = true;
        return result;
    }
    return nil;
}

- (GADUnifiedNativeAdView *)createGADUnifiedNativeAdView:(NSDictionary *)parts {
    GADUnifiedNativeAdView *view = [GADUnifiedNativeAdView new];
    view.nativeAd = self.nativeAdView.nativeAd;
    view.bodyView = parts[@"body"];
    view.advertiserView = parts[@"advertiser"];
    view.callToActionView = parts[@"callToAction"];
    view.mediaView = parts[@"media"];
    [view.nativeAd registerAdView:view
              clickableAssetViews:@{
                  GADUnifiedNativeCallToActionAsset: view.callToActionView,
                          GADUnifiedNativeBodyAsset: view.bodyView,
                     GADUnifiedNativeMediaViewAsset: view.mediaView,
                    GADUnifiedNativeAdvertiserAsset: view.advertiserView
              }
           nonclickableAssetViews:@{}];
    return view;
}

@end

@implementation MovieNative6060

@end
