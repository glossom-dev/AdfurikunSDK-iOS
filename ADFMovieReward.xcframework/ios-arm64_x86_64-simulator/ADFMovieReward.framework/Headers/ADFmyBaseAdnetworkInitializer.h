//
//  ADFmyBaseAdnetworkInitializer.h
//  ADFMovieReward
//
//  Created by Sungil Kim on 2025/10/30.
//  Copyright © 2025 GREE X, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADFmyBaseAdapterInterface.h"
#import "ADFBiddingTokenResult.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ADFInitAdnetworkForBiddingCompleteHandler)(ADFBiddingTokenResult *result);

@interface ADFmyBaseAdnetworkInitializer : ADFmyAdapterLogger

// Adnetwork SDKで使うClass名を返す
+ (NSString *)adnetworkClassName;

// Adnetwork SDKが存在するかをチェック
+ (bool)isClassReference;

// 初期化に必要なパラメータを設定する
- (void)setData:(NSDictionary *)data;

// BiddingのためのAdnetwork SDKを初期化する
- (void)initAdnetworkForBidding:(ADFInitAdnetworkForBiddingCompleteHandler)handler;

@end

NS_ASSUME_NONNULL_END
