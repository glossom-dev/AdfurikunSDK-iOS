//
//  MovieReward6120.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2022/09/02.
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import "MovieReward6120.h"
#import "AdnetworkParam6120.h"

@interface MovieReward6120 ()

@property (nonatomic) AdnetworkParam6120 *adParam;

@end

@implementation MovieReward6120

// SDKからバージョンを取得して返す
// APIがなければ削除
+ (NSString *)getSDKVersion {
    return MTGSDK.sdkVersion;
}

// Adapterのバージョン。最初は1にして、修正がある度＋1にする
+ (NSString *)getAdapterRevisionVersion {
    return @"2";
}

// getinfoからのParameter設定
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6120 alloc] initWithParam:data];
}

// 広告準備有無を返す
- (BOOL)isPrepared {
    // ロジックに合わせて修正する
    AdapterLogP(@"isVideoReady %d", [MTGRewardAdManager.sharedInstance isVideoReadyToPlayWithPlacementId:self.adParam.placementId unitId:self.adParam.unitId]);
    return  self.isAdLoaded && [MTGRewardAdManager.sharedInstance isVideoReadyToPlayWithPlacementId:self.adParam.placementId unitId:self.adParam.unitId];
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
        
        //音出力設定
        ADFMovieOptions_Sound soundState = [ADFMovieOptions getSoundState];
        if (ADFMovieOptions_Sound_On == soundState) {
            [MTGRewardAdManager.sharedInstance setPlayVideoMute:false];
        } else if (ADFMovieOptions_Sound_Off == soundState) {
            [MTGRewardAdManager.sharedInstance setPlayVideoMute:true];
        }
        
        [MTGRewardAdManager.sharedInstance loadVideoWithPlacementId:self.adParam.placementId
                                                             unitId:self.adParam.unitId
                                                           delegate:self];
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
    if (!self.adParam || ![self.adParam isValid]) {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
        return;
    }
    
    [super showAdWithPresentingViewController:viewController];

    @try {
        [self requireToAsyncPlay];
        
        [MTGRewardAdManager.sharedInstance showVideoWithPlacementId:self.adParam.placementId
                                                             unitId:self.adParam.unitId
                                                             userId:nil
                                                           delegate:self
                                                     viewController:viewController];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

// Adnetwork SDKが設置されているかをチェックする
- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"MTGRewardAdManager");
    if (clazz) {
        AdapterLog(@"found Class: MTGRewardAdManager");
        return YES;
    } else {
        AdapterLog(@"Not found Class: MTGRewardAdManager");
        return NO;
    }
}

-(void)setHasUserConsent:(BOOL)hasUserConsent {
    [super setHasUserConsent:hasUserConsent];
    [MTGSDK.sharedInstance setConsentStatus:hasUserConsent];
    AdapterLogP(@"Adnetwork 6120, gdprConsent : %@, sdk setting value : %d", self.hasGdprConsent, (int)hasUserConsent);
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

/**
*  Called when the ad is loaded , but not ready to be displayed,need to wait load video
completely

*  @param placementId - the placementId string of the Ad that was loaded.
*  @param unitId - the unitId string of the Ad that was loaded.
*/
- (void)onAdLoadSuccess:(nullable NSString *)placementId unitId:(nullable NSString *)unitId {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

/**
 *  Called when there was an error loading the ad.

 *  @param placementId - the placementId string of the Ad that was loaded.
 *  @param unitId      - the unitId string of the Ad that failed to load.
 *  @param error       - error object that describes the exact error encountered when loading the ad.
 */
- (void)onVideoAdLoadFailed:(nullable NSString *)placementId unitId:(nullable NSString *)unitId error:(nonnull NSError *)error {
    AdapterTrace;
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

/**
 *  Called when the ad display success

 *  @param placementId - the placementId string of the Ad that display success.
 *  @param unitId - the unitId string of the Ad that display success.
 */
- (void)onVideoAdShowSuccess:(nullable NSString *)placementId unitId:(nullable NSString *)unitId {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

/**
 *  Called when the ad display success,It will be called only when bidding is used.

 *  @param placementId - the placementId string of the Ad that display success.
 *  @param unitId - the unitId string of the Ad that display success.
 *  @param bidToken - the bidToken string of the Ad that display success.
 */
- (void)onVideoAdShowSuccess:(nullable NSString *)placementId unitId:(nullable NSString *)unitId bidToken:(nullable NSString *)bidToken {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

/**
 *  Called when the ad failed to display for some reason

 *  @param placementId      - the placementId string of the Ad that failed to be displayed.
 *  @param unitId      - the unitId string of the Ad that failed to be displayed.
 *  @param error       - error object that describes the exact error encountered when showing the ad.
 */
- (void)onVideoAdShowFailed:(nullable NSString *)placementId unitId:(nullable NSString *)unitId withError:(nonnull NSError *)error {
    AdapterTrace;
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}

/**
 *  Called only when the ad has a video content, and called when the video play completed.

 *  @param placementId - the placementId string of the Ad that video play completed.
 *  @param unitId - the unitId string of the Ad that video play completed.
 */
- (void) onVideoPlayCompleted:(nullable NSString *)placementId unitId:(nullable NSString *)unitId {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
}

/**
 *  Called only when the ad has a endcard content, and called when the endcard show.

 *  @param placementId - the placementId string of the Ad that endcard show.
 *  @param unitId - the unitId string of the Ad that endcard show.
 */
- (void) onVideoEndCardShowSuccess:(nullable NSString *)placementId unitId:(nullable NSString *)unitId {
    AdapterTrace;
}

/**
 *  Called when the ad is clicked
 *
 *  @param placementId - the placementId string of the Ad clicked.
 *  @param unitId - the unitId string of the Ad clicked.
 */
- (void)onVideoAdClicked:(nullable NSString *)placementId unitId:(nullable NSString *)unitId {
    AdapterTrace;
}

/**
 *  Called when the ad has been dismissed from being displayed, and control will return to your app
 *
 *  @param placementId      - the placementId string of the Ad that has been dismissed
 *  @param unitId      - the unitId string of the Ad that has been dismissed
 *  @param converted   - BOOL describing whether the ad has converted
 *  @param rewardInfo  - the rewardInfo object containing the info that should be given to your user.
 */
- (void)onVideoAdDismissed:(nullable NSString *)placementId unitId:(nullable NSString *)unitId withConverted:(BOOL)converted withRewardInfo:(nullable MTGRewardAdInfo *)rewardInfo {
    AdapterTrace;
}

/**
 *  Called when the ad  did closed;
 *
 *  @param unitId - the unitId string of the Ad that video play did closed.
 *  @param placementId - the placementId string of the Ad that video play did closed.
 */
- (void)onVideoAdDidClosed:(nullable NSString *)placementId unitId:(nullable NSString *)unitId {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackClose];
}

@end

@implementation MovieReward6121

@end

@implementation MovieReward6122

@end

@implementation MovieReward6123

@end

@implementation MovieReward6124

@end

@implementation MovieReward6125

@end
