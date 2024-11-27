//
//  MovieReward6110.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2022/08/09.
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import "MovieReward6110.h"
#import "AdnetworkConfigure6110.h"
#import "AdnetworkParam6110.h"

@implementation MovieReward6110

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"9";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"IronSource";
}

// ADFで定義しているAdnetwork名。
+ (NSString *)adnetworkName {
    return [AdnetworkConfigure6110 adnetworkName];
}

+ (NSString *)getSDKVersion {
    return [AdnetworkConfigure6110 getSDKVersion];
}

// Instance Variableを初期化する。また、必要な場合Configureを生成する
-(id)init {
    self = [super init];
    if (self) {
        self.configure = [AdnetworkConfigure6110 sharedInstance];
    }
    return self;
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6110 alloc] initWithParam:data];
    self.configure.param = self.adParam; // Parameterを設定する
}

// Adnetwork SDKを初期化する
- (bool)initAdnetworkIfNeeded {
    if (![super initAdnetworkIfNeeded]) { // 初期化済みかParameterが設定されてないとそのままReturnする
        return false;
    }
    
    // SDK初期化はConfigureを使う
    __weak typeof(self) weakSelf = self;
    [self.configure initAdnetworkSDKWithCompletionHander:^(_Bool result) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        // 初期化完了後の実装が必要な場合こちらに追加する
        [strongSelf initCompleteAndRetryStartAdIfNeeded];
    }];
    return true;
}

// 広告読み込みを開始する
- (bool)startAd {
    if (![super startAd]) { // 読み込みが可能な状態かをチェックする
        return false;
    }
    
    @try {
        [self requireToAsyncRequestAd];
        [AdnetworkConfigure6110.sharedInstance setMovieRewardAdapter:self instanceId:((AdnetworkParam6110 *)self.adParam).instanceId];
//        [IronSource loadISDemandOnlyRewardedVideo:((AdnetworkParam6110 *)self.adParam).instanceId];
        
        
        [IronSource loadRewardedVideo];
        AdapterLog(@"load rewarded video");
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
    return true;
}

// 在庫取得有無を返す
- (BOOL)isPrepared {
    return self.isAdLoaded;
}

// 広告再生
- (void)showAd {
    UIViewController *vc = [self topMostViewController];
    if (vc) {
        [self showAdWithPresentingViewController:vc];
    } else {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAdWithPresentingViewController:viewController];
    
    if ([self isPrepared]) {
        @try {
            [self requireToAsyncPlay];
            [IronSource showISDemandOnlyRewardedVideo:viewController instanceId:((AdnetworkParam6110 *)self.adParam).instanceId];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    } else {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
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

@implementation MovieReward6116
@end

@implementation MovieReward6117
@end

@implementation MovieReward6118
@end

@implementation MovieReward6119
@end
