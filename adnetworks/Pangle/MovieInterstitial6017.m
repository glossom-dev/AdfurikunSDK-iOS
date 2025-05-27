//
//  MovieInterstitial6017.m
//  MovieRewardTestApp
//
//  Created by Ren Fujii on 2019/08/20.
//  Copyright © 2019 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import "MovieInterstitial6017.h"
#import "AdnetworkConfigure6017.h"
#import "AdnetworkParam6017.h"

#import <PAGAdSDK/PAGAdSDK.h>

@interface MovieInterstitial6017 ()<PAGLInterstitialAdDelegate>

@property (nonatomic, strong) PAGLInterstitialAd *fullscreenVideoAd;

@end

@implementation MovieInterstitial6017

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"16";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"PAGLInterstitialAd";
}

// ADFで定義しているAdnetwork名。
+ (NSString *)adnetworkName {
    return [AdnetworkConfigure6017 adnetworkName];
}

+ (NSString *)getSDKVersion {
    return [AdnetworkConfigure6017 getSDKVersion];
}

// Instance Variableを初期化する。また、必要な場合Configureを生成する
-(id)init {
    self = [super init];
    if (self) {
        self.configure = [AdnetworkConfigure6017 sharedInstance];
    }
    return self;
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6017 alloc] initWithParam:data];
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
    
    if (self.fullscreenVideoAd) {
        self.fullscreenVideoAd = nil;
    }

    @try {
        [self requireToAsyncRequestAd];
        PAGInterstitialRequest *request = [PAGInterstitialRequest request];
        __weak typeof(self) weakSelf = self;
        [PAGLInterstitialAd loadAdWithSlotID:((AdnetworkParam6017 *)self.adParam).slotID
                                     request:request
                           completionHandler:^(PAGLInterstitialAd * _Nullable interstitialAd, NSError * _Nullable error) {
            __strong typeof(self) strongSelf = weakSelf;
            if (!strongSelf) return;
            // Load Fail
            if (error) {
                AdapterTraceP(@"error : %@", error);
                [strongSelf setErrorWithMessage:error.localizedDescription code:error.code];
                [strongSelf setCallbackStatus:MovieRewardCallbackFetchFail];
                return;
            } else if (interstitialAd == nil) {
                NSString *errorMsg = @"interstitialAd is nil";
                AdapterTraceP(@"error : %@", errorMsg);
                [strongSelf setErrorWithMessage:errorMsg code:0];
                [strongSelf setCallbackStatus:MovieRewardCallbackFetchFail];
                return;
            }
            // Load Success
            AdapterTrace;
            strongSelf.fullscreenVideoAd = interstitialAd;
            strongSelf.fullscreenVideoAd.delegate = strongSelf;
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
        [self setPlayFailCallbackTopVCGetFailed];
    }
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAdWithPresentingViewController:viewController];
    
    if (!self.fullscreenVideoAd) {
        [self setPlayFailCallbackAdInstanceNil];
        return;
    }

    if ([self isPrepared]) {
        @try {
            [self requireToAsyncPlay];
            [self.fullscreenVideoAd presentFromRootViewController:viewController];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setPlayFailCallbackException:exception];
        }
    } else {
        [self setPlayFailCallbackIsPreparedFalse];
    }
}

#pragma PAGLInterstitialAdDelegate

- (void)adDidShow:(PAGLInterstitialAd *)ad{
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)adDidClick:(PAGLInterstitialAd *)ad{
    AdapterTrace;
}

- (void)adDidDismiss:(PAGLInterstitialAd *)ad{
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    [self setCallbackStatus:MovieRewardCallbackClose];
}

@end

@implementation MovieInterstitial6090
@end

@implementation MovieInterstitial6091
@end

@implementation MovieInterstitial6092
@end

@implementation MovieInterstitial6093
@end

@implementation MovieInterstitial6094
@end

@implementation MovieInterstitial6095
@end

@implementation MovieInterstitial6096
@end

@implementation MovieInterstitial6097
@end

@implementation MovieInterstitial6098
@end
