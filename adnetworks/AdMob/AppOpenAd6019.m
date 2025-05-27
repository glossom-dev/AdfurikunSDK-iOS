//
//  AppOpenAd6019.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2023/03/22.
//  Copyright © 2023 Glossom, Inc. All rights reserved.
//

#import "AppOpenAd6019.h"
#import "AdnetworkConfigure6019.h"
#import "AdnetworkParam6019.h"

@interface AppOpenAd6019()

@property (nonatomic) GADAppOpenAd* appOpenAd;

@end

@implementation AppOpenAd6019

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"7";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"GADAppOpenAd";
}

// ADFで定義しているAdnetwork名。
+ (NSString *)adnetworkName {
    return [AdnetworkConfigure6019 adnetworkName];
}

// Instance Variableを初期化する。また、必要な場合Configureを生成する
-(id)init {
    self = [super init];
    if (self) {
        self.configure = [AdnetworkConfigure6019 sharedInstance];
    }
    return self;
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6019 alloc] initWithParam:data];
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
    [self.configure soundControl];
    return true;
}

// 広告読み込みを開始する
- (bool)startAd {
    if (![super startAd]) { // 読み込みが可能な状態かをチェックする
        return false;
    }
    
    @try {
        GADRequest *request = [GADRequest request];
        [(AdnetworkConfigure6019 *)self.configure setHasGdprConsent:self.hasGdprConsent request:request];
        [self requireToAsyncRequestAd];
        self.appOpenAd = nil;
        __weak typeof(self) weakSelf = self;
        [GADAppOpenAd loadWithAdUnitID:((AdnetworkParam6019 *)self.adParam).unitID
                               request:request
                     completionHandler:^(GADAppOpenAd *_Nullable appOpenAd, NSError *_Nullable error) {
            __strong typeof(self) strongSelf = weakSelf;
            if (!strongSelf) return;
            if (error) {
                [strongSelf adRequestFailure:error];
            } else {
                [strongSelf adRequestSccess:appOpenAd];
            }
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
    
    if (!self.appOpenAd) {
        [self setPlayFailCallbackAdInstanceNil];
        return;
    }

    if ([self isPrepared]) {
        @try {
            [self requireToAsyncPlay];
            [self.appOpenAd presentFromRootViewController:viewController];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setPlayFailCallbackException:exception];
        }
    } else {
        [self setPlayFailCallbackIsPreparedFalse];
    }
}

- (void)adRequestSccess:(GADAppOpenAd * _Nullable)appOpenAd {
    AdapterTrace;
    if ([self isNotNull:appOpenAd]) {
        self.appOpenAd = appOpenAd;
        self.appOpenAd.fullScreenContentDelegate = self;
        [self setCallbackStatus:MovieRewardCallbackFetchComplete];
    } else {
        NSString *message = @"appOpenAd is null";
        NSError *error = [NSError errorWithDomain:@"jp.glossom.adfurikun.error"
                                             code:0
                                         userInfo:@{NSLocalizedDescriptionKey: message,
                                                    NSLocalizedRecoverySuggestionErrorKey: message}];
        [self adRequestFailure:error];
    }
}

- (void)adRequestFailure:(NSError *)error {
    AdapterTraceP(@"error: %@", error);
    [self setError:error];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
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
#pragma mark - GADFullScreenContentDelegate

- (void)adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>)ad {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    AdapterTrace;
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}

- (void)adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    AdapterTrace;
}

- (void)adWillDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
    AdapterTrace;
}

- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    AdapterTrace;
    // OpenAdをクローズする時Finish BCを送信するためCallback statusをCompleteにする。アプリへのCallbackは発生しない
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    [self setCallbackStatus:MovieRewardCallbackClose];
}

@end

@implementation AppOpenAd6160
@end

@implementation AppOpenAd6161
@end

@implementation AppOpenAd6162
@end

@implementation AppOpenAd6163
@end

@implementation AppOpenAd6164
@end

@implementation AppOpenAd6060
@end
