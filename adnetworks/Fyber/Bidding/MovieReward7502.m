//
//  MovieReward7502.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2026/07/07.
//  Copyright © 2026 GREE X, Inc. All rights reserved.
//

#import "MovieReward7502.h"
#import "AdnetworkParam7502.h"

@implementation MovieReward7502

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"1";
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];

    self.adParam = [[AdnetworkParam7502 alloc] initWithParam:data];
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

// Win API成功後にFyber SDKでマークアップ広告を読み込む
- (void)loadAdAfterWinApi {
    [super startAd]; // super = MovieReward6140（loadAdWithMarkup呼び出し）
}

@end
