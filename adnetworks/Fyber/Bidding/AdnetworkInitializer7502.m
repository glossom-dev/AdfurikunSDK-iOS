//
//  AdnetworkInitializer7502.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2026/07/07.
//  Copyright © 2026 GREE X, Inc. All rights reserved.
//

#import "AdnetworkInitializer7502.h"

@implementation AdnetworkInitializer7502

+ (NSString *)adnetworkClassName {
    return @"IASDKCore";
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    AdapterTrace;
    self.param = [[AdnetworkParam7502 alloc] initWithParam:data];
    self.gdprStatus = [AdfurikunSdk getHasUserConsentNumber];
    self.isChildDirected = [AdfurikunSdk getChildDirected];
}

// Adnetwork SDKを初期化する
- (void)initAdnetworkForBidding:(ADFInitAdnetworkForBiddingCompleteHandler)handler {
    AdapterTrace;
    // すでに初期化済みの場合にはBidding Tokenだけ取得する
    if (IASDKCore.sharedInstance.isInitialised) {
        AdapterLog(@"isInitialised is True");
        [self getBiddingToken:handler];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [IASDKCore.sharedInstance initWithAppID:((AdnetworkParam7502 *)self.param).appId
                            completionBlock:^(BOOL success, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        if (success) {
            // GDPR設定
            if (self.gdprStatus) {
                [IASDKCore.sharedInstance setGDPRConsent:self.gdprStatus.boolValue];
                AdapterTraceP(@"hasUserConsent: %d", (int)self.gdprStatus.boolValue);
            }
            
            // COPPA関連設定はSDK初期化後にやるようにマニュアルに書いてる。
            if (self.isChildDirected) {
                IASDKCore.sharedInstance.coppaApplies = self.isChildDirected.boolValue ? IACoppaAppliesTypeTrue : IACoppaAppliesTypeFalse;
                AdapterLogP(@"childDirected : %@, sdk setting value : %d", self.isChildDirected, (int)IASDKCore.sharedInstance.coppaApplies);
            }
            [strongSelf getBiddingToken:handler];
        } else {
            handler([ADFBiddingTokenResult failureWithError:error]);
        }
    } completionQueue:nil];
}

- (void)getBiddingToken:(ADFInitAdnetworkForBiddingCompleteHandler)handler {
    AdapterTrace;
    
    NSString *biddingToken = FMPBiddingManager.sharedInstance.biddingToken;
    AdapterLogP(@"biddingToken : %@", biddingToken);
    
    if (biddingToken && biddingToken.length > 0) {
        handler([ADFBiddingTokenResult successWithToken:biddingToken]);
    } else {
        handler([ADFBiddingTokenResult failureWithErrorCode:nil
                                               errorMessage:@"Bidding token is empty"]);
    }
}

@end
