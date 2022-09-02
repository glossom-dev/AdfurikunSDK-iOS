//
//  MovieInterstitial6110.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2022/08/16.
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import "MovieInterstitial6110.h"
#import "AdnetworkConfigure6110.h"

@implementation MovieInterstitial6110

// Adapterのバージョン。最初は1にして、修正がある度＋1にする
+ (NSString *)getAdapterRevisionVersion {
    return @"1";
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
        
        AdnetworkConfigure6110.sharedInstance.interstitialAdapter = self;
        [IronSource loadInterstitial];
        
        AdapterLog(@"load interstitial video");
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    @try {
        [self requireToAsyncPlay];
        
        AdnetworkConfigure6110.sharedInstance.interstitialAdapter = self;
        [IronSource showInterstitialWithViewController:viewController placement:self.placement];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

@end
