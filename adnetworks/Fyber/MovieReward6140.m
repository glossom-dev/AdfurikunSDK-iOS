//
//  MovieReward6140.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2022/10/03.
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import "MovieReward6140.h"
#import "AdnetworkParam6140.h"

@interface MovieReward6140()

@property (nonatomic) AdnetworkParam6140 *adParam;

@property (nonatomic, strong) IAAdSpot *adSpot;
@property (nonatomic, strong) IAFullscreenUnitController *unitController;
@property (nonatomic, strong) IAVideoContentController *videoContentController;

@end

@implementation MovieReward6140

// SDKからバージョンを取得して返す
// APIがなければ削除
+ (NSString *)getSDKVersion {
    return [IASDKCore.sharedInstance version];
}

// Adapterのバージョン。最初は1にして、修正がある度＋1にする
+ (NSString *)getAdapterRevisionVersion {
    return @"2";
}

// getinfoからのParameter設定
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6140 alloc] initWithParam:data];
}

// 広告準備有無を返す
- (BOOL)isPrepared {
    // ロジックに合わせて修正する
    return self.isAdLoaded;
}

// Adnetwork SDKの初期化を行う
- (void)initAdnetworkIfNeeded {
    // 一回のみ初期化を行うようなチェックを行う
    if (![self needsToInit]) {
        return;
    }
    
    if (self.adParam == nil || ![self.adParam isValid]) {
        return;
    }
    
    if (IASDKCore.sharedInstance.isInitialised) {
        [self initCompleteAndRetryStartAdIfNeeded];
        return;
    }
    
    // Adnetwork SDKの関数を呼び出す際はTryーCatchでException Handlingを行う
    @try {
        // 非同期で初期化が行われる場合にはFlag設定を行う
        [self requireToAsyncInit]; // 要らない場合には消す
        
        [IASDKCore.sharedInstance initWithAppID:self.adParam.appId
                                completionBlock:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                [self initCompleteAndRetryStartAdIfNeeded];
                // COPPA関連設定はSDK初期化後にやるようにマニュアルに書いてる。
                if (self.childDirected) {
                    IASDKCore.sharedInstance.coppaApplies = self.childDirected.boolValue ? IACoppaAppliesTypeDenied : IACoppaAppliesTypeGiven;
                    AdapterLogP(@"Adnetwork %@, childDirected : %@", self.adnetworkKey, self.childDirected);
                }
            } else {
                AdapterLogP(@"init error (%@)", error);
            }
        } completionQueue:nil];
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
    
    if (self.adParam == nil || ![self.adParam isValid]) {
        return;
    }
    
    [super startAd];
    
    // Adnetwork SDKの関数を呼び出す際はTryーCatchでException Handlingを行う
    @try {
        // 非同期で行われる場合にはFlag設定を行う
        [self requireToAsyncRequestAd];

        if (self.adSpot == nil) {
            IAAdRequest *request = [IAAdRequest build:^(id<IAAdRequestBuilder>  _Nonnull builder) {
                builder.spotID = self.adParam.placementId;
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
            if (error) {
                [weakSelf setErrorWithMessage:error.localizedDescription code:error.code];
                [weakSelf setCallbackStatus:MovieRewardCallbackFetchFail];
                return;
            }
            [weakSelf setCallbackStatus:MovieRewardCallbackFetchComplete];
        }];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

// 広告再生関数
// showAdWithPresentingViewController と両方を必ず実装する
- (void)showAd {
    [super showAd];
    
    @try {
        [self requireToAsyncPlay];

        [self.unitController showAdAnimated:true completion:nil];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [self showAd];
}

-(void)setHasUserConsent:(BOOL)hasUserConsent {
    [super setHasUserConsent:hasUserConsent];
    [IASDKCore.sharedInstance setGDPRConsent:hasUserConsent];
    AdapterLogP(@"Adnetwork 6140, gdprConsent : %@, sdk setting value : %d", self.hasGdprConsent, (int)hasUserConsent);
}

// Adnetwork SDKが設置されているかをチェックする
- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"IAFullscreenUnitController");
    if (clazz) {
        AdapterLog(@"found Class: IAFullscreenUnitController");
        return YES;
    } else {
        AdapterLog(@"Not found Class: IAFullscreenUnitController");
        return NO;
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
