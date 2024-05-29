//
//  MovieInterstitial6120.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2022/09/14.
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import "MovieInterstitial6120.h"
#import "AdnetworkConfigure6120.h"
#import "AdnetworkParam6120.h"

@interface MovieInterstitial6120 ()

@property (nonatomic) MTGNewInterstitialAdManager *adManager;

@end

@implementation MovieInterstitial6120

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"7";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"MTGNewInterstitialAdManager";
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
        if (!self.adManager) {
            self.adManager = [[MTGNewInterstitialAdManager alloc] initWithPlacementId:((AdnetworkParam6120 *)self.adParam).placementId
                                                                               unitId:((AdnetworkParam6120 *)self.adParam).unitId
                                                                             delegate:self];
        }
        //音出力設定
        AdapterLogP(@"soundState: %d", (int)[ADFMovieOptions getSoundState]);
        ADFMovieOptions_Sound soundState = [ADFMovieOptions getSoundState];
        if (ADFMovieOptions_Sound_On == soundState) {
            [self.adManager setPlayVideoMute:false];
        } else if (ADFMovieOptions_Sound_Off == soundState) {
            [self.adManager setPlayVideoMute:true];
        }
        
        [self.adManager loadAd];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
    return true;
}

// 在庫取得有無を返す
- (BOOL)isPrepared {
    return self.isAdLoaded && self.adManager && self.adManager.isAdReady;
}

// 広告再生
- (void)showAd {
    UIViewController *topVC = [self topMostViewController];
    if (topVC) {
        [self showAdWithPresentingViewController:topVC];
    } else {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAdWithPresentingViewController:viewController];
    
    if (!self.adManager) {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
        return;
    }

    if ([self isPrepared]) {
        @try {
            [self requireToAsyncPlay];
            [self.adManager showFromViewController:viewController];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    } else {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

/*
 * Adnetwork SDKからのCallbackに合わせてStatusを設定する
 [self setCallbackStatus:CALLBACKSTATUS]
 MovieRewardCallbackFetchComplete：広告読み込み完了
 MovieRewardCallbackPlayStart：再生開始
 MovieRewardCallbackPlayComplete：動画再生完了（Finish）
 MovieRewardCallbackClose：広告終了（Close）
 MovieRewardCallbackFetchFail：広告読み込み失敗
 MovieRewardCallbackPlayFail：再生失敗
 
 */

#pragma mark - MTGNewInterstitialAdDelegate

- (void)newInterstitialAdLoadSuccess:(MTGNewInterstitialAdManager *_Nonnull)adManager {
    AdapterTrace;
    self.creativeId = [adManager getCreativeIdWithUnitId:((AdnetworkParam6120 *)self.adParam).unitId];
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}


- (void)newInterstitialAdResourceLoadSuccess:(MTGNewInterstitialAdManager *_Nonnull)adManager {
    AdapterTrace;
}


- (void)newInterstitialAdLoadFail:(nonnull NSError *)error adManager:(MTGNewInterstitialAdManager *_Nonnull)adManager {
    AdapterTrace;
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}


- (void)newInterstitialAdShowSuccess:(MTGNewInterstitialAdManager *_Nonnull)adManager {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}


- (void)newInterstitialAdShowFail:(nonnull NSError *)error adManager:(MTGNewInterstitialAdManager *_Nonnull)adManager {
    AdapterTrace;
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}


- (void)newInterstitialAdPlayCompleted:(MTGNewInterstitialAdManager *_Nonnull)adManager {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
}


- (void)newInterstitialAdEndCardShowSuccess:(MTGNewInterstitialAdManager *_Nonnull)adManager {
    AdapterTrace;
}


- (void)newInterstitialAdClicked:(MTGNewInterstitialAdManager *_Nonnull)adManager {
    AdapterTrace;
}


- (void)newInterstitialAdDismissedWithConverted:(BOOL)converted adManager:(MTGNewInterstitialAdManager *_Nonnull)adManager {
    AdapterTrace;
}


- (void)newInterstitialAdDidClosed:(MTGNewInterstitialAdManager *_Nonnull)adManager {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackClose];
}

/**
 *  If iv reward is set, you will receive this callback
 *  @param rewardedOrNot  A sign to judge whether a reward can be given
 * @param alertWindowStatus MTGIVAlertWindowStatus
 */
- (void)newInterstitialAdRewarded:(BOOL)rewardedOrNot alertWindowStatus:(MTGNIAlertWindowStatus)alertWindowStatus adManager:(MTGNewInterstitialAdManager *_Nonnull)adManager {
    AdapterTrace;
}

@end

@implementation MovieInterstitial6121

@end

@implementation MovieInterstitial6122

@end

@implementation MovieInterstitial6123

@end

@implementation MovieInterstitial6124

@end

@implementation MovieInterstitial6125

@end
