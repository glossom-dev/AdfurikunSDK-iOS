//
//  MovieReward6017.m
//  MovieRewardTestApp
//
//  Created by Ren Fujii on 2019/08/20.
//  Copyright © 2019 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import "MovieReward6017.h"
#import "AdnetworkConfigure6017.h"
#import "AdnetworkParam6017.h"

#import <PAGAdSDK/PAGAdSDK.h>

@interface MovieReward6017 ()<PAGRewardedAdDelegate>

@property (nonatomic, strong) PAGRewardedAd *rewardedVideoAd;

@end

@implementation MovieReward6017

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"18";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"PAGRewardedAd";
}

// ADFで定義しているAdnetwork名。
+ (NSString *)adnetworkName {
    return [AdnetworkConfigure6017 adnetworkName];
}

+ (NSString *)getSDKVersion {
    return [AdnetworkConfigure6017 getSDKVersion];
}

// Instance Variableを初期化する。また、必要な場合Configureを生成する
-(id)init {
    self = [super init];
    if (self) {
        self.configure = [AdnetworkConfigure6017 sharedInstance];
    }
    return self;
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6017 alloc] initWithParam:data];
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
    
    if (self.rewardedVideoAd) {
        self.rewardedVideoAd = nil;
    }

    @try {
        [self requireToAsyncRequestAd];
        dispatch_async(dispatch_get_main_queue(), ^{
            PAGRewardedRequest *request = [PAGRewardedRequest request];
            __weak typeof(self) weakSelf = self;
            [PAGRewardedAd loadAdWithSlotID:((AdnetworkParam6017 *)self.adParam).slotID
                                    request:request
                          completionHandler:^(PAGRewardedAd * _Nullable rewardedAd, NSError * _Nullable error) {
                __strong typeof(self) strongSelf = weakSelf;
                if (!strongSelf) return;

                // Load Fail
                if (error) {
                    AdapterTraceP(@"error : %@", error);
                    [strongSelf setErrorWithMessage:error.localizedDescription code:error.code];
                    [strongSelf setCallbackStatus:MovieRewardCallbackFetchFail];
                    return;
                } else if (rewardedAd == nil) {
                    NSString *errorMsg = @"rewardedAd is nil";
                    AdapterTraceP(@"error : %@", errorMsg);
                    [strongSelf setErrorWithMessage:errorMsg code:0];
                    [strongSelf setCallbackStatus:MovieRewardCallbackFetchFail];
                    return;
                }

                // Load Success
                AdapterTrace;
                strongSelf.rewardedVideoAd = rewardedAd;
                strongSelf.rewardedVideoAd.delegate = strongSelf;
                [strongSelf setCallbackStatus:MovieRewardCallbackFetchComplete];
            }];
        });
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
    UIViewController *topVC = [self topMostViewController];
    if (topVC) {
        [self showAdWithPresentingViewController:topVC];
    } else {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAdWithPresentingViewController:viewController];
    
    if (!self.rewardedVideoAd) {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
        return;
    }

    if ([self isPrepared]) {
        @try {
            [self requireToAsyncPlay];
            
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf = weakSelf;
                if (!strongSelf) return;
                [strongSelf.rewardedVideoAd presentFromRootViewController:viewController];
            });
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    } else {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

#pragma mark - PAGRewardedAdDelegate

- (void)adDidShow:(PAGRewardedAd *)ad {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)adDidClick:(PAGRewardedAd *)ad {
    AdapterTrace;
}

- (void)adDidDismiss:(PAGRewardedAd *)ad {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackClose];
}

- (void)rewardedAd:(PAGRewardedAd *)rewardedAd userDidEarnReward:(PAGRewardModel *)rewardModel {
    AdapterTraceP(@"reward earned! rewardName:%@ rewardMount:%ld",rewardModel.rewardName,(long)rewardModel.rewardAmount);
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
}

- (void)rewardedAd:(PAGRewardedAd *)rewardedAd userEarnRewardFailWithError:(NSError *)error {
    AdapterTraceP(@"reward earned failed. Error:%@",error);
    if (error) {
        AdapterTraceP(@"error : %@", error);
        [self setErrorWithMessage:error.localizedDescription code:error.code];
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

@end

@implementation MovieReward6090
@end

@implementation MovieReward6091
@end

@implementation MovieReward6092
@end

@implementation MovieReward6093
@end

@implementation MovieReward6094
@end

@implementation MovieReward6095
@end

@implementation MovieReward6096
@end

@implementation MovieReward6097
@end

@implementation MovieReward6098
@end

typedef enum : NSUInteger {
    initializeNotYet,
    initializing,
    initializeComplete,
} PangleInitializeStatus;

@interface MovieConfigure6017()

@property (nonatomic) PangleInitializeStatus initStatus;
@property (nonatomic) NSMutableArray <completionHandlerType> *handlers;

@end

@implementation MovieConfigure6017
+ (instancetype)sharedInstance {
    static MovieConfigure6017 *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.initStatus = initializeNotYet;
        self.handlers = [NSMutableArray new];
    }
    return self;
}

- (void)configureWithAppId:(NSString *)appId
                gdprStatus:(NSNumber *)gdprStatus
             childDirected:(NSNumber * _Nullable)childDirected
              appLogoImage:(UIImage * _Nullable)logoImage
                completion:(completionHandlerType)completionHandler {
    if (!appId || !completionHandler) {
        return;
    }
    
    if (self.initStatus == initializeComplete) {
        completionHandler();
        return;
    }
    
    if (self.initStatus == initializing) {
        [self.handlers addObject:completionHandler];
        return;
    }
    
    if (self.initStatus == initializeNotYet) {
        self.initStatus = initializing;
        [self.handlers addObject:completionHandler];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @try {
                PAGConfig *configuration = [PAGConfig shareConfig];
                if (gdprStatus) {
                    configuration.GDPRConsent = gdprStatus.boolValue ? PAGGDPRConsentTypeConsent : PAGGDPRConsentTypeNoConsent;
                    NSLog(@"[ADF] Adnetwork 6017, gdprConsent : %@, sdk setting value : %d", gdprStatus, (int)configuration.GDPRConsent);
                }
                if (childDirected) {
                    configuration.childDirected = childDirected.boolValue ? PAGChildDirectedTypeChild : PAGChildDirectedTypeNonChild;
                    NSLog(@"[ADF] Adnetwork 6017, childDirected : %@, sdk setting value : %d", childDirected, (int)configuration.childDirected);
                }
                configuration.debugLog = false;
                configuration.appID = appId;
                if (logoImage) {
                    configuration.appLogoImage = logoImage;
                }
                [PAGSdk startWithConfig:configuration completionHandler:^(BOOL success, NSError * _Nonnull error) {
                    if (success) {
                        self.initStatus = initializeComplete;

                        for (completionHandlerType handler in self.handlers) {
                            handler();
                        }
                    }
                }];
            } @catch (NSException *exception) {
                NSLog(@"[ADF] adnetwork exception : %@", exception);
            }
        });
    }
}

@end
