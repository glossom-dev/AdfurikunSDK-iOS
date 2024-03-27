//
//  AppOpenAd6019.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2023/03/22.
//  Copyright © 2023 Glossom, Inc. All rights reserved.
//

#import "AppOpenAd6019.h"

@interface AppOpenAd6019()

@property (nonatomic) GADAppOpenAd* appOpenAd;

@property (nonatomic) NSString *unitID;
@property (nonatomic) BOOL testFlg;

@end

@implementation AppOpenAd6019


// Adapterのバージョン。最初は1にして、修正がある度＋1にする
+ (NSString *)getAdapterRevisionVersion {
    return @"5";
}

+ (NSString *)adnetworkClassName {
    return @"GADAppOpenAd";
}

+ (NSString *)adnetworkName {
    return @"AdMob";
}

// getinfoからのParameter設定
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    NSString* admobId = [data objectForKey:@"ad_unit_id"];
    if ([self isNotNull:admobId]) {
        self.unitID = [[NSString alloc] initWithFormat:@"%@", admobId];
    }
    NSNumber *testFlg = [data objectForKey:@"test_flg"];
    if ([self isNotNull:testFlg] && [testFlg isKindOfClass:[NSNumber class]]) {
        self.testFlg = [testFlg boolValue];
    }
}

// 広告準備有無を返す
- (BOOL)isPrepared {
    // ロジックに合わせて修正する
    return self.isAdLoaded;
}

// Adnetwork SDKの初期化を行う
- (void)initAdnetworkIfNeeded {
    if (self.testFlg) {
        //GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[@"コンソールに出力されたデバイスIDを入力してください。"]; //詳細　https://developers.google.com/admob/ios/test-ads?hl=ja
    }
    [self initCompleteAndRetryStartAdIfNeeded];
}

// 広告呼び込みを行う
- (void)startAd {
    if (![self canStartAd]) {
        return;
    }

    if (self.unitID == nil) {
        return;
    }
    
    [super startAd];
    
    @try {
        self.appOpenAd = nil;
        [GADAppOpenAd loadWithAdUnitID:self.unitID
                               request:[GADRequest request]
                     completionHandler:^(GADAppOpenAd *_Nullable appOpenAd, NSError *_Nullable error) {
            if (error) {
                [self adRequestFailure:error];
            } else {
                [self adRequestSccess:appOpenAd];
            }
        }];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

// 広告再生関数
// showAdWithPresentingViewController と両方を必ず実装する
- (void)showAd {
    [self showAdWithPresentingViewController:[self topMostViewController]];
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAdWithPresentingViewController:viewController];

    if (!self.appOpenAd) {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
        return;
    }
    
    @try {
        [self requireToAsyncPlay];
        
        [self.appOpenAd presentFromRootViewController:viewController];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

- (void)isChildDirected:(BOOL)childDirected {
    [super isChildDirected:childDirected];
    GADMobileAds.sharedInstance.requestConfiguration.tagForChildDirectedTreatment = [NSNumber numberWithBool:childDirected];
    AdapterLogP(@"Adnetwork %@, childDirected : %@, input parameter : %d", self.adnetworkKey, self.childDirected, (int)childDirected);
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
    [self setErrorWithMessage:error.localizedDescription code:error.code];
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

@implementation AppOpenAd6060
@end

@implementation AppOpenAd6061
@end

@implementation AppOpenAd6062
@end

@implementation AppOpenAd6063
@end

@implementation AppOpenAd6064
@end
