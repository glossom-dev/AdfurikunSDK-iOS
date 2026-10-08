//
//  MovieInterstitial6001.m
//  MovieRewardSampleDev
//
//  Created by Amin Al on 2018/06/22.
//  Copyright © 2018 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovieInterstitial6001.h"
#import "AdnetworkConfigure6001.h"
#import "AdnetworkParam6001.h"

@interface MovieInterstitial6001 ()

@property (nonatomic, strong) UADSInterstitialAd *interstitialAd;

@end

@implementation MovieInterstitial6001

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"1";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"UnityAds.UADSInterstitialAd";
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
        if (self.interstitialAd) {
            self.interstitialAd = nil;
        }

        UADSLoadConfigurationBuilder *builder = [[UADSLoadConfigurationBuilder alloc] initWithPlacementId:param.placementId];

        __weak typeof(self) weakSelf = self;
        [UADSInterstitialAd load:[builder build]
                      completion:^(UADSInterstitialAd * _Nullable ad, id<UnityAdsError> _Nullable error) {
            __strong typeof(self) strongSelf = weakSelf;
            if (!strongSelf) return;

            if (error || !ad) {
                // adが取得できずerrorもnilで返るケースがあるため、その場合はデフォルトのメッセージを使う
                NSInteger errorCode = error ? error.code : 0;
                NSString *errorMessage = error ? error.message : @"[ADF] UnityAds load returned nil ad without error";
                AdapterLogP(@"load failed : placementId=%@, code=%ld, message=%@", param.placementId, (long)errorCode, errorMessage);
                [strongSelf setErrorWithMessage:errorMessage code:errorCode];
                [strongSelf setCallbackStatus:MovieRewardCallbackFetchFail];
                return;
            }

            AdapterTraceP(@"object : %@, placement Id : %@", strongSelf, param.placementId);
            strongSelf.interstitialAd = ad;
            [strongSelf setCallbackStatus:MovieRewardCallbackFetchComplete];
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
    
    if (!self.interstitialAd) {
        [self setPlayFailCallback:PlayFailCallbackReasonAdInstanceNil exception:nil];
        return;
    }

    if (viewController != nil && self.isPrepared) {
        @try {
            [self requireToAsyncPlay];
            
            UADSShowConfiguration *configuration = [[[UADSShowConfigurationBuilder alloc] init]
                                                    withViewController:viewController].build;
            [self.interstitialAd show:configuration delegate:self];
            
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setPlayFailCallback:PlayFailCallbackReasonException exception:exception];
        }
    } else {
        AdapterLog(@"Error encountered playing ad : could not fetch topmost viewcontroller");
        [self setPlayFailCallback:PlayFailCallbackReasonTopVCGetFailed exception:nil];
    }
}

#pragma mark: UADSInterstitialShowDelegate
- (void)showDidStart:(UADSInterstitialAd *)unityAd {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)showDidClick:(UADSInterstitialAd *)unityAd {
    AdapterTrace;
}

- (void)showDidComplete:(UADSInterstitialAd *)unityAd with:(enum UADSShowFinishState)finishState {
    AdapterTraceP(@"finishState : %ld", (long)finishState);
    switch (finishState) {
        case UADSShowFinishStateCompleted:
            AdapterTrace;
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

- (void)showDidFail:(UADSInterstitialAd *)unityAd error:(id<UnityAdsError>)error {
    AdapterTraceP(@"code : %ld, message : %@", (long)error.code, error.message);
    [self setErrorWithMessage:error.message code:error.code];
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}

@end

@implementation MovieInterstitial6030
@end

@implementation MovieInterstitial6031
@end

@implementation MovieInterstitial6032
@end

@implementation MovieInterstitial6033
@end

@implementation MovieInterstitial6034
@end

@implementation MovieInterstitial6035
@end

@implementation MovieInterstitial6036
@end

@implementation MovieInterstitial6037
@end

@implementation MovieInterstitial6038
@end
