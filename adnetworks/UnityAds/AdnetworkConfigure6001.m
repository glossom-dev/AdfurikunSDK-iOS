//
//  AdnetworkConfigure6001.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/04/26.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import "AdnetworkConfigure6001.h"
#import "AdnetworkParameter6001.h"

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
    UADSMetaData *gdprConsentMetaData = [[UADSMetaData alloc] init];
    [gdprConsentMetaData set:@"gdpr.consent" value:hasUserConsent ? @YES : @NO];
    [gdprConsentMetaData commit];
}

// COPPA関連設定実装
- (void)isChildDirected:(BOOL)childDirected {
    AdapterTraceP(@"childDirected: %d", (int)childDirected);
    UADSMetaData *gdprConsentMetaData = [[UADSMetaData alloc] init];
    [gdprConsentMetaData set:@"user.nonbehavioral" value:childDirected ? @YES : @NO];
    [gdprConsentMetaData commit];
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
    [UnityAds initialize:((AdnetworkParameter6001 *)self.param).gameId testMode:testFlg initializationDelegate:self];
}

#pragma mark: UnityAdsInitializationDelegate
- (void)initializationComplete {
    AdapterTrace;
    [self initSuccess];
}

- (void)initializationFailed: (UnityAdsInitializationError)error withMessage: (NSString *)message {
    AdapterTraceP(@"error message : %@", message);
    [self initFail];
}

@end
