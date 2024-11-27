//
//  MovieReward6140.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2022/10/03.
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import "MovieReward6140.h"
#import "AdnetworkConfigure6140.h"
#import "AdnetworkParam6140.h"

@interface MovieReward6140()

@property (nonatomic, strong) IAAdSpot *adSpot;
@property (nonatomic, strong) IAFullscreenUnitController *unitController;
@property (nonatomic, strong) IAVideoContentController *videoContentController;

@end

@implementation MovieReward6140

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"7";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"IAFullscreenUnitController";
}

// ADFで定義しているAdnetwork名。
+ (NSString *)adnetworkName {
    return [AdnetworkConfigure6140 adnetworkName];
}

+ (NSString *)getSDKVersion {
    return [AdnetworkConfigure6140 getSDKVersion];
}

// Instance Variableを初期化する。また、必要な場合Configureを生成する
-(id)init {
    self = [super init];
    if (self) {
        self.configure = [AdnetworkConfigure6140 sharedInstance];
    }
    return self;
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6140 alloc] initWithParam:data];
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
        
    [self.configure soundControl];
    
    @try {
        [self requireToAsyncRequestAd];
        
        if (self.adSpot == nil) {
            IAAdRequest *request = [IAAdRequest build:^(id<IAAdRequestBuilder>  _Nonnull builder) {
                builder.spotID = ((AdnetworkParam6140 *)self.adParam).placementId;
            }];
            self.videoContentController = [IAVideoContentController build:^(id<IAVideoContentControllerBuilder>  _Nonnull builder) {
                builder.videoContentDelegate = self;
            }];
            self.unitController = [IAFullscreenUnitController build:^(id<IAFullscreenUnitControllerBuilder>  _Nonnull builder) {
                builder.unitDelegate = self;
                [builder addSupportedContentController:self.videoContentController];
            }];
            self.adSpot = [IAAdSpot build:^(id<IAAdSpotBuilder>  _Nonnull builder) {
                builder.adRequest = request;
                [builder addSupportedUnitController:self.unitController];
            }];
        }
        
        __weak typeof(self) weakSelf = self;
        [self.adSpot fetchAdWithCompletion:^(IAAdSpot * _Nullable adSpot, IAAdModel * _Nullable adModel, NSError * _Nullable error) {
            AdapterLogP(@"error : %@", error);
            __strong typeof(self) strongSelf = weakSelf;
            if (!strongSelf) return;
            if (error) {
                [strongSelf setErrorWithMessage:error.localizedDescription code:error.code];
                [strongSelf setCallbackStatus:MovieRewardCallbackFetchFail];
                return;
            }
            [strongSelf setCallbackStatus:MovieRewardCallbackFetchComplete];
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
    [super showAd];
    
    if (!self.unitController) {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
        return;
    }

    if ([self isPrepared]) {
        @try {
            [self requireToAsyncPlay];
            [self.unitController showAdAnimated:true completion:nil];
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

- (NSString *)getPlayingAdCreativeId {
    return [AdnetworkConfigure6140.sharedInstance creativeId];
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

#pragma mark - IAUnitDelegate

- (UIViewController * _Nonnull)IAParentViewControllerForUnitController:(IAUnitController * _Nullable)unitController {
    AdapterTrace;
    return [self topMostViewController];
}

- (void)IAAdDidReceiveClick:(IAUnitController * _Nullable)unitController {
    AdapterTrace;
}

- (void)IAAdWillLogImpression:(IAUnitController * _Nullable)unitController {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)IAAdDidReward:(IAUnitController * _Nullable)unitController {
    AdapterTrace;
}

- (void)IAUnitControllerWillPresentFullscreen:(IAUnitController * _Nullable)unitController {
    AdapterTrace;
}

- (void)IAUnitControllerDidPresentFullscreen:(IAUnitController * _Nullable)unitController {
    AdapterTrace;
}

- (void)IAUnitControllerWillDismissFullscreen:(IAUnitController * _Nullable)unitController {
    AdapterTrace;
}

- (void)IAUnitControllerDidDismissFullscreen:(IAUnitController * _Nullable)unitController {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackClose];
}

- (void)IAUnitControllerWillOpenExternalApp:(IAUnitController * _Nullable)unitController {
    AdapterTrace;
}

- (void)IAAdDidExpire:(IAUnitController * _Nullable)unitController {
    AdapterTrace;
    self.isAdLoaded = false;
}

#pragma mark - IAVideoContentDelegate

- (void)IAVideoCompleted:(IAVideoContentController * _Nullable)contentController {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
}

- (void)IAVideoContentController:(IAVideoContentController * _Nullable)contentController videoInterruptedWithError:(NSError * _Nonnull)error {
    AdapterTrace;
}

- (void)IAVideoContentController:(IAVideoContentController * _Nullable)contentController videoDurationUpdated:(NSTimeInterval)videoDuration {
    AdapterTrace;
}

- (void)IAVideoContentController:(IAVideoContentController * _Nullable)contentController videoProgressUpdatedWithCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
}

@end

@implementation MovieReward6141
@end

@implementation MovieReward6142
@end

@implementation MovieReward6143
@end

@implementation MovieReward6144
@end

@implementation MovieReward6145
@end

@implementation MovieReward6146
@end

@implementation MovieReward6147
@end

@implementation MovieReward6148
@end

@implementation MovieReward6149
@end
