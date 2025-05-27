//
//  MovieNative6019.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/02/10.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "MovieNative6019.h"
#import "AdnetworkConfigure6019.h"
#import "AdnetworkParam6019.h"

#import <GoogleMobileAds/GoogleMobileAds.h>

@interface MovieNative6019 ()<GADNativeAdLoaderDelegate, GADNativeAdDelegate, GADVideoControllerDelegate>

@property (nonatomic) GADAdLoader *adLoader;

@end

@implementation MovieNative6019

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"12";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"GADAdLoader";
}

// ADFで定義しているAdnetwork名。
+ (NSString *)adnetworkName {
    return [AdnetworkConfigure6019 adnetworkName];
}

// Instance Variableを初期化する。また、必要な場合Configureを生成する
-(id)init {
    self = [super init];
    if (self) {
        self.configure = [AdnetworkConfigure6019 sharedInstance];
    }
    return self;
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6019 alloc] initWithParam:data];
    self.configure.param = self.adParam; // Parameterを設定する
}

// Adnetwork SDKを初期化する
- (bool)initAdnetworkIfNeeded {
    if (![super initAdnetworkIfNeeded]) { // 初期化済みかParameterが設定されてないとそのままReturnする
        return false;
    }
    
    // SDK初期化はConfigureを使う
    __weak typeof(self) weakSelf = self;
    [self.configure initAdnetworkSDKWithCompletionHander:^(_Bool result) {
        // 初期化完了後の実装が必要な場合こちらに追加する
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        [strongSelf initCompleteAndRetryStartAdIfNeeded];
    }];
    return true;
}

// 広告読み込みを開始する
- (bool)startAd {
    return [self startAdWithOption:nil];
}

- (bool)startAdWithOption:(NSDictionary *)option {
    if (![super startAd]) { // 読み込みが可能な状態かをチェックする
        return false;
    }
    
    @try {
        [self requireToAsyncRequestAd];
        
        if (self.adLoader == nil) {
            GADNativeAdViewAdOptions *adViewOptions = [[GADNativeAdViewAdOptions alloc] init];
            if (option && option[@"adChoices_placement"]) {
                AdapterLogP(@"custom event option : %@", option);
                ((AdnetworkParam6019 *)self.adParam).adChoicesPlacement = option[@"adChoices_placement"];
            }
            NSString *placement = ((AdnetworkParam6019 *)self.adParam).adChoicesPlacement;
            if ([self isNotNull:placement]) {
                if ([placement isEqualToString:@"top_right"]) {
                    adViewOptions.preferredAdChoicesPosition = GADAdChoicesPositionTopRightCorner;
                } else if ([placement isEqualToString:@"top_left"]) {
                    adViewOptions.preferredAdChoicesPosition = GADAdChoicesPositionTopLeftCorner;
                } else if ([placement isEqualToString:@"bottom_right"]) {
                    adViewOptions.preferredAdChoicesPosition = GADAdChoicesPositionBottomRightCorner;
                } else if ([placement isEqualToString:@"bottom_left"]) {
                    adViewOptions.preferredAdChoicesPosition = GADAdChoicesPositionBottomLeftCorner;
                }
            }
            //AdMobのDefaultは右上
            self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:((AdnetworkParam6019 *)self.adParam).unitID
                                               rootViewController:nil
                                                          adTypes:@[GADAdLoaderAdTypeNative]
                                                          options:@[adViewOptions]];
            self.adLoader.delegate = self;
        }
        [self requireToAsyncRequestAd];
        GADRequest *request = [GADRequest request];
        [(AdnetworkConfigure6019 *)self.configure setHasGdprConsent:self.hasGdprConsent request:request];
        [self.adLoader loadRequest:request];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
    return true;
}

// 在庫取得有無を返す
- (BOOL)isPrepared {
    return self.isAdLoaded;
}

// 後処理を実装
- (void)dispose {
    [super dispose];
}

- (void)callbackRender {
    [self setCallbackStatus:NativeAdCallbackRendering];
}

- (void)callbackImpression {
    [self setCallbackStatus:NativeAdCallbackPlayStart];
}

- (void)callbackFinish {
    [self setCallbackStatus:NativeAdCallbackPlayFinish];
}

- (void)callbackClick {
    [self setCallbackStatus:NativeAdCallbackClick];
}

- (void)dealloc {
}

#pragma mark - GADNativeAdLoaderDelegate

- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd {
    AdapterTrace;

    MovieNativeAdView6019 *nativeAdView = [[MovieNativeAdView6019 alloc] initWithFrame:CGRectZero];
    nativeAd.mediaContent.videoController.delegate = self;
    nativeAd.delegate = self;
    [nativeAdView setupAdView:nativeAd];

    MovieNativeAdInfo6019 *info = [[MovieNativeAdInfo6019 alloc] initWithVideoUrl:nil
                                                                            title:@""
                                                                      description:@""
                                                                     adnetworkKey:self.adnetworkKey];

    info.mediaType = [nativeAdView isVideoContents] ? ADFNativeAdType_Movie : ADFNativeAdType_Image;
    info.isCustomComponentSupported = true;
    info.adapter = self;
    info.nativeAdView = nativeAdView;
    [info setupMediaView:nativeAdView];
    self.adInfo = info;

    [self setCustomMediaview:nativeAdView];

    [self setCallbackStatus:NativeAdCallbackLoadFinish];
}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error {
    AdapterTraceP(@"error: %@", error);
    [self setError:error];
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

#pragma mark - GADVideoControllerDelegate

/// Tells the delegate that the video controller has began or resumed playing a video.
- (void)videoControllerDidPlayVideo:(nonnull GADVideoController *)videoController {
    AdapterTrace;
    [self callbackImpression];
}

/// Tells the delegate that the video controller has paused video.
- (void)videoControllerDidPauseVideo:(nonnull GADVideoController *)videoController {
    AdapterTrace;
}

/// Tells the delegate that the video controller's video playback has ended.
- (void)videoControllerDidEndVideoPlayback:(nonnull GADVideoController *)videoController {
    AdapterTrace;
    [self callbackFinish];
}

/// Tells the delegate that the video controller has muted video.
- (void)videoControllerDidMuteVideo:(nonnull GADVideoController *)videoController {
    AdapterTrace;
}

/// Tells the delegate that the video controller has unmuted video.
- (void)videoControllerDidUnmuteVideo:(nonnull GADVideoController *)videoController {
    AdapterTrace;
}


#pragma mark - GADNativeAdDelegate

- (void)nativeAdDidRecordImpression:(nonnull GADNativeAd *)nativeAd {
    AdapterTrace;
    if (self.adInfo.mediaType == ADFNativeAdType_Image) {
        [self callbackRender];
    }
}

- (void)nativeAdDidRecordClick:(nonnull GADNativeAd *)nativeAd {
    AdapterTrace;
    [self callbackClick];
}

- (void)nativeAdWillPresentScreen:(nonnull GADNativeAd *)nativeAd {
    AdapterTrace;
}

- (void)nativeAdWillDismissScreen:(nonnull GADNativeAd *)nativeAd {
    AdapterTrace;
}

- (void)nativeAdDidDismissScreen:(nonnull GADNativeAd *)nativeAd {
    AdapterTrace;
}

- (void)nativeAdIsMuted:(nonnull GADNativeAd *)nativeAd {
    AdapterTrace;
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

- (void)setupAdView:(GADNativeAd *)nativeAd {
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
                  GADNativeHeadlineAsset: self.headlineLabel,
                  GADNativeCallToActionAsset: self.callToActionLabel,
                  GADNativeIconAsset: self.iconImageView}
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
        if (self.isCustomNativeAdComponents) {
            // UI組立方式では静止画のImpression Callbackが来ないため、PlayMediaViewが呼ばれるタイミングでRender Eventを発生させる
            [self.adapter setCallbackStatus:NativeAdCallbackRendering];
        }
        [self.adapter startViewabilityCheck];
    }
}

- (NSDictionary *)getCustomNativeAdComponents {
    if (self.nativeAdView && self.nativeAdView.nativeAd) {
        GADNativeAd *nativeAd = self.nativeAdView.nativeAd;
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

- (GADNativeAdView *)createViewForCarousel:(NSDictionary *)parts {
    GADNativeAdView *view = [GADNativeAdView new];
    view.nativeAd = self.nativeAdView.nativeAd;
    view.bodyView = parts[@"body"];
    view.advertiserView = parts[@"advertiser"];
    view.callToActionView = parts[@"callToAction"];
    view.mediaView = parts[@"media"];
    [view.nativeAd registerAdView:view
              clickableAssetViews:@{
                  GADNativeCallToActionAsset: view.callToActionView,
                          GADNativeBodyAsset: view.bodyView,
                     GADNativeMediaViewAsset: view.mediaView,
                    GADNativeAdvertiserAsset: view.advertiserView
              }
           nonclickableAssetViews:@{}];
    return view;
}

@end

@implementation MovieNative6160
@end

@implementation MovieNative6161
@end

@implementation MovieNative6162
@end

@implementation MovieNative6163
@end

@implementation MovieNative6164
@end

@implementation MovieNative6060

+ (NSString *)adnetworkName {
    return @"Google Ad Manager";
}

@end
