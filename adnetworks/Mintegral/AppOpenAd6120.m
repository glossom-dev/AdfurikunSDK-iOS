//
//  AppOpenAd6120.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2023/03/20.
//  Copyright © 2023 Glossom, Inc. All rights reserved.
//

#import "AppOpenAd6120.h"
#import "AdnetworkParam6120.h"

@interface AppOpenAd6120()

@property (nonatomic) AdnetworkParam6120 *adParam;
@property (nonatomic) MTGSplashAD *splashAd;

@end

@implementation AppOpenAd6120

// SDKからバージョンを取得して返す
// APIがなければ削除
+ (NSString *)getSDKVersion {
    return MTGSDK.sdkVersion;
}

// Adapterのバージョン。最初は1にして、修正がある度＋1にする
+ (NSString *)getAdapterRevisionVersion {
    return @"2";
}

// getinfoからのParameter設定
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6120 alloc] initWithParam:data];
}

// 広告準備有無を返す
- (BOOL)isPrepared {
    // ロジックに合わせて修正する
    return self.isAdLoaded && self.splashAd && self.splashAd.isADReadyToShow;
}

// Adnetwork SDKの初期化を行う
- (void)initAdnetworkIfNeeded {
    // 一回のみ初期化を行うようなチェックを行う
    if (![self needsToInit]) {
        return;
    }
    
    if (!self.adParam || ![self.adParam isValid]) {
        return;
    }
    
    // Adnetwork SDKの関数を呼び出す際はTryーCatchでException Handlingを行う
    @try {
        // 非同期で初期化が行われる場合にはFlag設定を行う
        [self requireToAsyncInit]; // 要らない場合には消す
        
        [MTGSDK.sharedInstance setAppID:self.adParam.appId ApiKey:self.adParam.appKey];
        // 初期化が完了するとこの関数を呼び出す
        [self initCompleteAndRetryStartAdIfNeeded]; // 適切なタイミングに移動する
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }

}

// 広告呼び込みを行う
- (void)startAd {
    // 初期化が完了しているかをチェック
    if (![self canStartAd]) {
        return;
    }
    
    if (!self.adParam || ![self.adParam isValid]) {
        return;
    }
    
    [super startAd];
    
    // Adnetwork SDKの関数を呼び出す際はTryーCatchでException Handlingを行う
    @try {
        // 非同期で行われる場合にはFlag設定を行う
        [self requireToAsyncRequestAd];
        
        if (self.splashAd) {
            self.splashAd = nil;
        }
        
        self.splashAd = [[MTGSplashAD alloc] initWithPlacementID:self.adParam.placementId
                                                          unitID:self.adParam.unitId
                                                       countdown:5
                                                       allowSkip:true];
        self.splashAd.delegate = self;
        [self.splashAd preload];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

// 広告再生関数
// showAdWithPresentingViewController と両方を必ず実装する
- (void)showAd {
    UIViewController *topVC = [self topMostViewController];
    if (topVC) {
        [self showAdWithPresentingViewController:topVC];
    } else {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    if (!self.adParam || ![self.adParam isValid] || !self.splashAd) {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
        return;
    }

    UIWindow *window = [self getKeyWindow];
    if (!window) {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
        return;
    }
    AdapterLogP(@"window : %@, rootVC : %@, topMostVC : %@", window, window.rootViewController, [self topMostViewController]);
    [super showAdWithPresentingViewController:viewController];
    
    @try {
        [self requireToAsyncPlay];
        
        [self.splashAd showInKeyWindow:window customView:nil];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

// Adnetwork SDKが設置されているかをチェックする
- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"MTGSplashAD");
    if (clazz) {
        AdapterLog(@"found Class: MTGSplashAD");
        return YES;
    } else {
        AdapterLog(@"Not found Class: MTGSplashAD");
        return NO;
    }
}

-(void)setHasUserConsent:(BOOL)hasUserConsent {
    [super setHasUserConsent:hasUserConsent];
    [MTGSDK.sharedInstance setConsentStatus:hasUserConsent];
    AdapterLogP(@"Adnetwork 6120, gdprConsent : %@, sdk setting value : %d", self.hasGdprConsent, (int)hasUserConsent);
}

- (void)isChildDirected:(BOOL)childDirected {
    [super isChildDirected:childDirected];
    [MTGSDK.sharedInstance setCoppa:childDirected ? MTGBoolYes : MTGBoolNo];
    AdapterLogP(@"Adnetwork %@, childDirected : %@, input parameter : %d", self.adnetworkKey, self.childDirected, (int)childDirected);
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
