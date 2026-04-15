//
//  AdnetworkInitializer7500.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2025/10/29.
//  Copyright © 2025 GREE X, Inc. All rights reserved.
//

#import "AdnetworkInitializer7500.h"
#import <PAGAdSDK/PAGAdSDK.h>

@implementation AdnetworkInitializer7500

+ (NSString *)adnetworkClassName {
    return @"PAGSdk";
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    self.param = [[AdnetworkParam7500 alloc] initWithParam:data];
    self.gdprStatus = [AdfurikunSdk getHasUserConsentNumber];
    self.isChildDirected = [AdfurikunSdk getChildDirected];
}

// Adnetwork SDKを初期化する
- (void)initAdnetworkForBidding:(ADFInitAdnetworkForBiddingCompleteHandler)handler {
    // すでに初期化済みの場合にはBidding Tokenだけ取得する
    if (PAGSdk.initializationState == PAGSDKInitializationStateReady) {
        AdapterLog(@"PAGSDKInitializationStateReady");
        [self getBiddingToken:handler];
        return;
    }
    
    AdapterTrace;
    PAGConfig *configuration = [PAGConfig shareConfig];
    if (self.gdprStatus) {
        configuration.GDPRConsent = self.gdprStatus.boolValue ? PAGGDPRConsentTypeConsent : PAGGDPRConsentTypeNoConsent;
    }
    if (self.isChildDirected) {
        // Indicates whether the user agrees to serve personalized ads. If not passed, it is assumed to agree. If 0 is passed, it means that ads are not allowed to be served.
        // 子供向けのアプリの場合には個人情報同意をしてないことにする
        configuration.PAConsent = self.isChildDirected.boolValue ? PAGPAConsentTypeNoConsent : PAGPAConsentTypeConsent;
    }
    
    configuration.debugLog = [AdfurikunSdk getTestMode];
    configuration.adxID = self.param.adxID;
    configuration.appID = self.param.appID;
    configuration.userDataString = [NSString stringWithFormat:@"\
                                                [{\"name\":\"mediation\" , \"value\":\"Adfurikun\", \
                                                 {\"name\":\"adapter_version\" , \"value\":\"%@\"}]", [self getAdapterVersion]];
    __weak typeof(self) weakSelf = self;
    [PAGSdk startWithConfig:configuration completionHandler:^(BOOL success, NSError * _Nonnull error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        if (success) {
            [strongSelf getBiddingToken:handler];
        } else {
            handler([ADFBiddingTokenResult failureWithError:error]);
        }
    }];
}

- (NSString *)getAdapterVersion {
    return [NSString stringWithFormat:@"%@.0", PAGSdk.SDKVersion];
}

- (void)getBiddingToken:(ADFInitAdnetworkForBiddingCompleteHandler)handler {
    AdapterTrace;
    
    PAGBiddingRequest *request = [[PAGBiddingRequest alloc] init];

    request.adxID = self.param.adxID;
    request.slotID = self.param.slotID;
    
    [PAGSdk getBiddingTokenWithRequest:request completion:^(NSString *biddingToken) {
        AdapterLogP(@"biddingToken : %@", biddingToken);
        if (biddingToken && biddingToken.length > 0) {
            handler([ADFBiddingTokenResult successWithToken:biddingToken]);
        } else {
            handler([ADFBiddingTokenResult failureWithErrorCode:nil
                                                  errorMessage:@"Bidding token is empty"]);
        }
    }];
}
@end
