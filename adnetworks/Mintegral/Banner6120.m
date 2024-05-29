//
//  Banner6120.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2022/09/14.
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import "Banner6120.h"
#import "AdnetworkConfigure6120.h"
#import "AdnetworkParam6120.h"

@interface Banner6120 ()

@property (nonatomic) MTGBannerAdView *adView;

@end

@implementation Banner6120

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"8";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"MTGBannerAdView";
}

// ADFで定義しているAdnetwork名。
+ (NSString *)adnetworkName {
    return [AdnetworkConfigure6120 adnetworkName];
}

+ (NSString *)getSDKVersion {
    return [AdnetworkConfigure6120 getSDKVersion];
}

// Instance Variableを初期化する。また、必要な場合Configureを生成する
-(id)init {
    self = [super init];
    if (self) {
        self.configure = [AdnetworkConfigure6120 sharedInstance];
        self.adSize = MTGStandardBannerType320x50;
    }
    return self;
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6120 alloc] initWithParam:data];
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
    
    if (self.adView) {
        [self.adView destroyBannerAdView];
        self.adView = nil;
    }

    @try {
        [self requireToAsyncRequestAd];
        
        NSString *placementId = ((AdnetworkParam6120 *)self.adParam).placementId;
        NSString *unitId = ((AdnetworkParam6120 *)self.adParam).unitId;
        
        self.adView = [[MTGBannerAdView alloc] initBannerAdViewWithBannerSizeType:self.adSize
                                                                      placementId:placementId
                                                                           unitId:unitId
                                                               rootViewController:nil];
        self.adView.delegate = self;
        self.adView.autoRefreshTime = 0;
        [self.adView loadBannerAd];
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

#pragma mark MTGBannerAdViewDelegate
- (void)adViewLoadSuccess:(MTGBannerAdView *)adView {
    AdapterTrace;
    self.creativeId = adView.creativeId;
    
    NativeAdInfo6120 *info = [[NativeAdInfo6120 alloc] initWithVideoUrl:nil
                                                                  title:@""
                                                            description:@""
                                                           adnetworkKey:self.adnetworkKey ];
    info.mediaType = ADFNativeAdType_Image;
    [info setupMediaView:adView];
    [self setCustomMediaview:adView];
    
    info.adapter = self;
    info.isCustomComponentSupported = false;
    
    self.adInfo = info;
    
    [self setCallbackStatus:NativeAdCallbackLoadFinish];
}

- (void)adViewLoadFailedWithError:(NSError *)error adView:(MTGBannerAdView *)adView {
    AdapterTraceP(@"error : %@", error);
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

- (void)adViewWillLogImpression:(MTGBannerAdView *)adView {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackRendering];
    [self startViewabilityCheck];
}

- (void)adViewDidClicked:(MTGBannerAdView *)adView {
    [self setCallbackStatus:NativeAdCallbackClick];
    AdapterTrace;
}

- (void)adViewWillLeaveApplication:(MTGBannerAdView *)adView {
    AdapterTrace;
}

- (void)adViewWillOpenFullScreen:(MTGBannerAdView *)adView {
    AdapterTrace;
}

- (void)adViewCloseFullScreen:(MTGBannerAdView *)adView {
    AdapterTrace;
}

- (void)adViewClosed:(MTGBannerAdView *)adView {
    AdapterTrace;
}


@end

@implementation Banner6121
@end

@implementation Banner6122
@end

@implementation Banner6123
@end

@implementation Banner6124
@end

@implementation Banner6125
@end
