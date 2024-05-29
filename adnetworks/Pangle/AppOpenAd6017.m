//
//  AppOpenAd6017.m
//  MovieRewardTestApp
//
//  Copyright © 2023 Glossom, Inc. All rights reserved.
//

#import "AppOpenAd6017.h"
#import "AdnetworkConfigure6017.h"
#import "AdnetworkParam6017.h"

#import <PAGAdSDK/PAGAdSDK.h>

#define kLoadTimeoutDefault 3

@interface AppOpenAd6017 ()<PAGLAppOpenAdDelegate>

@property (nonatomic, strong) PAGLAppOpenAd *openAd;

// ロードタイムアウト秒数
@property (nonatomic) NSTimeInterval timeout;

@end

@implementation AppOpenAd6017


// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"9";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"PAGLAppOpenAd";
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
    ((AdnetworkConfigure6017 *)self.configure).logoImage = self.logoImage;
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
    return [self startAdWithOption:nil];
}

- (bool)startAdWithOption:(NSDictionary *)option {
    if (![super startAd]) { // 読み込みが可能な状態かをチェックする
        return false;
    }
    
    if (self.openAd) {
        self.openAd = nil;
    }

    @try {
        [self requireToAsyncRequestAd];
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf = weakSelf;
            if (!strongSelf) return;
            if (option) {
                AdapterLogP(@"custom event option : %@", option);
                NSNumber *timeout = option[@"timeout"];
                if ([strongSelf isNumber:timeout]) {
                    strongSelf.timeout = [timeout doubleValue];
                }
            }
            if (strongSelf.timeout <= 0) {
                strongSelf.timeout = kLoadTimeoutDefault;
            }
            
            PAGAppOpenRequest *request = [PAGAppOpenRequest request];
            __weak typeof(self) weakSelf = self;
            [PAGLAppOpenAd loadAdWithSlotID:((AdnetworkParam6017 *)self.adParam).slotID
                                    request:request
                          completionHandler:^(PAGLAppOpenAd * _Nullable appOpenAd, NSError * _Nullable error) {
                __strong typeof(self) strongSelf = weakSelf;
                if (!strongSelf) return;
                AdapterLogP(@"Ad load is completed : %@", appOpenAd);
                if (strongSelf.isAdLoaded) {
                    AdapterLog(@"Ad is already loaded");
                    return;
                }
                if (error) {
                    AdapterTraceP(@"error : %@", error);
                    [strongSelf setErrorWithMessage:error.localizedDescription code:error.code];
                    [strongSelf setCallbackStatus:MovieRewardCallbackFetchFail];
                    return;
                } else if (appOpenAd == nil) {
                    NSString *errorMsg = @"appOpenAd is nil";
                    AdapterTraceP(@"error : %@", errorMsg);
                    [strongSelf setErrorWithMessage:errorMsg code:0];
                    [strongSelf setCallbackStatus:MovieRewardCallbackFetchFail];
                    return;
                }
                strongSelf.isAdLoaded = YES;
                strongSelf.openAd = appOpenAd;
                strongSelf.openAd.delegate = self;
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
    
    if (!self.openAd) {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
        return;
    }

    if ([self isPrepared]) {
        @try {
            [self requireToAsyncPlay];
            [self.openAd presentFromRootViewController:viewController];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    } else {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

#pragma mark PAGLAppOpenAdDelegate

- (void)adDidShow:(PAGLAppOpenAd *)ad {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)adDidClick:(PAGLAppOpenAd *)ad {
    AdapterTrace;
}

- (void)adDidDismiss:(PAGLAppOpenAd *)ad {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    [self setCallbackStatus:MovieRewardCallbackClose];
}

@end

@implementation AppOpenAd6090
@end

@implementation AppOpenAd6091
@end

@implementation AppOpenAd6092
@end

@implementation AppOpenAd6093
@end

@implementation AppOpenAd6094
@end
