//
//  MovieReward6190.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/10/28.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import "MovieReward6190.h"

@interface MovieReward6190()
@property (nonatomic, strong) IMInterstitial *interstitial;
@end

@implementation MovieReward6190

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"1";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"InMobiSDK.IMInterstitial";
}

// ADFで定義しているAdnetwork名。
+ (NSString *)adnetworkName {
    return [AdnetworkConfigure6190 adnetworkName];
}

+ (NSString *)getSDKVersion {
    return [AdnetworkConfigure6190 getSDKVersion];
}

// Instance Variableを初期化する。また、必要な場合Configureを生成する
-(id)init {
    self = [super init];
    if (self) {
        self.configure = [AdnetworkConfigure6190 sharedInstance];
        self.isRewardAd = true;
    }
    return self;
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6190 alloc] initWithParam:data];
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
        
        if (!self.interstitial) {
            self.interstitial = [[IMInterstitial alloc] initWithPlacementId:((AdnetworkParam6190 *)self.adParam).placementId.integerValue
                                                                   delegate:self];
        }
        [self.interstitial load];
        
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
    return true;
}

// 在庫取得有無を返す
- (BOOL)isPrepared {
    return self.interstitial && [self.interstitial isReady];
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
    
    if (!self.interstitial) {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
        return;
    }
    
    if ([self isPrepared]) {
        @try {
            [self requireToAsyncPlay];
            // 再生する
            [self.interstitial showFrom:viewController];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    } else {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

#pragma mark IMInterstitialDelegate

// 読み込み成功
- (void)interstitialDidFinishLoading:(IMInterstitial *)interstitial {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
    self.creativeId = interstitial.creativeId;
}

// 読み込み失敗
- (void)interstitial:(IMInterstitial *)interstitial didFailToLoadWithError:(IMRequestStatus *)error {
    AdapterTraceP(@"error: %@", error);
    [self setError:error];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

// 再生失敗
- (void)interstitial:(IMInterstitial *)interstitial didFailToPresentWithError:(IMRequestStatus *)error {
    AdapterTraceP(@"error: %@", error);
    [self setError:error];
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}

- (void)interstitialWillPresent:(IMInterstitial *)interstitial {
    AdapterTrace;
}

- (void)interstitialDidPresent:(IMInterstitial *)interstitial {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)interstitialWillDismiss:(IMInterstitial *)interstitial {
    AdapterTrace;
}

- (void)interstitialDidDismiss:(IMInterstitial *)interstitial {
    AdapterTrace;
    // Interstitial広告は画面が閉じられる時にFinish Callbackを発火する
    if (!self.isRewardAd) {
        [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    }
    [self setCallbackStatus:MovieRewardCallbackClose];
}

- (void)userWillLeaveApplicationFromInterstitial:(IMInterstitial *)interstitial {
    AdapterTrace;
}

- (void)interstitial:(IMInterstitial *)interstitial rewardActionCompletedWithRewards:(NSDictionary *)rewards {
    AdapterTrace;
    // Interstitial広告ではこちらのCallbackが呼ばれないが念の為広告タイプをチェックして2重発生を防ぐ
    if (self.isRewardAd) {
        [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    }
}

- (void)interstitial:(IMInterstitial *)interstitial didInteractWithParams:(NSDictionary *)params {
    AdapterTrace;
}

- (void)interstitialDidReceiveAd:(IMInterstitial *)interstitial {
    AdapterTrace;
}

@end

@implementation MovieReward6191
@end

@implementation MovieReward6192
@end

@implementation MovieReward6193
@end

@implementation MovieReward6194
@end

@implementation MovieReward6195
@end

@implementation MovieReward6196
@end

@implementation MovieReward6197
@end

@implementation MovieReward6198
@end

@implementation MovieReward6199
@end
