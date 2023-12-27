//
//  MovieReward6150.m
//
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import "MovieReward6150.h"
#import "AdnetworkParam6150.h"
#import <ZucksAdNetworkSDK/ZADNRewardedAd.h>

@interface MovieReward6150 () <ZADNRewardedAdDelegate>

@property (nonatomic) ZADNRewardedAd *rewardedAd;
@property (nonatomic) AdnetworkParam6150 *adParam;

@end

@implementation MovieReward6150

// Adapterのバージョン。最初は1にして、修正がある度＋1にする
+ (NSString *)getAdapterRevisionVersion {
    return @"3";
}

+ (NSString *)adnetworkClassName {
    return @"ZADNRewardedAd";
}

+ (NSString *)adnetworkName {
    return @"Zucks";
}

// getinfoからのParameter設定
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6150 alloc] initWithParam:data];
}

// 広告準備有無を返す
- (BOOL)isPrepared {
    AdapterTrace;
    return self.isAdLoaded && [self.rewardedAd isAdAvailable];
}

// 広告呼び込みを行う
- (void)startAd {
    AdapterTrace;
    
    if (!self.adParam || !self.adParam.frameId) {
        return;
    }

    [super startAd];
    
    if (self.rewardedAd) {
        self.rewardedAd = nil;
    }
    self.rewardedAd = [[ZADNRewardedAd alloc] initWithFrameId:self.adParam.frameId];
    
    // Adnetwork SDKの関数を呼び出す際はTryーCatchでException Handlingを行う
    @try {
        // 非同期で行われる場合にはFlag設定を行う
        [self requireToAsyncRequestAd];
        
        self.rewardedAd.delegate = self;
        [self.rewardedAd loadAd];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

// 広告再生関数
// showAdWithPresentingViewController と両方を必ず実装する
- (void)showAd {
    UIViewController *topVC = [self topMostViewController];
    [self showAdWithPresentingViewController:topVC];
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAdWithPresentingViewController:viewController];
    
    @try {
        if (viewController) {
            [self.rewardedAd presentAdFromViewController:viewController];
        } else {
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

#pragma mark - ZADNRewardedAdDelegate

- (void)rewardedAdDidLoad:(ZADNRewardedAd *)rewardedAd {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

- (void)rewardedAd:(ZADNRewardedAd *)rewardedAd didFailToLoadWithError:(NSError *)error {
    AdapterTraceP(@"Request failed with error: %@ and suggestion: %@", [error localizedDescription], [error localizedRecoverySuggestion]);
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

- (void)rewardedAdWillAppear:(ZADNRewardedAd *)rewardedAd {
    AdapterTrace;
}
 
- (void)rewardedAdDidAppear:(ZADNRewardedAd *)rewardedAd {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)rewardedAdWillDisappear:(ZADNRewardedAd *)rewardedAd {
    AdapterTrace;
}

- (void)rewardedAdShouldReward:(nonnull ZADNRewardedAd *)rewardedAd {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
}

- (void)rewardedAdDidDisappear:(ZADNRewardedAd *)rewardedAd {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackClose];
}

- (void)rewardedAd:(ZADNRewardedAd *)rewardedAd didFailToPlayWithError:(NSError *)error {
    AdapterTraceP(@"play failed with error: %@ and suggestion: %@", [error localizedDescription], [error localizedRecoverySuggestion]);
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}

@end

@implementation MovieReward6151
@end

@implementation MovieReward6152
@end

@implementation MovieReward6153
@end

@implementation MovieReward6154
@end

@implementation MovieReward6155
@end
