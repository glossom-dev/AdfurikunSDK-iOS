//
//  MovieInterstitial6008.m(Five)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import "MovieInterstitial6008.h"
#import "AdnetworkConfigure6008.h"
#import "AdnetworkParam6008.h"

#import <ADFMovieReward/ADFMovieOptions.h>

@interface MovieInterstitial6008()

@property (nonatomic)FADInterstitial *interstitial;

@end

@implementation MovieInterstitial6008

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"17";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"FADInterstitial";
}

// ADFで定義しているAdnetwork名。
+ (NSString *)adnetworkName {
    return [AdnetworkConfigure6008 adnetworkName];
}

+ (NSString *)getSDKVersion {
    return [AdnetworkConfigure6008 getSDKVersion];
}

// Instance Variableを初期化する。また、必要な場合Configureを生成する
-(id)init {
    self = [super init];
    if (self) {
        self.configure = [AdnetworkConfigure6008 sharedInstance];
    }
    return self;
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6008 alloc] initWithParam:data];
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
        
        if (self.interstitial) {
            self.interstitial = nil;
        }

        self.interstitial = [[FADInterstitial alloc] initWithSlotId:((AdnetworkParam6008 *)self.adParam).fiveSlotId];
        [self.interstitial setLoadDelegate:self];
        [self.interstitial setEventListener:self];
        //音出力設定
        AdapterLogP(@"soundState: %d", (int)[ADFMovieOptions getSoundState]);
        ADFMovieOptions_Sound soundState = [ADFMovieOptions getSoundState];
        if (ADFMovieOptions_Sound_On == soundState) {
            [self.interstitial enableSound:true];
        } else if (ADFMovieOptions_Sound_Off == soundState) {
            [self.interstitial enableSound:false];
        }
        
        [self.interstitial loadAdAsync];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
    return true;
}

// 在庫取得有無を返す
- (BOOL)isPrepared {
    //申請済のバンドルIDと異なる場合のメッセージ
    //(バンドルIDが申請済のものと異なると、正常に広告が返却されない可能性があります)
    if(![((AdnetworkParam6008 *)self.adParam).submittedPackageName isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
        //表示を消したい場合は、こちらをコメントアウトして下さい。
        AdapterLogP(@"[SEVERE] [Five]アプリのバンドルIDが、申請されたもの（%@）と異なります。", ((AdnetworkParam6008 *)self.adParam).submittedPackageName);
    }
    
    if (self.interstitial) {
        return self.isAdLoaded && self.interstitial.state == kFADStateLoaded;
    }
    return false;
}

// 広告再生
- (void)showAd {
    UIViewController *vc = [self topMostViewController];
    if (vc) {
        [self showAdWithPresentingViewController:vc];
    } else {
        AdapterLog(@"top most viewcontroller is nil");
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
            [self.interstitial showWithViewController:viewController];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    }
}

#pragma mark - FiveDelegate
- (void)fiveAdDidLoad:(id<FADAdInterface>)ad {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

- (void)fiveAd:(id<FADAdInterface>)ad didFailedToReceiveAdWithError:(FADErrorCode)errorCode {
    AdapterLogP(@"errorCode: %ld, slotId: %@", (long)errorCode, ((AdnetworkParam6008 *)self.adParam).fiveSlotId);
    [self setErrorWithMessage:nil code:errorCode];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

#pragma mark FADInterstitialEventListener
- (void)fiveInterstitialAd:(nonnull FADInterstitial*)ad didFailedToShowAdWithError:(FADErrorCode) errorCode {
    // エラー時の処理
    AdapterTrace;
    AdapterLogP(@"errorCode: %ld, slotId: %@", (long)errorCode, ((AdnetworkParam6008 *)self.adParam).fiveSlotId);
    [self setErrorWithMessage:nil code:errorCode];
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}

- (void)fiveInterstitialAdDidImpression:(nonnull FADInterstitial*)ad {
    // インプレッション時の処理
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)fiveInterstitialAdDidClick:(nonnull FADInterstitial*)ad {
    // クリック時の処理
    AdapterTrace;
}

- (void)fiveInterstitialAdFullScreenDidOpen:(nonnull FADInterstitial*)ad {
    // 【新規】フルスクリーン広告ビューオープン時の処理
    AdapterTrace;
}
- (void)fiveInterstitialAdFullScreenDidClose:(nonnull FADInterstitial*)ad {
    // フルスクリーン広告ビュークローズ時の処理
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackClose];
}

- (void)fiveInterstitialAdDidPlay:(nonnull FADInterstitial*)ad {
    // 再生開始時の処理（動画広告のみ）
    AdapterTrace;
}

- (void)fiveInterstitialAdDidPause:(nonnull FADInterstitial*)ad {
    // 一時停止時の処理（動画広告のみ）
    AdapterTrace;
}

- (void)fiveInterstitialAdDidViewThrough:(nonnull FADInterstitial*)ad {
    // 再生完了時の処理（動画広告のみ）
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
}

@end

@implementation MovieInterstitial6070
@end

@implementation MovieInterstitial6071
@end

@implementation MovieInterstitial6072
@end

@implementation MovieInterstitial6073
@end

@implementation MovieInterstitial6074
@end

@implementation MovieInterstitial6075
@end

@implementation MovieInterstitial6076
@end

@implementation MovieInterstitial6077
@end

@implementation MovieInterstitial6078
@end

@implementation MovieInterstitial6079
@end
