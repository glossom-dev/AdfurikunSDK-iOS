//
//  MovieReward6001.m(UnityAds)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//
#import <UIKit/UIKit.h>
#import "MovieReward6001.h"
#import "AdnetworkConfigure6001.h"
#import "AdnetworkParameter6001.h"

@implementation MovieReward6001

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"16";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"UnityAds.UnityAds";
}

// ADFで定義しているAdnetwork名。
+ (NSString *)adnetworkName {
    return [AdnetworkConfigure6001 adnetworkName];
}

+ (NSString *)getSDKVersion {
    return [AdnetworkConfigure6001 getSDKVersion];
}

// Instance Variableを初期化する。また、必要な場合Configureを生成する
-(id)init {
    self = [super init];
    if (self) {
        self.configure = [AdnetworkConfigure6001 sharedInstance];
    }
    return self;
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParameter6001 alloc] initWithParam:data];
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
        [UnityAds load:((AdnetworkParameter6001 *)self.adParam).placementId loadDelegate:self];
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
        [self setPlayFailCallbackTopVCGetFailed];
    }
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAdWithPresentingViewController:viewController];
    
    if (viewController != nil && self.isPrepared) {
        @try {
            [self requireToAsyncPlay];
            
            [UnityAds show:viewController placementId:((AdnetworkParameter6001 *)self.adParam).placementId showDelegate:self];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setPlayFailCallbackException:exception];
        }
    } else {
        AdapterLog(@"Error encountered playing ad : could not fetch topmost viewcontroller");
        [self setPlayFailCallbackTopVCGetFailed];
    }
}

-(void)sendFetchComplete {
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

-(void)sendFetchFail {
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

#pragma mark: UnityAdsLoadDelegate
- (void)unityAdsAdLoaded: (NSString *)placementId {
    AdapterTraceP(@"object : %@, placement Id : %@", self, placementId);
    if ([((AdnetworkParameter6001 *)self.adParam).placementId isEqualToString:placementId]) {
        [self sendFetchComplete];
    } else {
        AdapterLogP(@"unityAdsAdLoaded(%@), but placemendId(%@) is not equal to %@", self, placementId, ((AdnetworkParameter6001 *)self.adParam).placementId);
    }
}

- (void)unityAdsAdFailedToLoad: (NSString *)placementId
                     withError: (UnityAdsLoadError)error
                   withMessage: (NSString *)message {
    AdapterTraceP(@"unityAdsAdFailedToLoad : %@, placement Id : %@, message : %@", self, placementId, message);
    [self setErrorWithMessage:message code:0];
    [self sendFetchFail];
}

#pragma mark: UnityAdsShowDelegate
- (void)unityAdsShowComplete:(NSString *)placementId withFinishState:(UnityAdsShowCompletionState)state {
    AdapterTraceP(@"unityAdsShowComplete : UnityAdsShowDelegate unityAdsShowComplete %@ %ld", placementId, state);
    switch (state) {
        case kUnityShowCompletionStateCompleted:
            AdapterLogP(@"kUnityShowCompletionStateCompleted %@", placementId);
            self.isRewarded = true;
            [self setCallbackStatus:MovieRewardCallbackPlayComplete];
            break;
        case kUnityShowCompletionStateSkipped:
            AdapterLogP(@"kUnityShowCompletionStateSkipped %@", placementId);
            break;
        default:
            AdapterLogP(@"other %@", placementId);
            [self setErrorWithMessage:@"unityAdsShowComplete with UnityAdsShowCompletionStateError" code:0];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
            break;
    }

    [self setCallbackStatus:MovieRewardCallbackClose];
}

- (void)unityAdsShowFailed:(NSString *)placementId withError:(UnityAdsShowError)error withMessage:(NSString *)message {
    AdapterTraceP(@"%@ %ld", message, error);
    NSString *reason;
    switch (error) {
        case kUnityShowErrorNotInitialized:
            reason = @"NotInitialized";
            break;
        case kUnityShowErrorNotReady:
            reason = @"NotReady";
            break;
        case kUnityShowErrorVideoPlayerError:
            reason = @"VideoPlayerError";
            break;
        case kUnityShowErrorInvalidArgument:
            reason = @"InvalidArgument";
            break;
        case kUnityShowErrorNoConnection:
            reason = @"NoConnection";
            break;
        case kUnityShowErrorAlreadyShowing:
            reason = @"AlreadyShowing";
            break;
        case kUnityShowErrorInternalError:
            reason = @"InternalError";
            break;
        case kUnityShowErrorTimeout:
            reason = @"TimeoutError";
            break;
        default:
            reason = @"Unknown";
    }
    [self setErrorWithMessage:reason code:(int)error];
    [self setCallbackStatus:MovieRewardCallbackPlayFail];

}
 
- (void)unityAdsShowStart:(NSString *)placementId {
    AdapterTraceP(@"%@", placementId);
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}
 
- (void)unityAdsShowClick:(NSString *)placementId {
    AdapterTraceP(@"%@", placementId);
}

@end

@implementation MovieReward6030
@end

@implementation MovieReward6031
@end

@implementation MovieReward6032
@end

@implementation MovieReward6033
@end

@implementation MovieReward6034
@end

@implementation MovieReward6035
@end

@implementation MovieReward6036
@end

@implementation MovieReward6037
@end

@implementation MovieReward6038
@end
