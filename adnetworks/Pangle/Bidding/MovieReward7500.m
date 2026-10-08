//
//  MovieReward7500.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2025/11/28.
//  Copyright © 2025 GREE X, Inc. All rights reserved.
//

#import "MovieReward7500.h"
#import "AdnetworkParam7500.h"

@implementation MovieReward7500

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"2";
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];

    self.adParam = [[AdnetworkParam7500 alloc] initWithParam:data];
    self.configure.param = self.adParam;
}

// Adnetwork SDKを初期化する
- (bool)initAdnetworkIfNeeded {
    return [self initAdnetworkForBidding];
}

- (bool)startAd {
    return [self startAdForBidding];
}

// 在庫取得有無を返す
- (bool)isPrepared {
    return [super isPrepared] && ![self isBiddingAdExpired]; // WF Adapterの在庫取得有無関数（super.isPrepared）と案件切れをチェックする
}

// Win API成功後にPangle SDKで広告を読み込む
- (void)loadAdAfterWinApi {
    [super startAd]; // super = MovieReward6017（Pangle SDK呼び出し）
}

@end
