//
//  AdnetworkConfigure6140.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/04/24.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import "AdnetworkConfigure6140.h"
#import "AdnetworkParam6140.h"


@interface AdnetworkConfigure6140 ()

@property(nonatomic) bool childDirected;

@end

@implementation AdnetworkConfigure6140

// Adnetwork SDK Version
+ (NSString *)getSDKVersion {
    return [IASDKCore.sharedInstance version];
}

// Adnetwork名
+ (NSString *)adnetworkName {
    return @"Fyber";
}

+ (instancetype)sharedInstance {
    static AdnetworkConfigure6140 *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

// GDPR関連設定実装
- (void)setHasUserConsent:(BOOL)hasUserConsent {
    AdapterTraceP(@"hasUserConsent: %d", (int)hasUserConsent);
    [IASDKCore.sharedInstance setGDPRConsent:hasUserConsent];
}

// COPPA関連設定実装
- (void)isChildDirected:(BOOL)childDirected {
    AdapterTraceP(@"childDirected: %d", (int)childDirected);
    self.childDirected = childDirected;
}

// Adnetwork SDK初期化ロジック実装
// 初期化成功：initSuccess()呼び出し
// 初期化失敗：initFail()呼び出し
- (void)initAdnetworkSDK {
    if (IASDKCore.sharedInstance.isInitialised) {
        [self initSuccess];
        return;
    }
    
    IASDKCore.sharedInstance.globalAdDelegate = self;
    
    [IASDKCore.sharedInstance initWithAppID:((AdnetworkParam6140 *)self.param).appId
                            completionBlock:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                [self initSuccess];
                // COPPA関連設定はSDK初期化後にやるようにマニュアルに書いてる。
                if (self.childDirected) {
                    IASDKCore.sharedInstance.coppaApplies = self.childDirected ? IACoppaAppliesTypeDenied : IACoppaAppliesTypeGiven;
                }
            } else {
                [self initFail];
                AdapterLogP(@"init error (%@)", error);
            }
        } completionQueue:nil];
}

// サウンド制御実装
- (void)soundControl {
    AdapterTraceP(@"soundState: %d", (int)[ADFMovieOptions getSoundState]);
    ADFMovieOptions_Sound soundState = [ADFMovieOptions getSoundState];
    IASDKCore.sharedInstance.muteAudio = (ADFMovieOptions_Sound_Off == soundState);
}

- (void)adDidShowWithImpressionData:(IAImpressionData * _Nonnull)impressionData withAdRequest:(IAAdRequest * _Nonnull)adRequest {
    AdapterTraceP(@"impression creative id : %@", impressionData.creativeID);
    self.creativeId = impressionData.creativeID;
}

@end
