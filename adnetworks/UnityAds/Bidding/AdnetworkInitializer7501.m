//
//  AdnetworkInitializer7501.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2025/12/02.
//  Copyright © 2025 GREE X, Inc. All rights reserved.
//

#import "AdnetworkInitializer7501.h"

@implementation AdnetworkInitializer7501

+ (NSString *)adnetworkClassName {
    return @"UnityAds.UnityAds";
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    self.param = [[AdnetworkParam6001 alloc] initWithParam:data];
}

// Adnetwork SDKを初期化する
- (void)initAdnetworkForBidding:(ADFInitAdnetworkForBiddingCompleteHandler)handler {
    self.handler = handler;
    
    if (!UnityAds.isInitialized) {
        bool testFlg = [AdfurikunSdk getTestMode];
        if (testFlg) {
            AdapterLog(@"Test Mode ON!!!");
        }

        UADSInitializationConfiguration *configuration =
            [[[[UADSInitializationConfigurationBuilder alloc] initWithGameId:((AdnetworkParam6001 *)self.param).gameId]
              withTestMode:testFlg] build];

        __weak typeof(self) weakSelf = self;
        [UnityAds initialize:configuration completion:^(id<UnityAdsError> _Nullable error) {
            __strong typeof(self) strongSelf = weakSelf;
            if (!strongSelf) return;
            if (error) {
                AdapterLogP(@"initialize failed. code : %ld, message : %@", (long)error.code, error.message);
                if (strongSelf.handler) {
                    strongSelf.handler([ADFBiddingTokenResult failureWithErrorCode:@(error.code) errorMessage:error.message]);
                }
                return;
            }
            AdapterTrace;
            [strongSelf getBiddingToken];
        }];
    } else {
        [self getBiddingToken];
    }
}

- (void)getBiddingToken {
    AdapterTrace;
    
    // 7501はRewarded枠のため、Rewardedフォーマット指定でTokenを取得する
    UADSTokenConfigurationBuilder *builder = [[UADSTokenConfigurationBuilder alloc] initWithAdFormat:UADSAdFormatRewarded];
    NSString *placementId = ((AdnetworkParam6001 *)self.param).placementId;
    if (placementId) {
        builder = [builder withPlacementId:placementId];
    }

    __weak typeof(self) weakSelf = self;
    [UnityAds getToken:[builder build] completion:^(NSString * _Nullable token) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;

        AdapterLogP(@"Bidding Token: %@", token);
        if (!strongSelf.handler) return;

        if (token) {
            strongSelf.handler([ADFBiddingTokenResult successWithToken:token]);
        } else {
            strongSelf.handler([ADFBiddingTokenResult failureWithErrorCode:nil errorMessage:@"UnityAds getToken returned nil"]);
        }
    }];
}

@end
