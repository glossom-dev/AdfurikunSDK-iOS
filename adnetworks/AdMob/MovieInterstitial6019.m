//
//  MovieInterstitial6019.m
//  MovieRewardTestApp
//
//  Created by Ren Fujii on 2019/11/14.
//  Copyright © 2019 Glossom, Inc. All rights reserved.
//

#import "MovieInterstitial6019.h"
#import "AdnetworkConfigure6019.h"
#import "AdnetworkParam6019.h"

#import <ADFMovieReward/ADFMovieOptions.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface MovieInterstitial6019 ()<GADFullScreenContentDelegate>

@property(nonatomic) GADInterstitialAd *interstitial;

@end

@implementation MovieInterstitial6019

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"16";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"GADInterstitialAd";
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

    __weak typeof(self) weakSelf = self;
    [self.configure initAdnetworkSDKWithCompletionHander:^(_Bool result) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
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
        __weak typeof(self) weakSelf = self;
        [GADInterstitialAd loadWithAdUnitID:((AdnetworkParam6019 *)self.adParam).unitID
                                    request:request
                          completionHandler:^(GADInterstitialAd * _Nullable interstitialAd, NSError * _Nullable error) {
            __strong typeof(self) strongSelf = weakSelf;
            if (!strongSelf) return;
            if (error) {
                [strongSelf adRequestFailure:error];
            } else {
                [strongSelf adRequestSccess:interstitialAd];
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
    [self showAdWithPresentingViewController:[self topMostViewController]];
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
            [self.interstitial presentFromRootViewController:viewController];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    } else {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

- (void)adRequestSccess:(GADInterstitialAd * _Nullable)interstitialAd {
    AdapterTrace;
    if ([self isNotNull:interstitialAd]) {
        self.interstitial = interstitialAd;
        self.interstitial.fullScreenContentDelegate = self;
        [self setCallbackStatus:MovieRewardCallbackFetchComplete];
    } else {
        NSString *message = @"interstitialAd is null";
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

#pragma mark - GADFullScreenContentDelegate

- (void)adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>)ad {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    AdapterTraceP(@"error: %@", error);
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
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    [self setCallbackStatus:MovieRewardCallbackClose];
}

@end

@implementation MovieInterstitial6160
@end

@implementation MovieInterstitial6161
@end

@implementation MovieInterstitial6162
@end

@implementation MovieInterstitial6163
@end

@implementation MovieInterstitial6164
@end

@implementation MovieInterstitial6060

+ (NSString *)adnetworkName {
    return @"Google Ad Manager";
}

@end
