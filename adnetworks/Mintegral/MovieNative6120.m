//
//  MovieNative6120.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2022/09/15.
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import "MovieNative6120.h"
#import "AdnetworkParam6120.h"

@interface MovieNative6120()

@property (nonatomic) AdnetworkParam6120 *adParam;
@property (nonatomic) MTGNativeAdvancedAd *adManager;

@end

@implementation MovieNative6120

// SDKからバージョンを取得して返す
// APIがなければ削除
+ (NSString *)getSDKVersion {
    return MTGSDK.sdkVersion;
}

// Adapterのバージョン。最初は1にして、修正がある度＋1にする
+ (NSString *)getAdapterRevisionVersion {
    return @"3";
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
    
    [super startAd];
    
    // Adnetwork SDKの関数を呼び出す際はTryーCatchでException Handlingを行う
    @try {
        // 非同期で行われる場合にはFlag設定を行う
        [self requireToAsyncRequestAd];
        
        self.adManager = [[MTGNativeAdvancedAd alloc] initWithPlacementID:self.adParam.placementId
                                                                   unitID:self.adParam.unitId
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
}

- (void)startAdWithOption:(NSDictionary *)option {
    [self startAd];
}

// Adnetwork SDKが設置されているかをチェックする
- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"MTGNativeAdvancedAd");
    if (clazz) {
        AdapterLog(@"found Class: MTGNativeAdvancedAd");
        return YES;
    } else {
        AdapterLog(@"Not found Class: MTGNativeAdvancedAd");
        return NO;
    }
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

- (void)dispose {
    
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
    NativeAdInfo6120 *info = [[NativeAdInfo6120 alloc] initWithVideoUrl:nil
                                                                  title:@""
                                                            description:@""
                                                           adnetworkKey:@"6120" ];
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
