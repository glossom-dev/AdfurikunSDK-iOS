//
//  MovieReward6008.m(Five)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import "MovieReward6008.h"
#import "AdnetworkConfigure6008.h"
#import "AdnetworkParam6008.h"

#import <ADFMovieReward/ADFMovieOptions.h>

@interface MovieReward6008()

@property (nonatomic) FADVideoReward *fullscreen;

@end

@implementation MovieReward6008


// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"7";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"FADVideoReward";
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

        if (self.fullscreen) {
            self.fullscreen = nil;
        }

        self.fullscreen = [[FADVideoReward alloc] initWithSlotId:((AdnetworkParam6008 *)self.adParam).fiveSlotId];
        [self.fullscreen setLoadDelegate:self];
        [self.fullscreen setEventListener:self];
        
        //音出力設定
        AdapterLogP(@"soundState: %d", (int)[ADFMovieOptions getSoundState]);
        ADFMovieOptions_Sound soundState = [ADFMovieOptions getSoundState];
        if (ADFMovieOptions_Sound_On == soundState) {
            [self.fullscreen enableSound:true];
        } else if (ADFMovieOptions_Sound_Off == soundState) {
            [self.fullscreen enableSound:false];
        }
        [self.fullscreen loadAdAsync];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
    return true;
}

// 在庫取得有無を返す
- (BOOL)isPrepared {
    if(![((AdnetworkParam6008 *)self.adParam).submittedPackageName isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
        //表示を消したい場合は、こちらをコメントアウトして下さい。
        AdapterLogP(@"[SEVERE] [Five]アプリのバンドルIDが、申請されたもの（%@）と異なります。", ((AdnetworkParam6008 *)self.adParam).submittedPackageName);
    }
    
    if (self.fullscreen) {
        return self.isAdLoaded && self.fullscreen.state == kFADStateLoaded;
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
    
    if (!self.fullscreen) {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
        return;
    }

    if ([self isPrepared]) {
        @try {
            [self requireToAsyncPlay];
            [self.fullscreen showWithViewController:viewController];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    } else {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
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

#pragma mark FADVideoRewardEventListener
- (void)fiveVideoRewardAd:(nonnull FADVideoReward*)ad didFailedToShowAdWithError:(FADErrorCode) errorCode {
    // エラー時の処理
    AdapterLogP(@"errorCode: %ld, slotId: %@", (long)errorCode, ((AdnetworkParam6008 *)self.adParam).fiveSlotId);
    [self setErrorWithMessage:nil code:errorCode];
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}

- (void)fiveVideoRewardAdDidReward:(nonnull FADVideoReward*)ad {
    // 【新規】リワード付与の処理
    AdapterTrace;
    // 静止画の場合fiveVideoRewardAdDidViewThroughが発生しないため、Reward CallbackでFinishも発生させる
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    [self setCallbackStatus:MovieRewardCallbackClose];
}

- (void)fiveVideoRewardAdDidImpression:(nonnull FADVideoReward*)ad {
    // インプレッション時の処理
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)fiveVideoRewardAdDidClick:(nonnull FADVideoReward*)ad {
    // クリック時の処理
    AdapterTrace;
}

- (void)fiveVideoRewardAdFullScreenDidOpen:(nonnull FADVideoReward*)ad {
    // 【新規】フルスクリーン広告ビューオープン時の処理
    AdapterTrace;
}

- (void)fiveVideoRewardAdFullScreenDidClose:(nonnull FADVideoReward*)ad {
    // フルスクリーン広告ビュークローズ時の処理
    AdapterTrace;
}

- (void)fiveVideoRewardAdDidPlay:(nonnull FADVideoReward*)ad {
    // 再生開始時の処理（動画広告のみ）
    AdapterTrace;
}

- (void)fiveVideoRewardAdDidPause:(nonnull FADVideoReward*)ad {
    // 一時停止時の処理（動画広告のみ）
    AdapterTrace;
}

- (void)fiveVideoRewardAdDidViewThrough:(nonnull FADVideoReward*)ad {
    // 再生完了時の処理（動画広告のみ）
    AdapterTrace;
    
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
}

@end

@implementation MovieReward6070
@end

@implementation MovieReward6071
@end

@implementation MovieReward6072
@end

@implementation MovieReward6073
@end

@implementation MovieReward6074
@end

@implementation MovieReward6075
@end

@implementation MovieReward6076
@end

@implementation MovieReward6077
@end

@implementation MovieReward6078
@end

@implementation MovieReward6079
@end
