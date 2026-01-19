//
//  AdfurikunAdnetworkExtra.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2025/08/12.
//  Copyright © 2025 GREE X, Inc. All rights reserved.
//

#import "AdfurikunAdnetworkExtra.h"
#import <ADFMovieReward/AdfurikunSdk.h>
#import <ADFMovieReward/ADFLogger.h>

@implementation AdfurikunAdnetworkExtra

- (instancetype)init {
    self = [super init];
    if (self) {
        self.loadTimeout = 0.0;
    }
    return self;
}

- (void)adfurikunSDKInitProcessWithTestMode:(bool)testMode {
    [AdfurikunSdk setTestMode:testMode];
    
    if (self.enableDebugLog) {
        [ADFLogger setLogLevel:ADFLogLevelVerbose];
        enableMediationAdapterLog = true;
    }
    
    if (self.hasUserConsent) {
        [AdfurikunSdk setHasUserConsent:[self.hasUserConsent boolValue]];
    }
    
    if (self.childDirected) {
        [AdfurikunSdk isChildDirected:[self.childDirected boolValue]];
    }

    if (self.setUserIsMinor) {
        [AdfurikunSdk setUserIsMinor];
    }
    
    if (self.soundState) {
        AdfurikunSdkSound state = [self.soundState boolValue] ? AdfurikunSdkSoundOn : AdfurikunSdkSoundOff;
        [AdfurikunSdk setSoundState:state];
    }
}

// 内部ログ出力用
// MediationAdapterのログを出力する。extra.enableDebugLogをtrueに設定した場合もtrueが設定される。
static BOOL enableMediationAdapterLog = false;

BOOL ADFIsMediationAdapterLogEnabled(void) {
    return enableMediationAdapterLog;
}

@end
