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
    
    if (self.enagleDebugLog) {
        [ADFLogger setLogLevel:ADFLogLevelVerbose];
    }
    
    if (self.hasUserConsent) {
        [AdfurikunSdk setHasUserConsent:[self.hasUserConsent boolValue]];
    }
    
    if (self.childDirected) {
        [AdfurikunSdk isChildDirected:[self.childDirected boolValue]];
    }

    if (self.applicationIsForChild) {
        [AdfurikunSdk applicationIsForChild];
    }
    
    if (self.soundState) {
        AdfurikunSdkSound state = [self.soundState boolValue] ? AdfurikunSdkSoundOn : AdfurikunSdkSoundOff;
        [AdfurikunSdk setSoundState:state];
    }
}
@end
