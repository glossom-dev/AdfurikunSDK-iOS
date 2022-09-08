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
    return @"1";
}

// getinfoからのParameter設定
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    NSString *appKey = [data objectForKey:@"app_key"];
    if ([self isString:appKey]) {
        self.appKey = [NSString stringWithFormat:@"%@", appKey];
    }
    
    NSString *placement = [data objectForKey:@"placement"];
    if ([self isString:placement]) {
        self.placement = [NSString stringWithFormat:@"%@", placement];
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
    
    self.isAdLoaded = false;
    
    // Adnetwork SDKの関数を呼び出す際はTryーCatchでException Handlingを行う
    @try {
        // 非同期で行われる場合にはFlag設定を行う
        [self requireToAsyncRequestAd];
        
        AdnetworkConfigure6110.sharedInstance.movieRewardAdapter = self;
        [IronSource loadRewardedVideo];
        
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
    @try {
        [self requireToAsyncPlay];
        
        AdnetworkConfigure6110.sharedInstance.movieRewardAdapter = self;
        [IronSource showRewardedVideoWithViewController:viewController placement:self.placement];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

// Adnetwork SDKが設置されているかをチェックする
- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"IronSource");
    if (clazz) {
        AdapterLog(@"found Class: IronSource");
        return YES;
    } else {
        AdapterLog(@"Not found Class: IronSource");
        return NO;
    }
}

-(void)setHasUserConsent:(BOOL)hasUserConsent {
    [super setHasUserConsent:hasUserConsent];
    [IronSource setConsent:hasUserConsent];
    AdapterLogP(@"Adnetwork 6110, gdprConsent : %@, sdk setting value : %d", self.hasGdprConsent, (int)hasUserConsent);
}

@end
