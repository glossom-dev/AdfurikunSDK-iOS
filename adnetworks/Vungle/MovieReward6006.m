//
//  MovieReward6006.m(Vungle)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//
#import <UIKit/UIKit.h>
#import "MovieReward6006.h"
#import "AdnetworkConfigure6006.h"
#import "AdnetworkParam6006.h"

@interface MovieReward6006()

@property (nonatomic, strong) VungleRewarded *rewardedAd;

@end

@implementation MovieReward6006

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"12";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"VungleAdsSDK.VungleRewarded";
}

// ADFで定義しているAdnetwork名。
+ (NSString *)adnetworkName {
    return [AdnetworkConfigure6006 adnetworkName];
}

+ (NSString *)getSDKVersion {
    return [AdnetworkConfigure6006 getSDKVersion];
}

// Instance Variableを初期化する。また、必要な場合Configureを生成する
-(id)init {
    self = [super init];
    if (self) {
        self.configure = [AdnetworkConfigure6006 sharedInstance];
    }
    return self;
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6006 alloc] initWithParam:data];
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
        if (self.rewardedAd) {
            self.rewardedAd = nil;
        }
        [self requireToAsyncRequestAd];
        
        self.rewardedAd = [[VungleRewarded alloc] initWithPlacementId:((AdnetworkParam6006 *)self.adParam).placementID];
        self.rewardedAd.delegate = self;
        [self.rewardedAd load:nil];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
    return true;
}

// 在庫取得有無を返す
- (BOOL)isPrepared {
    return self.isAdLoaded && [self.rewardedAd canPlayAd];
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
    
    if (!self.rewardedAd) {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
        return;
    }

    if ([self isPrepared]) {
        @try {
            [self requireToAsyncPlay];
            [self.rewardedAd presentWith:viewController];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    } else {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

#pragma mark - VungleRewarded Delegate Methods
// Ad load events
- (void)rewardedAdDidLoad:(VungleRewarded *)rewarded {
    AdapterTrace;
    self.creativeId = rewarded.creativeId;
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

- (void)rewardedAdDidFailToLoad:(VungleRewarded *)rewarded withError:(NSError *)withError {
    AdapterTraceP(@"error : %@", withError);
    [self setLastError:withError];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

- (void)rewardedAdWillPresent:(VungleRewarded *)rewarded {
    AdapterTrace;
}

- (void)rewardedAdDidPresent:(VungleRewarded *)rewarded {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)rewardedAdDidFailToPresent:(VungleRewarded *)rewarded withError:(NSError *)withError {
    AdapterTraceP(@"error : %@", withError);
    [self setLastError:withError];
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}

- (void)rewardedAdDidTrackImpression:(VungleRewarded *)rewarded {
    AdapterTrace;
}

- (void)rewardedAdDidClick:(VungleRewarded *)rewarded {
    AdapterTrace;
}

- (void)rewardedAdWillLeaveApplication:(VungleRewarded *)rewarded {
    AdapterTrace;
}

- (void)rewardedAdDidRewardUser:(VungleRewarded *)rewarded {
    AdapterTrace;
}

- (void)rewardedAdWillClose:(VungleRewarded *)rewarded {
    AdapterTrace;
}

- (void)rewardedAdDidClose:(VungleRewarded *)rewarded {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    [self setCallbackStatus:MovieRewardCallbackClose];
}

@end

@implementation MovieReward6200
@end

@implementation MovieReward6201
@end

@implementation MovieReward6202
@end

@implementation MovieReward6203
@end

@implementation MovieReward6204
@end

@implementation MovieReward6205
@end

@implementation MovieReward6206
@end

@implementation MovieReward6207
@end

@implementation MovieReward6208
@end
