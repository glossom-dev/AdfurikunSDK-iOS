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
        [UnityAds initialize:((AdnetworkParam6001 *)self.param).gameId testMode:testFlg initializationDelegate:self];
    } else {
        [self getBiddingToken];
    }
}

- (void)getBiddingToken {
    AdapterTrace;
    
    NSString *token = [UnityAds getToken];
    AdapterLogP(@"Bidding Token: %@", token);
    if (self.handler) {
        self.handler([ADFBiddingTokenResult successWithToken:token]);
    }
}

#pragma mark: UnityAdsInitializationDelegate
- (void)initializationComplete {
    AdapterTrace;
    [self getBiddingToken];
}

- (void)initializationFailed: (UnityAdsInitializationError)error withMessage: (NSString *)message {
    AdapterTraceP(@"error message : %@", message);
    if (self.handler) {
        self.handler([ADFBiddingTokenResult failureWithErrorCode:@(error) errorMessage:message]);
    }
}

@end
