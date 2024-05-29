//
//  MovieNative6120.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2022/09/15.
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import "MovieNative6120.h"
#import "AdnetworkConfigure6120.h"
#import "AdnetworkParam6120.h"

@interface MovieNative6120()

@property (nonatomic) MTGNativeAdvancedAd *adManager;

@end

@implementation MovieNative6120

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"7";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"MTGNativeAdvancedAd";
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
    
    @try {
        [self requireToAsyncRequestAd];
        
        NSString *placementId = ((AdnetworkParam6120 *)self.adParam).placementId;
        NSString *unitId = ((AdnetworkParam6120 *)self.adParam).unitId;

        self.adManager = [[MTGNativeAdvancedAd alloc] initWithPlacementID:placementId
                                                                   unitID:unitId
                                                                   adSize:CGSizeMake(320.0, 180.0)
                                                       rootViewController:nil];
        self.adManager.mute = true;
        self.adManager.delegate = self;

/*
        NSDictionary *styles = @{
                @"list": @[
                        @{
                            // target
                            @"target": @"container",
                            // values
                            @"values": @{

                                    @"paddingTop": @(0),
                                    @"paddingRight": @(0),
                                    @"paddingBottom": @(0),
                                    @"paddingLeft": @(0),

                                    @"backgroundColor": @"#FC2E02",
                                    @"fontSize": @(10),
                                    @"color": @"#060602",
                                    @"fontFamily": @"Apple Symbols"
                            }

                        }
                    ]
            };
        [self.adManager setAdElementsStyle:styles];
 */
        
        [self.adManager loadAd];
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

/**
 This method is called when ad is loaded successfully.
 */
- (void)nativeAdvancedAdLoadSuccess:(MTGNativeAdvancedAd *)nativeAd {
    AdapterTrace;
    self.creativeId = nativeAd.creativeId;
    
    NativeAdInfo6120 *info = [[NativeAdInfo6120 alloc] initWithVideoUrl:nil
                                                                  title:@""
                                                            description:@""
                                                           adnetworkKey:self.adnetworkKey ];
    info.mediaType = ADFNativeAdType_Movie;
    UIView *adView = [nativeAd fetchAdView];
    [info setupMediaView:adView];
    [self setCustomMediaview:adView];
    
    info.adapter = self;
    info.isCustomComponentSupported = false;
    
    self.adInfo = info;
    
    [self setCallbackStatus:NativeAdCallbackLoadFinish];
}
 
/**
 This method is called when ad failed to load.
 */
- (void)nativeAdvancedAdLoadFailed:(MTGNativeAdvancedAd *)nativeAd error:(NSError * __nullable)error {
    AdapterTraceP(@"error : %@", error);
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

/**
 Sent immediately before the impression of an MTGNativeAdvancedAd object will be logged.
 */
- (void)nativeAdvancedAdWillLogImpression:(MTGNativeAdvancedAd *)nativeAd {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackRendering];
    [self startViewabilityCheck];
}
 
/**
 This method is called when ad is clicked.
 */
- (void)nativeAdvancedAdDidClicked:(MTGNativeAdvancedAd *)nativeAd {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackClick];
}
 
/**
 Called when the application is about to leave as a result of tapping.
 Your application will be moved to the background shortly after this method is called.
 */
- (void)nativeAdvancedAdWillLeaveApplication:(MTGNativeAdvancedAd *)nativeAd {
    AdapterTrace;
}
 
/**
 Will open the full screen view
 Called when opening storekit or opening the webpage in app

 */
- (void)nativeAdvancedAdWillOpenFullScreen:(MTGNativeAdvancedAd *)nativeAd {
    AdapterTrace;
}
 
/**
 Close the full screen view
 Called when closing storekit or closing the webpage in app
 */
- (void)nativeAdvancedAdCloseFullScreen:(MTGNativeAdvancedAd *)nativeAd {
    AdapterTrace;
}

/**
 This method is called when ad is Closed.
 */
- (void)nativeAdvancedAdClosed:(MTGNativeAdvancedAd *)nativeAd {
    AdapterTrace;
}

@end

@implementation MovieNative6121
@end

@implementation MovieNative6122
@end

@implementation MovieNative6123
@end

@implementation MovieNative6124
@end

@implementation MovieNative6125
@end

@implementation NativeAdInfo6120

- (void)playMediaView {
}

@end
