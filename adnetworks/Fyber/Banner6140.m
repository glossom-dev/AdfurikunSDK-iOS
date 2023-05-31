//
//  Banner6140.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2023/02/08.
//  Copyright © 2023 Glossom, Inc. All rights reserved.
//

#import "Banner6140.h"
#import "AdnetworkParam6140.h"

@interface Banner6140()

@property (nonatomic) AdnetworkParam6140 *adParam;

@property (nonatomic, strong) IAAdSpot *adSpot;
@property (nonatomic, strong) IAViewUnitController *viewUnitController;
@property (nonatomic, strong) IAMRAIDContentController *mraidContentController;

@end

@implementation Banner6140

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

// startAdが呼ばれるたびにStatus初期化が必要な場合こちらで実装する
- (void)clearStatusIfNeeded {
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
    
    [super startAd];
    
    if (self.adParam == nil || ![self.adParam isValid]) {
        return;
    }
    
    // Adnetwork SDKの関数を呼び出す際はTryーCatchでException Handlingを行う
    @try {
        // 非同期で行われる場合にはFlag設定を行う
        [self requireToAsyncRequestAd];
        
        if (self.adSpot == nil) {
            IAAdRequest *request = [IAAdRequest build:^(id<IAAdRequestBuilder>  _Nonnull builder) {
                builder.spotID = self.adParam.placementId;
            }];
            
            self.mraidContentController = [IAMRAIDContentController build: ^(id<IAMRAIDContentControllerBuilder>  _Nonnull builder) {
               builder.MRAIDContentDelegate = self;
            }];
            
            self.viewUnitController = [IAViewUnitController build:^(id<IAViewUnitControllerBuilder>  _Nonnull builder) {
                builder.unitDelegate = self;
                [builder addSupportedContentController:self.mraidContentController];
            }];

            self.adSpot = [IAAdSpot build:^(id<IAAdSpotBuilder>  _Nonnull builder) {
                builder.adRequest = request;
                [builder addSupportedUnitController:self.viewUnitController];
            }];
        }
        
        __weak typeof(self) weakSelf = self;
        [self.adSpot fetchAdWithCompletion:^(IAAdSpot * _Nullable adSpot, IAAdModel * _Nullable adModel, NSError * _Nullable error) {
            AdapterLogP(@"error : %@", error);
            if (error == nil && adSpot.activeUnitController == weakSelf.viewUnitController && weakSelf.viewUnitController.adView) {
                NativeAdInfo6140 *info = [[NativeAdInfo6140 alloc] initWithVideoUrl:nil
                                                                              title:@""
                                                                        description:@""
                                                                       adnetworkKey:@"6140"];
                info.mediaType = ADFNativeAdType_Image;
                [info setupMediaView:weakSelf.viewUnitController.adView];
                [weakSelf setCustomMediaview:weakSelf.viewUnitController.adView];
                
                info.adapter = weakSelf;
                info.isCustomComponentSupported = weakSelf;
                
                weakSelf.adInfo = info;
                
                [weakSelf setCallbackStatus:NativeAdCallbackLoadFinish];
                return;
            }
            if (error) {
                [weakSelf setErrorWithMessage:error.localizedDescription code:error.code];
            }
            [weakSelf setCallbackStatus:NativeAdCallbackLoadError];
        }];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (void)startAdWithOption:(NSDictionary *)option {
    [self startAd];
}

-(void)setHasUserConsent:(BOOL)hasUserConsent {
    [super setHasUserConsent:hasUserConsent];
    [IASDKCore.sharedInstance setGDPRConsent:hasUserConsent];
    AdapterLogP(@"Adnetwork 6140, gdprConsent : %@, sdk setting value : %d", self.hasGdprConsent, (int)hasUserConsent);
}

// Adnetwork SDKが設置されているかをチェックする
- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"IAMRAIDContentController");
    if (clazz) {
        AdapterLog(@"found Class: IAMRAIDContentController");
        return YES;
    } else {
        AdapterLog(@"Not found Class: IAMRAIDContentController");
        return NO;
    }
}

- (void)dispose {
    
}

/*
 * Adnetwork SDKからのCallbackに合わせてStatusを設定する
 [self setCallbackStatus:CALLBACKSTATUS]
 NativeAdCallbackLoadFinish：読み込み完了
 nativeAdInfoSetting Snippetを使って、NativeAdInfoを作成する
 NativeAdCallbackLoadError：読み込み失敗
 NativeAdCallbackRendering：画面に広告表示開始
 NativeAdCallbackPlayStart：動作再生開始、静止画のViewability Impression
 NativeAdCallbackPlayFinish：動画再生完了
 NativeAdCallbackPlayFail：再生失敗
 NativeAdCallbackClick：広告クリック
 */

#pragma mark - IAUnitDelegate
- (UIViewController * _Nonnull)IAParentViewControllerForUnitController:(IAUnitController * _Nullable)unitController {
    AdapterTrace;
    return [self topMostViewController];
}

- (void)IAAdDidReceiveClick:(IAUnitController * _Nullable)unitController {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackClick];
}

- (void)IAAdWillLogImpression:(IAUnitController * _Nullable)unitController {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackRendering];
    [self startViewabilityCheck];
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
}

- (void)IAUnitControllerWillOpenExternalApp:(IAUnitController * _Nullable)unitController {
    AdapterTrace;
}

- (void)IAAdDidExpire:(IAUnitController * _Nullable)unitController {
    AdapterTrace;
    self.isAdLoaded = false;
}

#pragma mark - IAMRAIDContentDelegate
- (void)IAMRAIDContentController:(IAMRAIDContentController * _Nullable)contentController MRAIDAdWillResizeToFrame:(CGRect)frame {
    AdapterTrace;
}

- (void)IAMRAIDContentController:(IAMRAIDContentController * _Nullable)contentController MRAIDAdDidResizeToFrame:(CGRect)frame {
    AdapterTrace;
}

- (void)IAMRAIDContentController:(IAMRAIDContentController * _Nullable)contentController MRAIDAdWillExpandToFrame:(CGRect)frame {
    AdapterTrace;
}

- (void)IAMRAIDContentController:(IAMRAIDContentController * _Nullable)contentController MRAIDAdDidExpandToFrame:(CGRect)frame {
    AdapterTrace;
}

- (void)IAMRAIDContentControllerMRAIDAdWillCollapse:(IAMRAIDContentController * _Nullable)contentController {
    AdapterTrace;
}

- (void)IAMRAIDContentControllerMRAIDAdDidCollapse:(IAMRAIDContentController * _Nullable)contentController {
    AdapterTrace;
}

- (void)IAMRAIDContentController:(IAMRAIDContentController * _Nullable)contentController videoInterruptedWithError:(NSError * _Nonnull)error {
    AdapterTrace;
}

@end

@implementation NativeAdInfo6140

@end

@implementation Banner6141
@end

@implementation Banner6142
@end

@implementation Banner6143
@end

@implementation Banner6144
@end

@implementation Banner6145
@end
