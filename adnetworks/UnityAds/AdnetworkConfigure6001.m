//
//  AdnetworkConfigure6001.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/04/26.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import "AdnetworkConfigure6001.h"
#import "AdnetworkParam6001.h"

#import <ADFMovieReward/AdfurikunSdk.h>

@implementation AdnetworkConfigure6001

// Adnetwork SDK Version
+ (NSString *)getSDKVersion {
    return UnityAds.getVersion;
}

// Adnetwork名
+ (NSString *)adnetworkName {
    return @"Unity Ads";
}

+ (instancetype)sharedInstance {
    static AdnetworkConfigure6001 *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

// GDPR関連設定実装
- (void)setHasUserConsent:(BOOL)hasUserConsent {
    AdapterTraceP(@"hasUserConsent: %d", (int)hasUserConsent);
    [UnityAds setUserConsent:hasUserConsent];
}

// COPPA関連設定実装
- (void)isChildDirected:(BOOL)childDirected {
    AdapterTraceP(@"childDirected: %d", (int)childDirected);
    [UnityAds setNonBehavioral:childDirected];
}

// 未成年関連実装
- (void)setUserIsMinor {
    AdapterTrace;
    [self isChildDirected:true];
}

// Adnetwork SDK初期化ロジック実装
// 初期化成功：initSuccess()呼び出し
// 初期化失敗：initFail()呼び出し
- (void)initAdnetworkSDK {
    if (UnityAds.isInitialized) {
        [self initSuccess];
    }
    bool testFlg = [AdfurikunSdk getTestMode];
    if (testFlg) {
        AdapterLog(@"Test Mode ON!!!");
    }

    UADSInitializationConfiguration *configuration =
        [[[[UADSInitializationConfigurationBuilder alloc] initWithGameId:((AdnetworkParam6001 *)self.param).gameId]
          withTestMode:testFlg] build];

    __weak typeof(self) weakSelf = self;
    [UnityAds initialize:configuration completion:^(id<UnityAdsError> _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        if (error) {
            AdapterLogP(@"initialize failed. code : %ld, message : %@", (long)error.code, error.message);
            [strongSelf initFail];
        } else {
            AdapterTrace;
            [strongSelf initSuccess];
        }
    }];
}

@end
