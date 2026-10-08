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

// 未成年関連実装
- (void)setUserIsMinor {
    AdapterTrace;
    [self isChildDirected:true];
}

// Adnetwork SDK初期化ロジック実装
// 初期化成功：initSuccess()呼び出し
// 初期化失敗：initFail()呼び出し
- (void)initAdnetworkSDK {
    __weak typeof(self) weakSelf = self;
    [MTGSDK.sharedInstance initializeWithAppID:((AdnetworkParam6120 *)self.param).appId
                                        ApiKey:((AdnetworkParam6120 *)self.param).appKey
                             completionHandler:^(BOOL success, NSError * _Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        if (success) {
            AdapterTrace;
            [strongSelf initSuccess];
        } else {
            // 初期化失敗時にerrorがnilで返るケースがあるため、その場合はデフォルトのメッセージを使う
            NSInteger errorCode = error ? error.code : 0;
            NSString *errorMessage = error ? error.localizedDescription : @"[ADF] MTGSDK initialize failed without error";
            AdapterLogP(@"initialize failed. code : %ld, message : %@", (long)errorCode, errorMessage);
            [strongSelf initFail];
        }
    }];
}

@end
