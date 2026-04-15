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
    return @"1";
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam7501 alloc] initWithParam:data];
    self.configure.param = self.adParam;
}

// Adnetwork SDKを初期化する
- (bool)initAdnetworkIfNeeded {
    // 案件の期限切れタイマーを開始する
    [self checkExpiredAd];
    [self initCompleteAndRetryStartAdIfNeeded];
    return true;
}

- (bool)startAd {
    __weak typeof(self) weakSelf = self;
    // Win APIを叩く
    [self callWinApi:^(NSError * _Nonnull error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        // Win API後に呼び出し、RTB広告の有効期限チェックタイマーを破棄する（Win API以降の敗北通知expired bcは不要）
        [self stopExpiredAdCheck];
        
        if (error) { // Win APIが失敗すると広告読み込みをせずにエラー処理にする
            AdapterLogP(@"error : %@", error);
            [strongSelf setErrorWithMessage:error.localizedDescription code:error.code];
            [strongSelf setCallbackStatus:MovieRewardCallbackFetchFail];
            return;
        } else {
            // Win APIが成功すると広告読み込みを開始する
            AdapterLog(@"start loading");
            [super startAd];
        }
    }];
    
    return true;
}

// 在庫取得有無を返す
- (BOOL)isPrepared {
    return self.isAdLoaded && ![self isBiddingAdExpired];
}

@end
