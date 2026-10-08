//
//  AdnetworkInitializer7503.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2026/07/07.
//  Copyright © 2026 GREE X, Inc. All rights reserved.
//

#import "AdnetworkInitializer7503.h"

@implementation AdnetworkInitializer7503

+ (NSString *)adnetworkClassName {
    return @"InMobiSDK.IMSdk";
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    AdapterTrace;
    self.param = [[AdnetworkParam7503 alloc] initWithParam:data];
    self.gdprStatus = [AdfurikunSdk getHasUserConsentNumber];
    self.isChildDirected = [AdfurikunSdk getChildDirected];
    if (self.isChildDirected) {
        AdapterTraceP(@"childDirected: %d", (int)self.isChildDirected.boolValue);
        [IMSdk setIsAgeRestricted:self.isChildDirected.boolValue];
    }
}

// Adnetwork SDKを初期化する
- (void)initAdnetworkForBidding:(ADFInitAdnetworkForBiddingCompleteHandler)handler {
    AdapterTrace;
    // Test Mode ONの時Debug Logを出力する
    if ([AdfurikunSdk getTestMode]) {
        [IMSdk setLogLevel:IMSDKLogLevelDebug];
    }
    
    AdnetworkParam6190 *param = (AdnetworkParam6190 *)self.param;
    NSDictionary *consentDictionary = nil;
    if (self.gdprStatus) {
        if (self.gdprStatus.boolValue) {
            // GDPRに同意した場合
            consentDictionary = @{
                IMCommonConstants.IM_GDPR_CONSENT_AVAILABLE: @"true",
                IMCommonConstants.IM_GDPR_CONSENT_IAB: @"True",
                IMCommonConstants.IM_SUBJECT_TO_GDPR: @"1"
            };
            AdapterLogP(@"consentDictionary: %@", consentDictionary);
        } else {
            // GDPRに同意してない場合
            consentDictionary = @{
                IMCommonConstants.IM_GDPR_CONSENT_AVAILABLE: @"false",
                IMCommonConstants.IM_GDPR_CONSENT_IAB: @"False",
                IMCommonConstants.IM_SUBJECT_TO_GDPR: @"0"
            };
            AdapterLogP(@"consentDictionary: %@", consentDictionary);
        }
    }
    __weak typeof(self) weakSelf = self;
    [IMSdk initWithAccountID:param.accountId
           consentDictionary:consentDictionary
        andCompletionHandler:^(NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        if (error) {
            handler([ADFBiddingTokenResult failureWithError:error]);
            AdapterLogP(@"init error (%@)", error);
            return;
        }
        
        [strongSelf getBiddingToken:handler];
    }];
}

- (void)getBiddingToken:(ADFInitAdnetworkForBiddingCompleteHandler)handler {
    AdapterTrace;
    
    NSString *sdkVersion = [AdfurikunSdk version];
    NSDictionary *param = @{
        @"tp": @"c_adfurikun",
        @"tp-ver": sdkVersion,
    };
    
    NSString *biddingToken = [IMSdk getTokenWithExtras:param andKeywords:nil];
    AdapterLogP(@"biddingToken : %@", biddingToken);
    
    if (biddingToken && biddingToken.length > 0) {
        handler([ADFBiddingTokenResult successWithToken:biddingToken]);
    } else {
        handler([ADFBiddingTokenResult failureWithErrorCode:nil
                                               errorMessage:@"Bidding token is empty"]);
    }
}

@end
