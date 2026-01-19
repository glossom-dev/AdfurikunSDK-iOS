//
//  AdnetworkConfigure6000.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/04/23.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import "AdnetworkConfigure6000.h"
#import "AdnetworkParam6000.h"

@implementation AdnetworkConfigure6000

+ (NSString *)getSDKVersion {
    return ALSdk.version;
}
// Adnetwork名
+ (NSString *)adnetworkName {
    return @"AppLovin";
}

+ (instancetype)sharedInstance {
    static AdnetworkConfigure6000 *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

// GDPR関連設定実装
- (void)setHasUserConsent:(BOOL)hasUserConsent {
    AdapterTraceP(@"hasUserConsent: %d", (int)hasUserConsent);
    [ALPrivacySettings setHasUserConsent:hasUserConsent];
}

// Adnetwork SDK初期化ロジック実装
// 初期化成功：initSuccess()呼び出し
// 初期化失敗：initFail()呼び出し
- (void)initAdnetworkSDK {
    ALSdkInitializationConfiguration *initConfig =
    [ALSdkInitializationConfiguration configurationWithSdkKey:((AdnetworkParam6000 *)self.param).appLovinSdkKey
                                                 builderBlock:^(ALSdkInitializationConfigurationBuilder *builder) {
        builder.mediationProvider = ALMediationProviderMAX;
    }];
    
    __weak typeof(self) weakSelf = self;
    [[ALSdk shared] initializeWithConfiguration:initConfig completionHandler:^(ALSdkConfiguration *sdkConfig) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;

        //音出力設定
        [strongSelf soundControl];
        
        // デバッグ機能設定（Trueにすると端末を裏表に振ると、画面にAppLovinアイコンが表示される）
        [ALSdk shared].settings.creativeDebuggerEnabled = [AdfurikunSdk getTestMode];
        
        // DebugLog出力設定
        [ALSdk shared].settings.verboseLoggingEnabled = [AdfurikunSdk getTestMode];
        
        // SafeAreaサイズ不具合対応
        [[ALSdk shared].settings setExtraParameterForKey:@"pisw" value:@"true"];
        
        [strongSelf initSuccess];
    }];

}

// サウンド制御実装
- (void)soundControl {
    AdapterTraceP(@"soundState: %d", (int)[AdfurikunSdk getSoundState]);
    [ALSdk shared].settings.muted = (AdfurikunSdkSoundOff == [AdfurikunSdk getSoundState]);
}

@end
