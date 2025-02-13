//
//  MovieInterstitial6006.m(Vungle)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import "MovieInterstitial6006.h"
#import "AdnetworkConfigure6006.h"
#import "AdnetworkParam6006.h"

@interface MovieInterstitial6006()

@property (nonatomic, strong) VungleInterstitial *interstitialAd;

@end

@implementation MovieInterstitial6006

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"5";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"VungleAdsSDK.VungleInterstitial";
}

// ADFで定義しているAdnetwork名。
+ (NSString *)adnetworkName {
    return [AdnetworkConfigure6006 adnetworkName];
}

+ (NSString *)getSDKVersion {
    return [AdnetworkConfigure6006 getSDKVersion];
}

// Instance Variableを初期化する。また、必要な場合Configureを生成する
-(id)init {
    self = [super init];
    if (self) {
        self.configure = [AdnetworkConfigure6006 sharedInstance];
    }
    return self;
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6006 alloc] initWithParam:data];
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
        if (self.interstitialAd) {
            self.interstitialAd = nil;
        }
        
        self.interstitialAd = [[VungleInterstitial alloc] initWithPlacementId:((AdnetworkParam6006 *)self.adParam).placementID];
        self.interstitialAd.delegate = self;
        [self.interstitialAd load:nil];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
    return true;
}

// 在庫取得有無を返す
- (BOOL)isPrepared {
    return self.isAdLoaded && [self.interstitialAd canPlayAd];
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
    
    if (!self.interstitialAd) {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
        return;
    }

    if ([self isPrepared]) {
        @try {
            [self requireToAsyncPlay];
            [self.interstitialAd presentWith:viewController];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    } else {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

#pragma mark - VungleInterstitial Delegate Methods
// Ad load events
- (void)interstitialAdDidLoad:(VungleInterstitial *)interstitial {
    AdapterTrace;
    self.creativeId = interstitial.creativeId;
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

- (void)interstitialAdDidFailToLoad:(VungleInterstitial *)interstitial
                          withError:(NSError *)withError {
    AdapterTraceP(@"error : %@", withError);
    [self setLastError:withError];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

// Ad Lifecycle Events
- (void)interstitialAdWillPresent:(VungleInterstitial *)interstitial {
    AdapterTrace;
}

- (void)interstitialAdDidPresent:(VungleInterstitial *)interstitial {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)interstitialAdDidFailToPresent:(VungleInterstitial *)interstitial
                             withError:(NSError *)withError {
    AdapterTraceP(@"error : %@", withError);
    [self setLastError:withError];
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}

- (void)interstitialAdDidTrackImpression:(VungleInterstitial *)interstitial {
    AdapterTrace;
}

- (void)interstitialAdDidClick:(VungleInterstitial *)interstitial {
    AdapterTrace;
}

- (void)interstitialAdWillLeaveApplication:(VungleInterstitial *)interstitial {
    AdapterTrace;
}

- (void)interstitialAdWillClose:(VungleInterstitial *)interstitial {
    AdapterTrace;
}

- (void)interstitialAdDidClose:(VungleInterstitial *)interstitial {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    [self setCallbackStatus:MovieRewardCallbackClose];
}

@end

@implementation MovieInterstitial6200
@end

@implementation MovieInterstitial6201
@end

@implementation MovieInterstitial6202
@end

@implementation MovieInterstitial6203
@end

@implementation MovieInterstitial6204
@end

@implementation MovieInterstitial6205
@end

@implementation MovieInterstitial6206
@end

@implementation MovieInterstitial6207
@end

@implementation MovieInterstitial6208
@end
