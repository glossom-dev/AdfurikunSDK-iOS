//
//  Banner6110.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2022/08/17.
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import "Banner6110.h"
#import "AdnetworkConfigure6110.h"
#import "AdnetworkParam6110.h"

@implementation Banner6110

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"8";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"IronSource";
}

// ADFで定義しているAdnetwork名。
+ (NSString *)adnetworkName {
    return [AdnetworkConfigure6110 adnetworkName];
}

+ (NSString *)getSDKVersion {
    return [AdnetworkConfigure6110 getSDKVersion];
}

// Instance Variableを初期化する。また、必要な場合Configureを生成する
-(id)init {
    self = [super init];
    if (self) {
        self.configure = [AdnetworkConfigure6110 sharedInstance];
        self.bannerSize = ISBannerSize_BANNER;
    }
    return self;
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6110 alloc] initWithParam:data];
    self.configure.param = self.adParam; // Parameterを設定する
}

// Adnetwork SDKを初期化する
- (bool)initAdnetworkIfNeeded {
    if (![super initAdnetworkIfNeeded]) { // 初期化済みかParameterが設定されてないとそのままReturnする
        if ([self.adParam isValid]) {
            [IronSource setISDemandOnlyBannerDelegate:self forInstanceId:((AdnetworkParam6110 *)self.adParam).instanceId];
        }
        return false;
    }
    
    // SDK初期化はConfigureを使う
    __weak typeof(self) weakSelf = self;
    [self.configure initAdnetworkSDKWithCompletionHander:^(_Bool result) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        // 初期化完了後の実装が必要な場合こちらに追加する
        [strongSelf initCompleteAndRetryStartAdIfNeeded];
        [IronSource setISDemandOnlyBannerDelegate:strongSelf forInstanceId:((AdnetworkParam6110 *)strongSelf.adParam).instanceId];
    }];
    return true;
}

// 広告読み込みを開始する
- (bool)startAd {
    if (![super startAd]) { // 読み込みが可能な状態かをチェックする
        return false;
    }

    UIViewController *topVC = [self topMostViewController];
    if (!topVC) {
        return false;
    }

    @try {
        [self requireToAsyncRequestAd];

        if (self.bannerView) {
            self.bannerView = nil;
        }
        [IronSource loadISDemandOnlyBannerWithInstanceId:((AdnetworkParam6110 *)self.adParam).instanceId
                                          viewController:topVC
                                                    size:self.bannerSize];
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

- (void)clearStatusIfNeeded {
}

// 後処理を実装
- (void)dispose {
    [super dispose];
    if (self.bannerView) {
        self.bannerView = nil;
    }
    [IronSource destroyISDemandOnlyBannerWithInstanceId:((AdnetworkParam6110 *)self.adParam).instanceId];
}

/*
 * Adnetwork SDKからのCallbackに合わせてStatusを設定する
 [self setCallbackStatus:CALLBACKSTATUS]
 NativeAdCallbackLoadFinish：読み込み完了
 nativeAdInfoSetting Snippetを使って、NativeAdInfoを作成する
 NativeAdCallbackLoadError：読み込み失敗
 NativeAdCallbackRendering：画面に広告表示開始
 NativeAdCallbackPlayStart：動作再生開始、静止画のViewability Impression
 NativeAdCallbackPlayFinish：動画再生完了
 NativeAdCallbackPlayFail：再生失敗
 NativeAdCallbackClick：広告クリック
 */

/**
 Called after a banner ad has been successfully loaded
 @param bannerView The view that contains the ad.
 @param instanceId The demand only instance id to be used to display the banner.
 */
- (void)bannerDidLoad:(ISDemandOnlyBannerView *)bannerView instanceId:(NSString *)instanceId {
    AdapterTrace;
    NativeAdInfo6110 *info = [[NativeAdInfo6110 alloc] initWithVideoUrl:nil
                                                                  title:@""
                                                            description:@""
                                                           adnetworkKey:self.adnetworkKey];
    info.mediaType = ADFNativeAdType_Image;
    [info setupMediaView:bannerView];
    [self setCustomMediaview:bannerView];
    self.bannerView = bannerView;
    
    info.adapter = self;
    info.isCustomComponentSupported = false;
    
    self.adInfo = info;
    
    [self setCallbackStatus:NativeAdCallbackLoadFinish];
}

/**
 Called after a banner has attempted to load an ad but failed.
 @param error The reason for the error
 @param instanceId The demand only instance id that fail to load.
 */
- (void)bannerDidFailToLoadWithError:(NSError *)error instanceId:(NSString *)instanceId {
    AdapterTraceP(@"error : %@", error);
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

/**
 Called when a banner was shown
 @param instanceId The demand only instance id which did show.

 */
- (void)bannerDidShow:(NSString *)instanceId {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackRendering];
    [self startViewabilityCheck];
}

/**
 Called after a banner has been clicked.
 @param instanceId The demand only instance id which clicked.

 */
- (void)didClickBanner:(NSString *)instanceId {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackClick];
}


/**
 Called when a user would be taken out of the application context.
 @param instanceId The demand only instance id that taken out of the application.

 */
- (void)bannerWillLeaveApplication:(NSString *)instanceId {
    AdapterTrace;
}

@end

@implementation NativeAdInfo6110

- (void)playMediaView {
}

@end

@implementation Banner6111
@end

@implementation Banner6112
@end

@implementation Banner6113
@end

@implementation Banner6114
@end

@implementation Banner6115
@end

@implementation Banner6116
@end

@implementation Banner6117
@end

@implementation Banner6118
@end

@implementation Banner6119
@end
