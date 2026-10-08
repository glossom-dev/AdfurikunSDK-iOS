//
//  MovieReward7501.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2026/03/03.
//  Copyright © 2026 GREE X, Inc. All rights reserved.
//

#import "MovieReward7501.h"
#import "AdnetworkParam7501.h"

@implementation MovieReward7501

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"2";
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];

    self.adParam = [[AdnetworkParam7501 alloc] initWithParam:data];
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

// Win API成功後にUnityAds SDKで広告を読み込む
- (void)loadAdAfterWinApi {
    [super startAd]; // super = MovieReward6001（UnityAds SDK呼び出し）
}

@end
