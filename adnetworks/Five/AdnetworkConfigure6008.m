//
//  AdnetworkConfigure6008.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/04/24.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import "AdnetworkConfigure6008.h"
#import "AdnetworkParam6008.h"

@interface AdnetworkConfigure6008 ()

@property (nonatomic, nullable, readwrite) FADAdLoader *adLoader;

@end

@implementation AdnetworkConfigure6008

// Adnetwork SDK Version
+ (NSString *)getSDKVersion {
    return FADAdLoader.semanticVersion;
}

// Adnetwork名
+ (NSString *)adnetworkName {
    return @"LINE Ads Platform";
}

+ (instancetype)sharedInstance {
    static AdnetworkConfigure6008 *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

// Adnetwork SDK初期化ロジック実装
// 初期化成功：initSuccess()呼び出し
// 初期化失敗：initFail()呼び出し
- (void)initAdnetworkSDK {
    // テストモードはSDK 3.1.0でFADConfig.isTestが非推奨になったため、
    // 各広告取得時にFADAdSlotConfig.setAdTestModeEnabled:で設定する
    FADConfig *config = [[FADConfig alloc] initWithAppId:((AdnetworkParam6008 *)self.param).fiveAppId];

    NSError *error = nil;
    self.adLoader = [FADAdLoader adLoaderForConfig:config outError:&error];
    if (error) {
        AdapterLogP(@"[Five] FADAdLoader init failed: %@", error);
        [self initFail];
    } else {
        [self initSuccess];
    }
}

@end
