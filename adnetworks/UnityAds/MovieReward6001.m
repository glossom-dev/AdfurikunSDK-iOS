//
//  MovieReward6001.m(UnityAds)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//
#import <UIKit/UIKit.h>
#import "MovieReward6001.h"
#import "AdnetworkConfigure6001.h"
#import "AdnetworkParam6001.h"

@interface MovieReward6001 ()

@property (nonatomic, strong) UADSRewardedAd *rewardedAd;

@end

@implementation MovieReward6001

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"18";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"UnityAds.UnityAds";
}

// ADFで定義しているAdnetwork名。
+ (NSString *)adnetworkName {
    return [AdnetworkConfigure6001 adnetworkName];
}

+ (NSString *)getSDKVersion {
    return [AdnetworkConfigure6001 getSDKVersion];
}

// Instance Variableを初期化する。また、必要な場合Configureを生成する
-(id)init {
    self = [super init];
    if (self) {
        self.configure = [AdnetworkConfigure6001 sharedInstance];
    }
    return self;
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6001 alloc] initWithParam:data];
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
        
        AdnetworkParam6001 *param = (AdnetworkParam6001 *)self.adParam;
        if (self.rewardedAd) {
            self.rewardedAd = nil;
        }

        UADSLoadConfigurationBuilder *builder = [[UADSLoadConfigurationBuilder alloc] initWithPlacementId:param.placementId];
        if (param.adm) { // for Bidding
            builder = [builder withAdMarkup:param.adm];
            AdapterLogP(@"UnityAds load with adm : placementId=%@", param.placementId);
        }

        __weak typeof(self) weakSelf = self;
        [UADSRewardedAd load:[builder build]
                  completion:^(UADSRewardedAd * _Nullable ad, id<UnityAdsError> _Nullable error) {
            __strong typeof(self) strongSelf = weakSelf;
            if (!strongSelf) return;

            if (error || !ad) {
                // adが取得できずerrorもnilで返るケースがあるため、その場合はデフォルトのメッセージを使う
                NSInteger errorCode = error ? error.code : 0;
                NSString *errorMessage = error ? error.message : @"[ADF] UnityAds load returned nil ad without error";
                AdapterLogP(@"load failed : placementId=%@, code=%ld, message=%@", param.placementId, (long)errorCode, errorMessage);
                [strongSelf setErrorWithMessage:errorMessage code:errorCode];
                [strongSelf sendFetchFail];
                return;
            }

            AdapterTraceP(@"object : %@, placement Id : %@", strongSelf, param.placementId);
            strongSelf.rewardedAd = ad;
            [strongSelf sendFetchComplete];
        }];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
    return true;
}

// 在庫取得有無を返す
- (BOOL)isPrepared {
    return self.isAdLoaded;
}

// 広告再生
- (void)showAd {
    UIViewController *topVC = [self topMostViewController];
    if (topVC) {
        [self showAdWithPresentingViewController:topVC];
    } else {
        [self setPlayFailCallback:PlayFailCallbackReasonTopVCGetFailed exception:nil];
    }
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAdWithPresentingViewController:viewController];
    
    // RTB専用：案件が期限切れの場合は再生させない
    if ([self isBiddingAdExpired]) {
        [self setPlayFailCallback:PlayFailCallbackReasonIsPreparedFalse exception:nil];
        return;
    }
    
    if (!self.rewardedAd) {
        [self setPlayFailCallback:PlayFailCallbackReasonAdInstanceNil exception:nil];
        return;
    }

    if (viewController != nil && self.isPrepared) {
        @try {
            [self requireToAsyncPlay];
            
            UADSShowConfiguration *configuration = [[[UADSShowConfigurationBuilder alloc] init]
                                                    withViewController:viewController].build;
            [self.rewardedAd show:configuration delegate:self];
            
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setPlayFailCallback:PlayFailCallbackReasonException exception:exception];
        }
    } else {
        AdapterLog(@"Error encountered playing ad : could not fetch topmost viewcontroller");
        [self setPlayFailCallback:PlayFailCallbackReasonTopVCGetFailed exception:nil];
    }
}

-(void)sendFetchComplete {
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

-(void)sendFetchFail {
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

#pragma mark: UADSRewardedShowDelegate
- (void)showDidStart:(UADSRewardedAd *)unityAd {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)showDidClick:(UADSRewardedAd *)unityAd {
    AdapterTrace;
}

- (void)showDidReceiveReward:(UADSRewardedAd *)unityAd {
    AdapterTrace;
    self.isRewarded = true;
}

- (void)showDidComplete:(UADSRewardedAd *)unityAd with:(enum UADSShowFinishState)finishState {
    AdapterTraceP(@"finishState : %ld", (long)finishState);
    switch (finishState) {
        case UADSShowFinishStateCompleted:
            AdapterTrace;
            self.isRewarded = true;
            [self setCallbackStatus:MovieRewardCallbackPlayComplete];
            break;
        case UADSShowFinishStateSkipped:
            AdapterTrace;
            break;
        default:
            AdapterLogP(@"other finishState : %ld", (long)finishState);
            [self setErrorWithMessage:@"showDidComplete with unknown UADSShowFinishState" code:0];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
            break;
    }

    [self setCallbackStatus:MovieRewardCallbackClose];
}

- (void)showDidFail:(UADSRewardedAd *)unityAd error:(id<UnityAdsError>)error {
    AdapterTraceP(@"code : %ld, message : %@", (long)error.code, error.message);
    [self setErrorWithMessage:error.message code:error.code];
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}

@end

@implementation MovieReward6030
@end

@implementation MovieReward6031
@end

@implementation MovieReward6032
@end

@implementation MovieReward6033
@end

@implementation MovieReward6034
@end

@implementation MovieReward6035
@end

@implementation MovieReward6036
@end

@implementation MovieReward6037
@end

@implementation MovieReward6038
@end
