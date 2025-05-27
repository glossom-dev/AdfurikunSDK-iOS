//
//  AdnetworkConfigure6006.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/04/30.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import "AdnetworkConfigure6006.h"
#import "AdnetworkParam6006.h"
#import <VungleAdsSDK/VungleAdsSDK.h>

@implementation AdnetworkConfigure6006

// Adnetwork SDK Version
+ (NSString *)getSDKVersion {
    return [VungleAds sdkVersion];
}

// Adnetwork名
+ (NSString *)adnetworkName {
    return @"Vungle";
}

+ (instancetype)sharedInstance {
    static AdnetworkConfigure6006 *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

// GDPR関連設定実装
- (void)setHasUserConsent:(BOOL)hasUserConsent {
    AdapterTraceP(@"hasUserConsent: %d", (int)hasUserConsent);
    [VunglePrivacySettings setGDPRStatus:hasUserConsent];
}

// COPPA関連設定実装
- (void)isChildDirected:(BOOL)childDirected {
    AdapterTraceP(@"childDirected: %d", (int)childDirected);
    [VunglePrivacySettings setCOPPAStatus:childDirected];
}

// Adnetwork SDK初期化ロジック実装
// 初期化成功：initSuccess()呼び出し
// 初期化失敗：initFail()呼び出し
- (void)initAdnetworkSDK {
    [VungleAds setDebugLoggingEnabled:[AdfurikunSdk getTestMode]];
    
    __weak typeof(self) weakSelf = self;
    [VungleAds initWithAppId:((AdnetworkParam6006 *)self.param).vungleAppID completion:^(NSError * _Nullable error){
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        if (error) {
            [strongSelf initFail];
        } else {
            [strongSelf initSuccess];
        }
    }];
}

@end
