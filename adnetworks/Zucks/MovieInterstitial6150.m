//
//  MovieInterstitial6150.m
//
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import "MovieInterstitial6150.h"
#import "AdnetworkParam6150.h"
#import <ZucksAdNetworkSDK/ZADNFullScreenInterstitialView.h>

@interface MovieInterstitial6150 () <ZADNFullScreenInterstitialViewDelegate>

@property (nonatomic) AdnetworkParam6150 *adParam;

@end

@implementation MovieInterstitial6150

// Adapterのバージョン。最初は1にして、修正がある度＋1にする
+ (NSString *)getAdapterRevisionVersion {
    return @"1";
}

// getinfoからのParameter設定
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6150 alloc] initWithParam:data];
}

// 広告準備有無を返す
- (BOOL)isPrepared {
    AdapterTrace;
    return self.isAdLoaded;
}

//// Adnetwork SDKの初期化を行う
//- (void)initAdnetworkIfNeeded {
//}

// 広告呼び込みを行う
- (void)startAd {
    AdapterTrace;
    
    if (!self.adParam || !self.adParam.frameId) {
        return;
    }
    
    [super startAd];
    
    // Adnetwork SDKの関数を呼び出す際はTryーCatchでException Handlingを行う
    @try {
        [self requireToAsyncRequestAd];
        
        [ZADNFullScreenInterstitialView sharedInstance].frameId = self.adParam.frameId;
        [ZADNFullScreenInterstitialView sharedInstance].delegate = self;
        [[ZADNFullScreenInterstitialView sharedInstance] loadAd];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

// 広告再生関数
// showAdWithPresentingViewController と両方を必ず実装する
- (void)showAd {
    [super showAd];
    
    @try {
        [[ZADNFullScreenInterstitialView sharedInstance] show];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [self showAd];
}

// Adnetwork SDKが設置されているかをチェックする
- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"ZADNFullScreenInterstitialView");
    if (clazz) {
        AdapterLog(@"found Class: Zucks");
        return YES;
    } else {
        AdapterLog(@"Not found Class: Zucks");
        return NO;
    }
}

#pragma mark - ZADNFullScreenInterstitialViewDelegate methods

- (void)fullScreenInterstitialViewDidReceiveAd {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

- (void)fullScreenInterstitialViewDidLoadFailAdWithErrorType:
            (ZADNFullScreenInterstitialLoadErrorType)errorType {
    AdapterTraceP(@"Request failed with error type: %ld", errorType);
    [self setErrorWithMessage:nil code:errorType];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

- (void)fullScreenInterstitialViewDidShowAd {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)fullScreenInterstitialViewDidTapAd {
    AdapterTrace;
}

- (void)fullScreenInterstitialViewDidDismissAd {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    [self setCallbackStatus:MovieRewardCallbackClose];
}

//表示率設定により表示がキャンセルされた場合に通知されます。
- (void)fullScreenInterstitialViewCancelDisplayRate {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}

- (void)fullScreenInterstitialViewDidShowFailAdWithErrorType:
            (ZADNFullScreenInterstitialShowErrorType)errorType {
    AdapterTraceP(@"Request failed with error type: %ld", errorType);
    [self setErrorWithMessage:nil code:errorType];
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}

@end

// 同時に複数の枠を扱えない為マルチゾーン対応出来ない
//@implementation MovieInterstitial6151
//@end
//
//@implementation MovieInterstitial6152
//@end
//
//@implementation MovieInterstitial6153
//@end
//
//@implementation MovieInterstitial6154
//@end
//
//@implementation MovieInterstitial6155
//@end
