//
//  Banner6140.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2023/02/08.
//  Copyright © 2023 Glossom, Inc. All rights reserved.
//

#import "Banner6140.h"
#import "AdnetworkConfigure6140.h"
#import "AdnetworkParam6140.h"

@interface Banner6140()

@property (nonatomic, strong) IAAdSpot *adSpot;
@property (nonatomic, strong) IAViewUnitController *viewUnitController;
@property (nonatomic, strong) IAMRAIDContentController *mraidContentController;

@end

@implementation Banner6140

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"6";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"IAMRAIDContentController";
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
    
    @try {
        [self requireToAsyncRequestAd];
        if (self.adSpot == nil) {
            IAAdRequest *request = [IAAdRequest build:^(id<IAAdRequestBuilder>  _Nonnull builder) {
                builder.spotID = ((AdnetworkParam6140 *)self.adParam).placementId;
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
            __strong typeof(self) strongSelf = weakSelf;
            if (!strongSelf) return;
            if (error == nil && adSpot.activeUnitController == strongSelf.viewUnitController && strongSelf.viewUnitController.adView) {
                NativeAdInfo6140 *info = [[NativeAdInfo6140 alloc] initWithVideoUrl:nil
                                                                              title:@""
                                                                        description:@""
                                                                       adnetworkKey:self.adnetworkKey];
                info.mediaType = ADFNativeAdType_Image;
                [info setupMediaView:strongSelf.viewUnitController.adView];
                [strongSelf setCustomMediaview:strongSelf.viewUnitController.adView];
                
                info.adapter = strongSelf;
                info.isCustomComponentSupported = strongSelf;
                
                strongSelf.adInfo = info;
                
                [strongSelf setCallbackStatus:NativeAdCallbackLoadFinish];
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
    return true;
}

- (bool)startAdWithOption:(NSDictionary *)option {
    return [self startAd];
}

- (NSString *)getPlayingAdCreativeId {
    return [AdnetworkConfigure6140.sharedInstance creativeId];
}

// 在庫取得有無を返す
- (BOOL)isPrepared {
    return self.isAdLoaded;
}

// 後処理を実装
- (void)dispose {
    [super dispose];
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
