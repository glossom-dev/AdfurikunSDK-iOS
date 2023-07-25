//
//  Banner6120.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2022/09/14.
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import "Banner6120.h"
#import "AdnetworkParam6120.h"

@interface Banner6120 ()

@property (nonatomic) MTGBannerAdView *adView;
@property (nonatomic) AdnetworkParam6120 *adParam;

@end

@implementation Banner6120

// SDKからバージョンを取得して返す
// APIがなければ削除
+ (NSString *)getSDKVersion {
    return MTGSDK.sdkVersion;
}

// Adapterのバージョン。最初は1にして、修正がある度＋1にする
+ (NSString *)getAdapterRevisionVersion {
    return @"5";
}

+ (NSString *)adnetworkClassName {
    return @"MTGBannerAdView";
}

// getinfoからのParameter設定
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6120 alloc] initWithParam:data];
}

// 広告準備有無を返す
- (BOOL)isPrepared {
    // ロジックに合わせて修正する
    return self.isAdLoaded;
}

// startAdが呼ばれるたびにStatus初期化が必要な場合こちらで実装する
- (void)clearStatusIfNeeded {
}

// Adnetwork SDKの初期化を行う
- (void)initAdnetworkIfNeeded {
    // 一回のみ初期化を行うようなチェックを行う
    if (![self needsToInit]) {
        return;
    }
    
    if (!self.adParam || ![self.adParam isValid]) {
        return;
    }
    
    self.adSize = MTGStandardBannerType320x50;
    
    // Adnetwork SDKの関数を呼び出す際はTryーCatchでException Handlingを行う
    @try {
        // 非同期で初期化が行われる場合にはFlag設定を行う
        [self requireToAsyncInit]; // 要らない場合には消す
        
        [MTGSDK.sharedInstance setAppID:self.adParam.appId ApiKey:self.adParam.appKey];
        
        // 初期化が完了するとこの関数を呼び出す
        [self initCompleteAndRetryStartAdIfNeeded]; // 適切なタイミングに移動する
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

// 広告呼び込みを行う
- (void)startAd {
    // 初期化が完了しているかをチェック
    if (![self canStartAd]) {
        return;
    }
    
    if (!self.adParam || ![self.adParam isValid]) {
        return;
    }

    if (self.adView) {
        [self.adView destroyBannerAdView];
        self.adView = nil;
    }
    
    [super startAd];
    
    // Adnetwork SDKの関数を呼び出す際はTryーCatchでException Handlingを行う
    @try {
        // 非同期で行われる場合にはFlag設定を行う
        [self requireToAsyncRequestAd];
        
        self.adView = [[MTGBannerAdView alloc] initBannerAdViewWithBannerSizeType:self.adSize
                                                                      placementId:self.adParam.placementId
                                                                      unitId:self.adParam.unitId
                                                               rootViewController:nil];
        self.adView.delegate = self;
        self.adView.autoRefreshTime = 0;
        [self.adView loadBannerAd];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (void)startAdWithOption:(NSDictionary *)option {
    [self startAd];
}

-(void)setHasUserConsent:(BOOL)hasUserConsent {
    [super setHasUserConsent:hasUserConsent];
    [MTGSDK.sharedInstance setConsentStatus:hasUserConsent];
    AdapterLogP(@"Adnetwork 6120, gdprConsent : %@, sdk setting value : %d", self.hasGdprConsent, (int)hasUserConsent);
}

- (void)isChildDirected:(BOOL)childDirected {
    [super isChildDirected:childDirected];
    [MTGSDK.sharedInstance setCoppa:childDirected ? MTGBoolYes : MTGBoolNo];
    AdapterLogP(@"Adnetwork %@, childDirected : %@, input parameter : %d", self.adnetworkKey, self.childDirected, (int)childDirected);
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
    NativeAdInfo6120 *info = [[NativeAdInfo6120 alloc] initWithVideoUrl:nil
                                                                  title:@""
                                                            description:@""
                                                           adnetworkKey:@"6120" ];
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
