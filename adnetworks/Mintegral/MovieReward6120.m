//
//  MovieReward6120.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2022/09/02.
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import "MovieReward6120.h"
#import "AdnetworkConfigure6120.h"
#import "AdnetworkParam6120.h"

@implementation MovieReward6120

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"10";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"MTGRewardAdManager";
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
        //音出力設定
        AdapterLogP(@"soundState: %d", (int)[AdfurikunSdk getSoundState]);
        AdfurikunSdkSound soundState = [AdfurikunSdk getSoundState];
        if (AdfurikunSdkSoundOn == soundState) {
            [MTGRewardAdManager.sharedInstance setPlayVideoMute:false];
        } else if (AdfurikunSdkSoundOff == soundState) {
            [MTGRewardAdManager.sharedInstance setPlayVideoMute:true];
        }
        
        [MTGRewardAdManager.sharedInstance loadVideoWithPlacementId:((AdnetworkParam6120 *)self.adParam).placementId
                                                             unitId:((AdnetworkParam6120 *)self.adParam).unitId
                                                           delegate:self];

    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
    return true;
}

// 在庫取得有無を返す
- (BOOL)isPrepared {
    if (![self.adParam isValid]) {
        return false;
    }
    NSString *placementId = ((AdnetworkParam6120 *)self.adParam).placementId;
    NSString *unitId = ((AdnetworkParam6120 *)self.adParam).unitId;
    bool result = [MTGRewardAdManager.sharedInstance isVideoReadyToPlayWithPlacementId:placementId
                                                                                unitId:unitId];
    AdapterLogP(@"isVideoReady %d", (int)result);
    return self.isAdLoaded && result;
}

// 広告再生
- (void)showAd {
    UIViewController *topVC = [self topMostViewController];
    if (topVC) {
        [self showAdWithPresentingViewController:topVC];
    } else {
        [self setPlayFailCallbackTopVCGetFailed];
    }
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAdWithPresentingViewController:viewController];
    
    if ([self isPrepared]) {
        @try {
            [self requireToAsyncPlay];
            [MTGRewardAdManager.sharedInstance showVideoWithPlacementId:((AdnetworkParam6120 *)self.adParam).placementId
                                                                 unitId:((AdnetworkParam6120 *)self.adParam).unitId
                                                                 userId:nil
                                                               delegate:self
                                                         viewController:viewController];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setPlayFailCallbackException:exception];
        }
    } else {
        [self setPlayFailCallbackIsPreparedFalse];
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

/**
*  Called when the ad is loaded , but not ready to be displayed,need to wait load video
completely

*  @param placementId - the placementId string of the Ad that was loaded.
*  @param unitId - the unitId string of the Ad that was loaded.
*/
- (void)onAdLoadSuccess:(nullable NSString *)placementId unitId:(nullable NSString *)unitId {
    AdapterTrace;
    self.creativeId = [MTGRewardAdManager.sharedInstance getCreativeIdWithUnitId:unitId];
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
    self.isRewarded = true; // 動画視聴完了でもRewardを付与する
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
    AdapterTraceP(@"reward info : %@", rewardInfo);
    self.isRewarded = (rewardInfo != nil);
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

@implementation MovieReward6126
@end

@implementation MovieReward6127
@end

@implementation MovieReward6128
@end

@implementation MovieReward6129
@end
