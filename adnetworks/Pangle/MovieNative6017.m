//
//  MovieNative6017.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/10/23.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "MovieNative6017.h"
#import "AdnetworkConfigure6017.h"
#import "AdnetworkParam6017.h"

#pragma mark MovieNative6017

@interface MovieNative6017()

@property (nonatomic) PAGLNativeAd *nativeAd;
@property (nonatomic) PAGLNativeAdRelatedView *relatedView;
@property (nonatomic) UIImageView *imageView;

@end

@implementation MovieNative6017

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"12";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"PAGLNativeAd";
}

// ADFで定義しているAdnetwork名。
+ (NSString *)adnetworkName {
    return [AdnetworkConfigure6017 adnetworkName];
}

+ (NSString *)getSDKVersion {
    return [AdnetworkConfigure6017 getSDKVersion];
}

// Instance Variableを初期化する。また、必要な場合Configureを生成する
-(id)init {
    self = [super init];
    if (self) {
        self.configure = [AdnetworkConfigure6017 sharedInstance];
    }
    return self;
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6017 alloc] initWithParam:data];
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
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        // 初期化完了後の実装が必要な場合こちらに追加する
        [strongSelf initCompleteAndRetryStartAdIfNeeded];
    }];
    return true;
}

// 広告読み込みを開始する
- (bool)startAd {
    if (![super startAd]) { // 読み込みが可能な状態かをチェックする
        return false;
    }
    
    if (self.nativeAd) {
        self.nativeAd = nil;
    }

    @try {
        [self requireToAsyncRequestAd];
        PAGNativeRequest *request = PAGNativeRequest.request;
        __weak typeof(self) weakSelf = self;
        [PAGLNativeAd loadAdWithSlotID:((AdnetworkParam6017 *)self.adParam).slotID
                               request:request
                     completionHandler:^(PAGLNativeAd * _Nullable nativeAd, NSError * _Nullable error) {
            __strong typeof(self) strongSelf = weakSelf;
            if (!strongSelf) return;

            // load fail
            if (error) {
                [strongSelf setErrorWithMessage:error.localizedDescription code:error.code];
                [strongSelf setCallbackStatus:NativeAdCallbackLoadError];
                return;
            } else if (nativeAd == nil) {
                NSString *errorMsg = @"nativeAd is nil";
                AdapterTraceP(@"error : %@", errorMsg);
                [strongSelf setErrorWithMessage:errorMsg code:0];
                [strongSelf setCallbackStatus:NativeAdCallbackLoadError];
                return;
            }

            // load success
            [strongSelf setupNativeAdData:nativeAd];
            [strongSelf setCallbackStatus:NativeAdCallbackLoadFinish];
        }];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
    return true;
}

- (bool)startAdWithOption:(NSDictionary *)option {
    return [self startAd];
}

// 在庫取得有無を返す
- (BOOL)isPrepared {
    return self.isAdLoaded;
}

// startAd前の後処理
- (void)clearStatusIfNeeded {
}

// 後処理を実装
- (void)dispose {
    [super dispose];
}

- (void)setupNativeAdData:(PAGLNativeAd *)nativeAd {
    self.nativeAd = nativeAd;
    self.nativeAd.delegate = self;
    self.nativeAd.rootViewController = [self topMostViewController];
    
    PAGLMaterialMeta *adMeta = nativeAd.data;
    MovieNativeAdInfo6017 *info = [[MovieNativeAdInfo6017 alloc] initWithVideoUrl:nil
                                                                            title:adMeta.AdTitle
                                                                      description:adMeta.AdDescription
                                                                     adnetworkKey:self.adnetworkKey];
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

@implementation MovieNative6095
@end

@implementation MovieNative6096
@end

@implementation MovieNative6097
@end

@implementation MovieNative6098
@end
