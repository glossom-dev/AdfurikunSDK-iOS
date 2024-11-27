//
//  AdnetworkConfigure6190.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/10/28.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import "AdnetworkConfigure6190.h"
#import "AdnetworkParam6190.h"

@interface AdnetworkConfigure6190 ()

@property (nonatomic) NSNumber *gdprStatus;

@end

@implementation AdnetworkConfigure6190

// Adnetwork SDK Version
+ (NSString *)getSDKVersion {
    return [IMSdk getVersion];
}

// Adnetwork名
+ (NSString *)adnetworkName {
    return @"InMobi";
}

+ (instancetype)sharedInstance {
    static AdnetworkConfigure6190 *sharedInstance = nil;
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
    [IMSdk setIsAgeRestricted:childDirected];
}

// Adnetwork SDK初期化ロジック実装
// 初期化成功：initSuccess()呼び出し
// 初期化失敗：initFail()呼び出し
- (void)initAdnetworkSDK {
    // Test Mode ONの時Debug Logを出力する
    if ([ADFMovieOptions getTestMode]) {
        [IMSdk setLogLevel:IMSDKLogLevelDebug];
    }
    
    AdnetworkParam6190 *param = (AdnetworkParam6190 *)self.param;
    if ([param isValid]) {
        NSDictionary *consentDictionary = nil;
        if (self.gdprStatus) {
            if (self.gdprStatus.boolValue) {
                // GDPRに同意した場合
                consentDictionary = @{
                    IMCommonConstants.IM_GDPR_CONSENT_AVAILABLE: @"true",
                    IMCommonConstants.IM_GDPR_CONSENT_IAB: @"True",
                    IMCommonConstants.IM_SUBJECT_TO_GDPR: @"1"
                };
            } else {
                // GDPRに同意してない場合
                consentDictionary = @{
                    IMCommonConstants.IM_GDPR_CONSENT_AVAILABLE: @"false",
                    IMCommonConstants.IM_GDPR_CONSENT_IAB: @"False",
                    IMCommonConstants.IM_SUBJECT_TO_GDPR: @"0"
                };
            }
        }
        [IMSdk initWithAccountID:param.accountId
               consentDictionary:consentDictionary
            andCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                [self initFail];
                AdapterLogP(@"init error (%@)", error);
                return;
            }
            
            [self initSuccess];
        }];
    } else {
        [self initFail];
        AdapterLog(@"init fail because parameter is not valid");
    }
}

// サウンド制御実装
- (void)soundControl {
    AdapterTraceP(@"soundState: %d", (int)[ADFMovieOptions getSoundState]);
    ADFMovieOptions_Sound soundState = [ADFMovieOptions getSoundState];
    [IMSdk setMute:(ADFMovieOptions_Sound_Off == soundState)];
}

@end
