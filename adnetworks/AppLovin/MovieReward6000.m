//
//  MovieReward6000.m(AppLovin)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import <ADFMovieReward/ADFMovieOptions.h>
#import "MovieReward6000.h"

#import "AdnetworkConfigure6000.h"
#import "AdnetworkParam6000.h"

@interface MovieReward6000()<ALAdLoadDelegate, ALAdDisplayDelegate, ALAdVideoPlaybackDelegate>

@property(nonatomic, strong) ALIncentivizedInterstitialAd *incentivizedInterstitial;

@end


@implementation MovieReward6000

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"12";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"ALIncentivizedInterstitialAd";
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
        if (!strongSelf.incentivizedInterstitial) {
            @try {
                if ([strongSelf.adParam isValid]) {
                    strongSelf.incentivizedInterstitial =
                    [[ALIncentivizedInterstitialAd alloc] initWithZoneIdentifier:((AdnetworkParam6000 *)strongSelf.adParam).zoneIdentifier];
                } else {
                    strongSelf.incentivizedInterstitial = [[ALIncentivizedInterstitialAd alloc] initWithSdk:[ALSdk shared]];
                }
            } @catch (NSException *exception) {
                [self adnetworkExceptionHandling:exception];
            }
            strongSelf.incentivizedInterstitial.adDisplayDelegate = strongSelf;
            strongSelf.incentivizedInterstitial.adVideoPlaybackDelegate = strongSelf;
        }
        [strongSelf initCompleteAndRetryStartAdIfNeeded];
    }];
    return true;
}

// 広告読み込みを開始する
- (bool)startAd {
    if (![super startAd]) { // 読み込みが可能な状態かをチェックする
        return false;
    }

    if (!self.incentivizedInterstitial) {
        [self setCallbackStatus:MovieRewardCallbackFetchFail];
        return false;
    }
    
    @try {
        [self requireToAsyncRequestAd];
        [self.incentivizedInterstitial preloadAndNotify:self];
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
    return self.isAdLoaded && self.incentivizedInterstitial && self.incentivizedInterstitial.isReadyForDisplay;
}

// 広告再生
- (void)showAd {
    [super showAd];
    
    if (!self.incentivizedInterstitial) {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
        return;
    }

    if ([self isPrepared]) {
        @try {
            [self requireToAsyncPlay];
            [self.incentivizedInterstitial show];
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
-(void) adService: (ALAdService *) adService didLoadAd: (ALAd *) ad {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

/**
 *  広告の読み込みに失敗
 */
-(void) adService: (ALAdService *) adService didFailToLoadAdWithError: (int) code {
    AdapterTraceP(@"code : %d", code);
    [self setErrorWithMessage:nil code:code];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

/**
 *  広告の表示が開始された場合
 */
-(void) ad: (ALAd *) ad wasDisplayedIn: (UIView *) view {
    AdapterTrace;
}

/**
 *  アプリが落とされたりした場合などのバックグラウンドに回った場合の動作
 */
-(void) ad: (ALAd *) ad wasHiddenIn: (UIView *) view {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackClose];
}

/**
 *  広告をクリックされた場合の動作
 */
-(void) ad: (ALAd *) ad wasClickedIn: (UIView *) view {
    AdapterTrace;
}

/**
 *  広告（ビデオ)の表示を開始されたか
 */
-(void) videoPlaybackBeganInAd: (ALAd*) ad {
    AdapterTrace;
    // 広告の読み
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

/**
 *  広告の終了・停止時に呼ばれる
 *  パーセント、読み込み終わりの設定を表示
 */
-(void) videoPlaybackEndedInAd: (ALAd*) ad atPlaybackPercent: (NSNumber*) percentPlayed fullyWatched: (BOOL) wasFullyWatched {
    AdapterTraceP(@"atPlaybackPercent : %@, fullyWatched : %d", percentPlayed, wasFullyWatched);
    if ( wasFullyWatched ) {
        [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    }
}

@end

@implementation MovieReward6011
@end

@implementation MovieReward6012
@end

@implementation MovieReward6013
@end

@implementation MovieReward6014
@end

@implementation MovieReward6015
@end

@implementation MovieReward6210
@end

@implementation MovieReward6211
@end

@implementation MovieReward6212
@end

@implementation MovieReward6213
@end
