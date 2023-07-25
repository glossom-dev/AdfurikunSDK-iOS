//
//  MovieReward6110.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2022/08/09.
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import "MovieReward6110.h"
#import "AdnetworkConfigure6110.h"

@interface MovieReward6110 ()

@property (nonatomic) NSString *appKey;

@end

@implementation MovieReward6110

// SDKからバージョンを取得して返す
// APIがなければ削除
+ (NSString *)getSDKVersion {
    return [IronSource sdkVersion];
}

// Adapterのバージョン。最初は1にして、修正がある度＋1にする
+ (NSString *)getAdapterRevisionVersion {
    return @"6";
}

+ (NSString *)adnetworkClassName {
    return @"IronSource";
}

// getinfoからのParameter設定
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    NSString *appKey = [data objectForKey:@"app_key"];
    if ([self isString:appKey]) {
        self.appKey = [NSString stringWithFormat:@"%@", appKey];
    }
    
    NSString *instanceId = [data objectForKey:@"instance_id"];
    if ([self isString:instanceId]) {
        self.instanceId = [NSString stringWithFormat:@"%@", instanceId];
    }
}

// 広告準備有無を返す
- (BOOL)isPrepared {
    AdapterTrace;
    return self.isAdLoaded;
}

// Adnetwork SDKの初期化を行う
- (void)initAdnetworkIfNeeded {
    // 一回のみ初期化を行うようなチェックを行う
    if (![self needsToInit]) {
        return;
    }
    
    if (!self.appKey) {
        return;
    }
    
    [AdnetworkConfigure6110.sharedInstance initIronSource:self.appKey completion:^{
        [self initCompleteAndRetryStartAdIfNeeded];
    }];
}

// 広告呼び込みを行う
- (void)startAd {
    AdapterTrace;
    // 初期化が完了しているかをチェック
    if (![self canStartAd]) {
        return;
    }
    
    if (!self.instanceId) {
        return;
    }
    
    [super startAd];
    
    // Adnetwork SDKの関数を呼び出す際はTryーCatchでException Handlingを行う
    @try {
        // 非同期で行われる場合にはFlag設定を行う
        [self requireToAsyncRequestAd];
        
        [AdnetworkConfigure6110.sharedInstance setMovieRewardAdapter:self instanceId:self.instanceId];
        [IronSource loadISDemandOnlyRewardedVideo:self.instanceId];
        AdapterLog(@"load rewarded video");
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

// 広告再生関数
// showAdWithPresentingViewController と両方を必ず実装する
- (void)showAd {
    UIViewController *topVC = [self topMostViewController];
    if (topVC) {
        [self showAdWithPresentingViewController:topVC];
    } else {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAdWithPresentingViewController:viewController];
    
    @try {
        [self requireToAsyncPlay];
        
        [IronSource showISDemandOnlyRewardedVideo:viewController instanceId:self.instanceId];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

-(void)setHasUserConsent:(BOOL)hasUserConsent {
    [super setHasUserConsent:hasUserConsent];
    [IronSource setConsent:hasUserConsent];
    AdapterLogP(@"Adnetwork 6110, gdprConsent : %@, sdk setting value : %d", self.hasGdprConsent, (int)hasUserConsent);
}

- (void)isChildDirected:(BOOL)childDirected {
    [super isChildDirected:childDirected];
    [IronSource setMetaDataWithKey:@"is_child_directed" value:childDirected ? @"YES": @"NO"];
    AdapterLogP(@"Adnetwork %@, childDirected : %@, input parameter : %d", self.adnetworkKey, self.childDirected, (int)childDirected);
}

@end

@implementation MovieReward6111
@end

@implementation MovieReward6112
@end

@implementation MovieReward6113
@end

@implementation MovieReward6114
@end

@implementation MovieReward6115
@end
