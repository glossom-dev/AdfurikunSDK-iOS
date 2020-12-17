//
//  MovieNative6020.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/07/27.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "MoPub.h"

#import "MovieNative6020.h"

#pragma mark MovieNative6020

@interface MovieNative6020()

@property (nonatomic) MPNativeAdRendererConfiguration *config;
@property (nonatomic) MPStaticNativeAdRendererSettings *settings;
@property (nonatomic, strong) NSString *adUnitId;
@property (nonatomic) BOOL hasPendedLoad;

@end

@implementation MovieNative6020

- (BOOL)isClassReference {
    NSLog(@"MovieNatve6020 isClassReference");
    Class clazz = NSClassFromString(@"MPNativeAd");
    if (clazz) {
        NSLog(@"found Class: MPNativeAd");
        return YES;
    }
    else {
        NSLog(@"Not found Class: MPNativeAd");
        return NO;
    }
    return YES;
}

// getinfoから取得したデータを内部変数に保存する
- (void)setData:(NSDictionary *)data {
    NSLog(@"MovieNatve6020 setData");
    [super setData:data];

    NSString *adUnitId = [data objectForKey:@"ad_unit_id"];
    if ([self isNotNull:adUnitId]) {
        self.adUnitId = [NSString stringWithFormat:@"%@", adUnitId];
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

// SDKの初期化ロジックを入れる。ただし、Instance化を毎回する必要がある場合にはこちらではなくてSstartAdで行うこと
-(void)initAdnetworkIfNeeded {
    if (self.adUnitId) {
        @try {
            
            NSLog(@"MovieNatve6020 initAdnetworkIfNeeded");
            MPMoPubConfiguration *sdkConfig = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:self.adUnitId];
            
            sdkConfig.globalMediationSettings = @[];
            sdkConfig.loggingLevel = MPBLogLevelInfo;
            
            [[MoPub sharedInstance] initializeSdkWithConfiguration:sdkConfig completion:^{
                NSLog(@"MovieNatve6020 SDK initialization complete");
                if (self.hasPendedLoad) {
                    self.hasPendedLoad = false;
                    [self startAd];
                }
            }];
            
            self.settings = [[MPStaticNativeAdRendererSettings alloc] init];
            self.settings.renderingViewClass = [MovieNativeAdView6020 class];
            self.config = [MPStaticNativeAdRenderer rendererConfigurationWithRendererSettings:self.settings];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    }
}

- (void)clearStatusIfNeeded {

}

- (BOOL)isPrepared {
    return self.isAdLoaded;
}

// SDKのLoading関数を呼び出す
- (void)startAd {
    NSLog(@"MovieNative6020 : startAd");
    if (self.adUnitId == nil) {
        return;
    }
    if (![MoPub sharedInstance].isSdkInitialized) {
        self.hasPendedLoad = true;
        return;
    }

    [super startAd];
    
    @try {
        MPNativeAdRequest *adRequest = [MPNativeAdRequest requestWithAdUnitIdentifier:self.adUnitId
                                                               rendererConfigurations:@[self.config]];
        MPNativeAdRequestTargeting *targeting = [MPNativeAdRequestTargeting targeting];
        targeting.desiredAssets = [NSSet setWithObjects:
                                   kAdTitleKey,
                                   kAdCTATextKey,
                                   kAdIconImageKey,
                                   kAdMainImageKey,
                                   kAdPrivacyIconUIImageKey,
                                   kAdSponsoredByCompanyKey,
                                   nil];
        adRequest.targeting = targeting;
        
        MovieNative6020 __weak *weakSelf = self;
        [adRequest startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
            NSLog(@"MovieNatve6020 startWithCompletionHandler %@, %@", response, error);
            if (weakSelf) {
                if (error) {
                    [weakSelf sendLoadFail:error];
                } else {
                    [weakSelf loadAdInfo:response];
                }
            }
        }];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (void)startAdWithOption:(NSDictionary *)option {
    [self startAd];
}

- (void)cancel {
}

- (void)loadAdInfo:(MPNativeAd *)response {
    MovieNativeAdInfo6020 *info = [[MovieNativeAdInfo6020 alloc] initWithVideoUrl:nil
                                                                            title:@""
                                                                      description:@""
                                                                     adnetworkKey:@"6020"];
    info.mediaType = ADFNativeAdType_Image;
    info.adapter = self;
    info.nativeAd = response;
    info.nativeAd.delegate = self;
    info.isCustomComponentSupported = false;

    NSError *errrr;
    UIView *nativeAdView = [response retrieveAdViewWithError:&errrr];
    if (errrr == nil) {
        nativeAdView.frame = CGRectMake(0.0, 0.0, 320.0, 180.0);
        [self printSubView:nativeAdView];
        NSLog(@"MovieNative6020 retrieveAdViewWithError %@", errrr);
        [info setupMediaView:nativeAdView];
        [self setCustomMediaview:nativeAdView];

        self.adInfo = info;
        self.isAdLoaded = YES;

        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadFinish:)]) {
                [self.delegate onNativeMovieAdLoadFinish:self.adInfo];
            }
        }
    } else {
        [self sendLoadFail:errrr];
    }
}

- (void)sendLoadFail:(NSError *)error {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadError:)]) {
            if (error) {
                [self setErrorWithMessage:error.localizedDescription code:error.code];
            }
            [self.delegate onNativeMovieAdLoadError:self];
        }
    }
}

- (void)printSubView:(UIView *)view {
    for (UIView *subView in view.subviews) {
        NSLog(@"MovieNative6020 view %@ - subview %@", view, subView);
        if (subView.subviews.count > 0) {
            [self printSubView:subView];
        }
    }
}

- (UIViewController *)viewControllerForPresentingModalView {
    NSLog(@"MovieNative6020 viewControllerForPresentingModalView");
    return [self topMostViewController];
}

@end

#pragma mark MovieNativeAdView6020

@interface MovieNativeAdView6020()

@property (weak, nonatomic) IBOutlet UIView *_view;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *callToActionLabel;
@property (weak, nonatomic) IBOutlet UILabel *sponsoredByLabel;
@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UIImageView *privacyInformationIconImageView;

@end


@implementation MovieNativeAdView6020

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self makeSubviews];
    }
    return self;
}

- (void)makeSubviews {
    NSArray <UIView *>*result = [[UINib nibWithNibName:@"MovieNativeAdView6020" bundle:nil] instantiateWithOwner:self options:nil];
    UIView *_view = result.firstObject;
    [self viewSetted:_view];
}

- (void)viewSetted:(UIView *)_view {
    _view.frame = self.bounds;
    [self addSubview:_view];
    _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (UILabel *)nativeTitleTextLabel {
    return self.titleLabel;
}

- (UILabel *)nativeCallToActionTextLabel {
    return self.callToActionLabel;
}

- (UIImageView *)nativeIconImageView {
    return self.iconImageView;
}

- (UIImageView *)nativeMainImageView {
    return self.mainImageView;
}

- (UIImageView *)nativePrivacyInformationIconImageView {
    return self.privacyInformationIconImageView;
}

@end

#pragma mark MovieNativeAdInfo6020

@implementation MovieNativeAdInfo6020

- (void)playMediaView {
    NSLog(@"%s", __func__);
    if (self.mediaView.adapterInnerDelegate) {
        if ([self.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewRendering)]) {
            [self.mediaView.adapterInnerDelegate onADFMediaViewRendering];
        } else {
            NSLog(@"MovieNativeAdInfo6020: %s onADFMediaViewRendering selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"MovieNativeAdInfo6020: %s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }

    if (self.adapter) {
        [self.adapter startViewabilityCheck];
    }
}

@end
