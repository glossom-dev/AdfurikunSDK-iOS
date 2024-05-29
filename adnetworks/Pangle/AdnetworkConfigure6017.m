//
//  AdnetworkConfigure6017.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/04/26.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import "AdnetworkConfigure6017.h"
#import "AdnetworkParam6017.h"
#import <PAGAdSDK/PAGAdSDK.h>

@interface AdnetworkConfigure6017 ()

@property (nonatomic) NSNumber *gdprStatus;
@property (nonatomic) NSNumber *isChildDirected;

@end

@implementation AdnetworkConfigure6017

// Adnetwork SDK Version
+ (NSString *)getSDKVersion {
    return PAGSdk.SDKVersion;
}

// Adnetwork名
+ (NSString *)adnetworkName {
    return @"Pangle";
}

+ (instancetype)sharedInstance {
    static AdnetworkConfigure6017 *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

// GDPR関連設定実装
- (void)setHasUserConsent:(BOOL)hasUserConsent {
    AdapterTraceP(@"hasUserConsent: %d", (int)hasUserConsent);
    self.gdprStatus = [NSNumber numberWithBool:hasUserConsent];
}

// COPPA関連設定実装
- (void)isChildDirected:(BOOL)childDirected {
    AdapterTraceP(@"childDirected: %d", (int)childDirected);
    self.isChildDirected = [NSNumber numberWithBool:childDirected];
}

// Adnetwork SDK初期化ロジック実装
// 初期化成功：initSuccess()呼び出し
// 初期化失敗：initFail()呼び出し
- (void)initAdnetworkSDK {
    PAGConfig *configuration = [PAGConfig shareConfig];
    if (self.gdprStatus) {
        configuration.GDPRConsent = self.gdprStatus.boolValue ? PAGGDPRConsentTypeConsent : PAGGDPRConsentTypeNoConsent;
        AdapterLogP(@"gdprConsent : %@, sdk setting value : %d", self.gdprStatus, (int)configuration.GDPRConsent);
    }
    if (self.isChildDirected) {
        configuration.childDirected = self.isChildDirected.boolValue ? PAGChildDirectedTypeChild : PAGChildDirectedTypeNonChild;
        AdapterLogP(@"childDirected : %@, sdk setting value : %d", self.isChildDirected, (int)configuration.childDirected);
    }
    configuration.debugLog = [ADFMovieOptions getTestMode];
    configuration.appID = ((AdnetworkParam6017 *)self.param).appID;
    if (self.logoImage) {
        configuration.appLogoImage = self.logoImage;
    }
    [PAGSdk startWithConfig:configuration completionHandler:^(BOOL success, NSError * _Nonnull error) {
        if (success) {
            [self initSuccess];
        } else {
            [self initFail];
        }
    }];
}

@end
