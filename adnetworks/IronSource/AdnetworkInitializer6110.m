//
//  AdnetworkInitializer6110.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2025/11/27.
//  Copyright © 2025 GREE X, Inc. All rights reserved.
//

#import "AdnetworkInitializer6110.h"

#import <IronSource/IronSource.h>

@implementation AdnetworkInitializer6110

+ (NSString *)adnetworkClassName {
    return @"IronSource";
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    self.param = [[AdnetworkParam6110 alloc] initWithParam:data];
}

// Adnetwork SDKを初期化する
- (void)initAdnetworkForBidding:(ADFInitAdnetworkForBiddingCompleteHandler)handler {
    AdapterTrace;
    ISAInitRequestBuilder *requestBuilder = [[ISAInitRequestBuilder alloc] initWithAppKey:((AdnetworkParam6110 *)self.param).appKey];
    NSArray<ISAAdFormat *> *formats = @[
        [[ISAAdFormat alloc] initWithAdFormatType:ISAAdFormatTypeRewarded],
        [[ISAAdFormat alloc] initWithAdFormatType:ISAAdFormatTypeInterstitial],
        [[ISAAdFormat alloc] initWithAdFormatType:ISAAdFormatTypeBanner]
    ];
    [requestBuilder withLegacyAdFormats:formats];
    ISAInitRequest *initRequest = [requestBuilder build];
    [IronSourceAds initWithRequest:initRequest completion:^(BOOL success, NSError * _Nullable error) {
        if (handler) {
            handler([ADFBiddingTokenResult failureWithError:error]);
        }
    }];
}

@end
