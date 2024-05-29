//
//  AdnetworkConfigure6120.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/04/25.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import "AdnetworkConfigure6120.h"
#import "AdnetworkParam6120.h"

@implementation AdnetworkConfigure6120

// Adnetwork SDK Version
+ (NSString *)getSDKVersion {
    return MTGSDK.sdkVersion;
}

// Adnetwork名
+ (NSString *)adnetworkName {
    return @"Mintegral";
}

+ (instancetype)sharedInstance {
    static AdnetworkConfigure6120 *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

// GDPR関連設定実装
- (void)setHasUserConsent:(BOOL)hasUserConsent {
    AdapterTraceP(@"hasUserConsent: %d", (int)hasUserConsent);
    [MTGSDK.sharedInstance setConsentStatus:hasUserConsent];
}

// COPPA関連設定実装
- (void)isChildDirected:(BOOL)childDirected {
    AdapterTraceP(@"childDirected: %d", (int)childDirected);
    [MTGSDK.sharedInstance setCoppa:childDirected ? MTGBoolYes : MTGBoolNo];
}

// Adnetwork SDK初期化ロジック実装
// 初期化成功：initSuccess()呼び出し
// 初期化失敗：initFail()呼び出し
- (void)initAdnetworkSDK {
    [MTGSDK.sharedInstance setAppID:((AdnetworkParam6120 *)self.param).appId 
                             ApiKey:((AdnetworkParam6120 *)self.param).appKey];
    [self initSuccess];
}

@end
