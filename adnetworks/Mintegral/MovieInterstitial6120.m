//
//  MovieInterstitial6120.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2022/09/14.
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import "MovieInterstitial6120.h"
#import "AdnetworkParam6120.h"

@interface MovieInterstitial6120 ()

@property (nonatomic) AdnetworkParam6120 *adParam;
@property (nonatomic) MTGNewInterstitialAdManager *adManager;

@end

@implementation MovieInterstitial6120

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
    return self.isAdLoaded && self.adManager && self.adManager.isAdReady;
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
        self.adManager = [[MTGNewInterstitialAdManager alloc] initWithPlacementId:self.adParam.placementId
                                                                           unitId:self.adParam.unitId
                                                                         delegate:self];
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
    
    if (!self.adParam || ![self.adParam isValid] || !self.adManager) {
        return;
    }
    
    [super startAd];
    
    // Adnetwork SDKの関数を呼び出す際はTryーCatchでException Handlingを行う
    @try {
        // 非同期で行われる場合にはFlag設定を行う
        [self requireToAsyncRequestAd];
        
        //音出力設定
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
}

// 広告再生関数
// showAdWithPresentingViewController と両方を必ず実装する
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
    
    @try {
        [self requireToAsyncPlay];
        
        [self.adManager showFromViewController:viewController];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

// Adnetwork SDKが設置されているかをチェックする
- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"MTGNewInterstitialAdManager");
    if (clazz) {
        AdapterLog(@"found Class: MTGNewInterstitialAdManager");
        return YES;
    } else {
        AdapterLog(@"Not found Class: MTGNewInterstitialAdManager");
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
