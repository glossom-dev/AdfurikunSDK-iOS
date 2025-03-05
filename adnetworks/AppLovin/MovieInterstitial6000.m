//
//  MovieInterstitial6000.m
//  SampleViewRecipe
//
//  Created by Junhua Li on 2016/11/03.
//
//

#import <AppLovinSDK/AppLovinSDK.h>
#import "MovieInterstitial6000.h"
#import "AdnetworkConfigure6000.h"
#import "AdnetworkParam6000.h"

#import <ADFMovieReward/ADFMovieOptions.h>

@interface MovieInterstitial6000()<ALAdLoadDelegate, ALAdDisplayDelegate>
@property (nonatomic, strong) ALAd *ad;
@property (nonatomic, strong) ALInterstitialAd *interstitialAd;
@end

@implementation MovieInterstitial6000

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"13";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"ALInterstitialAd";
}

// ADFで定義しているAdnetwork名。
+ (NSString *)adnetworkName {
    return [AdnetworkConfigure6000 adnetworkName];
}

+ (NSString *)getSDKVersion {
    return [AdnetworkConfigure6000 getSDKVersion];
}

+ (bool)isSupportForChild {
    return [AdnetworkConfigure6000 isSupportForChild];
}

// Instance Variableを初期化する。また、必要な場合Configureを生成する
-(id)init {
    self = [super init];
    if (self) {
        self.configure = [AdnetworkConfigure6000 sharedInstance];
    }
    return self;
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6000 alloc] initWithParam:data];
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
        if (!strongSelf.interstitialAd) {
            @try {
                strongSelf.interstitialAd = [[ALInterstitialAd alloc] initWithSdk:[ALSdk shared]];
                strongSelf.interstitialAd.adDisplayDelegate = strongSelf;
                strongSelf.interstitialAd.adLoadDelegate = strongSelf;
            } @catch (NSException *exception) {
                [strongSelf adnetworkExceptionHandling:exception];
            }
        }
        [self initCompleteAndRetryStartAdIfNeeded];
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
        if ([self.adParam isValid]) {
            [[ALSdk shared].adService loadNextAdForZoneIdentifier:((AdnetworkParam6000 *)self.adParam).zoneIdentifier andNotify:self];
        } else {
            [[ALSdk shared].adService loadNextAd:ALAdSize.interstitial andNotify:self];
        }
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
    return true;
}

// 在庫取得有無を返す
- (BOOL)isPrepared {
    if([self.adParam isValid] &&
       ![[((AdnetworkParam6000 *)self.adParam).submittedPackageName lowercaseString]
         isEqualToString:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]]) {
        //表示を消したい場合は、こちらをコメントアウトして下さい。
        AdapterLogP(@"[SEVERE] [Applovin]アプリのバンドルIDが、申請されたもの（%@）と異なります。", ((AdnetworkParam6000 *)self.adParam).submittedPackageName);
    }
    return self.isAdLoaded && self.ad && self.interstitialAd;
}

// 広告再生
- (void)showAd {
    [super showAd];
    
    if (!self.interstitialAd) {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
        return;
    }

    if ([self isPrepared]) {
        @try {
            [self requireToAsyncPlay];
            [self.interstitialAd showAd:self.ad];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    } else {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [self showAd];
}

// ------------------------------ -----------------
// ここからはApplovinのDelegateを受け取る箇所

/**
 *  広告の読み込み準備が終わった
 */
-(void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad {
    AdapterTrace;
    self.ad = ad;
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

/**
 *  広告の読み込みに失敗
 */
-(void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code {
    AdapterTraceP(@"code:%d", code);
    [self setErrorWithMessage:nil code:(NSInteger)code];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

/**
 *  広告の表示が開始された場合
 */
-(void) ad:(ALAd *) ad wasDisplayedIn: (UIView *)view {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

/**
 *  アプリが落とされたりした場合などのバックグラウンドに回った場合の動作
 */
-(void) ad:(ALAd *) ad wasHiddenIn: (UIView *)view {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    [self setCallbackStatus:MovieRewardCallbackClose];
}

/**
 *  広告をクリックされた場合の動作
 */
-(void) ad:(ALAd *) ad wasClickedIn: (UIView *)view {
    AdapterTrace;
}

@end

@implementation MovieInterstitial6011
@end

@implementation MovieInterstitial6012
@end

@implementation MovieInterstitial6013
@end

@implementation MovieInterstitial6014
@end

@implementation MovieInterstitial6015
@end

@implementation MovieInterstitial6210
@end

@implementation MovieInterstitial6211
@end

@implementation MovieInterstitial6212
@end

@implementation MovieInterstitial6213
@end
