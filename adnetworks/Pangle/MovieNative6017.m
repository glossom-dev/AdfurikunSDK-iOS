//
//  MovieNative6017.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/10/23.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "MovieNative6017.h"
#import "MovieReward6017.h"
#import "AdnetworkParam6017.h"

#pragma mark MovieNative6017

@interface MovieNative6017()

@property (nonatomic) PAGLNativeAd *nativeAd;
@property (nonatomic) PAGLNativeAdRelatedView *relatedView;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) BOOL didSendPlayStartCallback;
@property (nonatomic) BOOL didSendPlayFinishCallback;
@property (nonatomic) AdnetworkParam6017 *adParam;

@end

@implementation MovieNative6017

+ (NSString *)getSDKVersion {
    return PAGSdk.SDKVersion;
}

+ (NSString *)getAdapterRevisionVersion {
    return @"9";
}

+ (NSString *)adnetworkClassName {
    return @"PAGLNativeAd";
}

// getinfoから取得したデータを内部変数に保存する
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6017 alloc] initWithParam:data];
}

// SDKの初期化ロジックを入れる。ただし、Instance化を毎回する必要がある場合にはこちらではなくてSstartAdで行うこと
-(void)initAdnetworkIfNeeded {
    if (![self needsToInit]) {
        return;
    }
    if (!self.adParam || ![self.adParam isValid]) {
        return;
    }

    AdapterLog(@"MovieNatve6017 initAdnetworkIfNeeded");
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
}

- (void)clearStatusIfNeeded {
}

- (BOOL)isPrepared {
    return self.isAdLoaded;
}

// SDKのLoading関数を呼び出す
- (void)startAd {
    if (![self canStartAd]) {
        return;
    }

    if (!self.adParam || ![self.adParam isValid]) {
        return;
    }

    AdapterTrace;
    
    if (self.nativeAd) {
        self.nativeAd = nil;
    }
    
    [super startAd];
    
    @try {
        [self requireToAsyncRequestAd];
        
        PAGNativeRequest *request = PAGNativeRequest.request;
        [PAGLNativeAd loadAdWithSlotID:self.adParam.slotID
                                   request:request
                         completionHandler:^(PAGLNativeAd * _Nullable nativeAd, NSError * _Nullable error) {
            // load fail
            if (error) {
                [self setErrorWithMessage:error.localizedDescription code:error.code];
                [self setCallbackStatus:NativeAdCallbackLoadError];
                return;
            } else if (nativeAd == nil) {
                NSString *errorMsg = @"nativeAd is nil";
                AdapterTraceP(@"error : %@", errorMsg);
                [self setErrorWithMessage:errorMsg code:0];
                [self setCallbackStatus:NativeAdCallbackLoadError];
                return;
            }

            // load success
            [self setupNativeAdData:nativeAd];
            [self setCallbackStatus:NativeAdCallbackLoadFinish];
        }];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (void)startAdWithOption:(NSDictionary *)option {
    [self startAd];
}

- (void)setupNativeAdData:(PAGLNativeAd *)nativeAd {
    self.nativeAd = nativeAd;
    self.nativeAd.delegate = self;
    self.nativeAd.rootViewController = [self topMostViewController];
    
    PAGLMaterialMeta *adMeta = nativeAd.data;
    MovieNativeAdInfo6017 *info = [[MovieNativeAdInfo6017 alloc] initWithVideoUrl:nil
                                                                            title:adMeta.AdTitle
                                                                      description:adMeta.AdDescription
                                                                     adnetworkKey:@"6017"];
    info.mediaType = (adMeta.mediaType == PAGLNativeMediaTypeVideo) ? ADFNativeAdType_Movie : ADFNativeAdType_Image;
    if (self.relatedView) {
        self.relatedView = nil;
    }
    self.relatedView = [PAGLNativeAdRelatedView new];
    [self.relatedView refreshWithNativeAd:nativeAd];
    [info setupMediaView:self.relatedView.mediaView];
    [self setCustomMediaview:self.relatedView.mediaView];
    [nativeAd registerContainer:info.mediaView withClickableViews:@[self.relatedView.mediaView]];
    info.adapter = self;
    info.isCustomComponentSupported = false;
    
    self.didSendPlayStartCallback = false;
    self.didSendPlayFinishCallback = false;
    
    self.adInfo = info;
}

#pragma mark PAGLNativeAdDelegate

- (void)adDidShow:(PAGLNativeAd *)ad {
    AdapterTrace;
}

- (void)adDidClick:(PAGLNativeAd *)ad {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackClick];
}

- (void)adDidDismiss:(PAGLNativeAd *)ad {
    AdapterTrace;
}

@end

#pragma mark MovieNativeAdInfo6017

@implementation MovieNativeAdInfo6017

- (void)playMediaView {
    NSLog(@"[ADF] %s", __func__);
    if (self.adapter) {
        [self.adapter setCallbackStatus:NativeAdCallbackRendering];
        [self.adapter startViewabilityCheck];
    }
}

@end

@implementation MovieNative6090
@end

@implementation MovieNative6091
@end

@implementation MovieNative6092
@end

@implementation MovieNative6093
@end

@implementation MovieNative6094
@end
