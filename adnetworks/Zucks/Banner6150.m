//
//  Banner6150.m
//
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import "Banner6150.h"
#import "AdnetworkParam6150.h"
#import <ZucksAdNetworkSDK/ZADNBannerView.h>

@interface Banner6150 () <ZADNBannerViewDelegate>

@property (nonatomic) ZADNBannerView *bannerView;
@property (nonatomic) BOOL isStartAd; // startAdしたのか判定用
@property (nonatomic) AdnetworkParam6150 *adParam;

@end

@implementation Banner6150

// Adapterのバージョン。最初は1にして、修正がある度＋1にする
+ (NSString *)getAdapterRevisionVersion {
    return @"1";
}

// Adnetwork SDKが設置されているかをチェックする
- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"ZADNBannerView");
    if (clazz) {
        AdapterLog(@"found Class: Zucks");
        return YES;
    } else {
        AdapterLog(@"Not found Class: Zucks");
        return NO;
    }
}

// getinfoからのParameter設定
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6150 alloc] initWithParam:data];
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
    if (![self needsToInit]) {
        return;
    }
    if (!self.adParam || !self.adParam.frameId) {
        return;
    }
    self.bannerSize = [self adViewSize];
    self.bannerView = [[ZADNBannerView alloc] initWithFrame:self.bannerSize frameId:self.adParam.frameId];
    [self initCompleteAndRetryStartAdIfNeeded];
}

// 広告呼び込みを行う
- (void)startAd {
    AdapterTrace;
    
    if (!self.bannerView) {
        return;
    }
    
    [super startAd];

    self.isAdLoaded = false;
    self.isStartAd = true;

    // Adnetwork SDKの関数を呼び出す際はTryーCatchでException Handlingを行う
    @try {
        [self requireToAsyncRequestAd];
        
        self.bannerView.delegate = self;
        [self.bannerView loadAd];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (void)startAdWithOption:(NSDictionary *)option {
    [self startAd];
}

- (CGRect)adViewSize {
    return CGRectMake(0, 0, 320.0, 50.0);
}

- (void)dispose {
    AdapterTrace;
    if (self.bannerView) {
        self.bannerView = nil;
    }
}

#pragma mark ZADNBannerViewDelegate methods

- (void)bannerViewDidReceiveAd:(ZADNBannerView *)bannerView {
    AdapterTrace;
    // 広告表示後もこの関数が呼ばれる為、startAdした時のみ実行されるようにする。
    if (self.isStartAd == false) {
        return;
    }
    self.isStartAd = false;
    self.isAdLoaded = true;
    
    NativeAdInfo6150 *info = [[NativeAdInfo6150 alloc] initWithVideoUrl:nil
                                                                  title:@""
                                                            description:@""
                                                           adnetworkKey:@"6150"];
    info.mediaType = ADFNativeAdType_Image;
    info.adapter = self;
    [info setupMediaView:self.bannerView];
    self.adInfo = info;
    
    [self setCustomMediaview:self.bannerView];
    
    [self setCallbackStatus:NativeAdCallbackLoadFinish];
}

- (void)bannerView:(ZADNBannerView *)bannerView
didFailAdWithErrorType:(ZADNBannerErrorType)errorType {
    AdapterTraceP(@"Request failed with error type: %ld", errorType);
    self.isStartAd = false;
    [self setErrorWithMessage:nil code:errorType];
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

- (void)bannerViewDidTapAd:(ZADNBannerView *)bannerView {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackClick];
}

@end

@implementation NativeAdInfo6150

- (void)playMediaView {
    if (self.adapter) {
        [self.adapter setCallbackStatus:NativeAdCallbackRendering];
        [self.adapter startViewabilityCheck];
    }
}

@end

@implementation Banner6151
@end

@implementation Banner6152
@end

@implementation Banner6153
@end

@implementation Banner6154
@end

@implementation Banner6155
@end
