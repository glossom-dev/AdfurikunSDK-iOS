//
//  AppOpenAd6120.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2023/03/20.
//  Copyright © 2023 Glossom, Inc. All rights reserved.
//

#import "AppOpenAd6120.h"
#import "AdnetworkConfigure6120.h"
#import "AdnetworkParam6120.h"

@interface AppOpenAd6120()

@property (nonatomic) MTGSplashAD *splashAd;
@property (nonatomic) UIView *logoView;
@end

@implementation AppOpenAd6120


// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"6";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"MTGSplashAD";
}

// ADFで定義しているAdnetwork名。
+ (NSString *)adnetworkName {
    return [AdnetworkConfigure6120 adnetworkName];
}

+ (NSString *)getSDKVersion {
    return [AdnetworkConfigure6120 getSDKVersion];
}

// Instance Variableを初期化する。また、必要な場合Configureを生成する
-(id)init {
    self = [super init];
    if (self) {
        self.configure = [AdnetworkConfigure6120 sharedInstance];
    }
    return self;
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6120 alloc] initWithParam:data];
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
        
        NSString *placementId = ((AdnetworkParam6120 *)self.adParam).placementId;
        NSString *unitId = ((AdnetworkParam6120 *)self.adParam).unitId;

        if (self.splashAd) {
            self.splashAd = nil;
        }
        if (self.logoImage) {
            self.splashAd = [[MTGSplashAD alloc] initWithPlacementID:placementId
                                                              unitID:unitId
                                                           countdown:5
                                                           allowSkip:true
                                                      customViewSize:self.logoImage.size
                                                preferredOrientation:0];
            self.logoView = [[UIImageView alloc] initWithImage:self.logoImage];
        } else {
            self.splashAd = [[MTGSplashAD alloc] initWithPlacementID:placementId
                                                              unitID:unitId
                                                           countdown:5
                                                           allowSkip:true];
        }
        self.splashAd.delegate = self;
        [self.splashAd preload];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
    return true;
}

// 在庫取得有無を返す
- (BOOL)isPrepared {
    return self.isAdLoaded && self.splashAd && self.splashAd.isADReadyToShow;
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
    UIWindow *window = [self getKeyWindow];
    if (!window || !self.splashAd) {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
        return;
    }
    AdapterLogP(@"window : %@, rootVC : %@, topMostVC : %@", window, window.rootViewController, [self topMostViewController]);

    [super showAdWithPresentingViewController:viewController];
    
    if ([self isPrepared]) {
        @try {
            [self requireToAsyncPlay];
            [self.splashAd showInKeyWindow:window customView:self.logoView];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    } else {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
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

#pragma mark - MTGSplashADDelegate
- (void)splashADPreloadSuccess:(MTGSplashAD *)splashAD {
    AdapterTrace;
    self.creativeId = splashAD.creativeID;
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}
- (void)splashADPreloadFail:(MTGSplashAD *)splashAD error:(NSError *)error {
    AdapterTraceP(@"error : %@", error);
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

- (void)splashADLoadSuccess:(MTGSplashAD *)splashAD {
    AdapterTrace;
}
    
- (void)splashADLoadFail:(MTGSplashAD *)splashAD error:(NSError *)error {
    AdapterTraceP(@"error : %@", error);
}

- (void)splashADShowSuccess:(MTGSplashAD *)splashAD {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)splashADShowFail:(MTGSplashAD *)splashAD error:(NSError *)error {
    AdapterTraceP(@"errro : %@", error);
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
    return;
}

- (void)splashADDidLeaveApplication:(MTGSplashAD *)splashAD {
    AdapterTrace;
}

- (void)splashADDidClick:(MTGSplashAD *)splashAD {
    AdapterTrace;
}

- (void)splashADWillClose:(MTGSplashAD *)splashAD {
    AdapterTrace;
}

- (void)splashADDidClose:(MTGSplashAD *)splashAD {
    AdapterTrace;
    // OpenAdをクローズする時Finish BCを送信するためCallback statusをCompleteにする。アプリへのCallbackは発生しない
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    [self setCallbackStatus:MovieRewardCallbackClose];
}

- (void)splashAD:(MTGSplashAD *)splashAD timeLeft:(NSUInteger)time {
    AdapterTraceP(@"timeleft : %lud", time);
}

- (UIView *)superViewForSplashZoomOutADViewToAddOn:(MTGSplashAD *)splashAD {
    AdapterTrace;
    return nil;
}

- (CGPoint)pointForSplashZoomOutADViewToAddOn:(MTGSplashAD *)splashAD {
    return CGPointZero;
}

/* Called when splash zoomout view did show. */
- (void)splashZoomOutADViewDidShow:(MTGSplashAD *)splashAD {
    AdapterTrace;
}

/* Called when splash zoomout view is about to close. */
- (void)splashZoomOutADViewClosed:(MTGSplashAD *)splashAD {
    AdapterTrace;
}

@end

@implementation AppOpenAd6121
@end

@implementation AppOpenAd6122
@end

@implementation AppOpenAd6123
@end

@implementation AppOpenAd6124
@end

@implementation AppOpenAd6125
@end
