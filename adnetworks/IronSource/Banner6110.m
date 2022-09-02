//
//  Banner6110.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2022/08/17.
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import "Banner6110.h"
#import "AdnetworkConfigure6110.h"

@interface Banner6110 ()

@property (nonatomic) NSString *appKey;
@property (nonatomic) NSString *placement;

@end

@implementation Banner6110

// SDKからバージョンを取得して返す
// APIがなければ削除
+ (NSString *)getSDKVersion {
    return [IronSource sdkVersion];
}

// Adapterのバージョン。最初は1にして、修正がある度＋1にする
+ (NSString *)getAdapterRevisionVersion {
    return @"1";
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
    // ロジックに合わせて修正する
    return self.isAdLoaded;
}

- (void)clearStatusIfNeeded {
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
    
    self.bannerSize = ISBannerSize_SMART;
    
    [AdnetworkConfigure6110.sharedInstance initIronSource:self.appKey completion:^{
        [self initCompleteAndRetryStartAdIfNeeded];
    }];
}

// 広告呼び込みを行う
- (void)startAd {
    // 初期化が完了しているかをチェック
    if (![self canStartAd]) {
        return;
    }
    
    UIViewController *topVC = [self topMostViewController];
    if (!topVC) {
        return;
    }
    
    self.isAdLoaded = false;

    [AdnetworkConfigure6110.sharedInstance destroyBannerView];
    
    // Adnetwork SDKの関数を呼び出す際はTryーCatchでException Handlingを行う
    @try {
        // 非同期で行われる場合にはFlag設定を行う
        [self requireToAsyncRequestAd];
        
        AdnetworkConfigure6110.sharedInstance.bannerAdapter = self;
        [IronSource loadBannerWithViewController:topVC size:self.bannerSize placement:self.placement];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (void)startAdWithOption:(NSDictionary *)option {
    [self startAd];
}

- (void)dispose {
    AdapterTrace;
    [AdnetworkConfigure6110.sharedInstance destroyBannerView];
}

/*
 * Adnetwork SDKからのCallbackに合わせてStatusを設定する
 [self setCallbackStatus:CALLBACKSTATUS]
 NativeAdCallbackLoadFinish：読み込み完了
 nativeAdInfoSetting Snippetを使って、NativeAdInfoを作成する
 NativeAdCallbackLoadError：読み込み失敗
 NativeAdCallbackRendering：画面に広告表示開始
 NativeAdCallbackPlayStart：動作再生開始、静止画のViewability Impression
 NativeAdCallbackPlayFinish：動画再生完了
 NativeAdCallbackPlayFail：再生失敗
 NativeAdCallbackClick：広告クリック
 */

@end

@implementation NativeAdInfo6110

- (void)playMediaView {
    if (self.adapter) {
        [self.adapter setCallbackStatus:NativeAdCallbackRendering];
        [self.adapter startViewabilityCheck];
    }
}

@end
