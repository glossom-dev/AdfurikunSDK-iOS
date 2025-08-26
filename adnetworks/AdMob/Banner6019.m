//
//  Banner6019.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/02/10.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "Banner6019.h"
#import "AdnetworkConfigure6019.h"
#import "AdnetworkParam6019.h"

#import <WebKit/WebKit.h>

#import <GoogleMobileAds/GoogleMobileAds.h>

@implementation Banner6019

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"15";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"GADBannerView";
}

// ADFで定義しているAdnetwork名。
+ (NSString *)adnetworkName {
    return [AdnetworkConfigure6019 adnetworkName];
}

// Instance Variableを初期化する。また、必要な場合Configureを生成する
-(id)init {
    self = [super init];
    if (self) {
        self.configure = [AdnetworkConfigure6019 sharedInstance];
    }
    return self;
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6019 alloc] initWithParam:data];
    self.configure.param = self.adParam; // Parameterを設定する
}

// Adnetwork SDKを初期化する
- (bool)initAdnetworkIfNeeded {
    self.adSize = GADAdSizeBanner;
    
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
    return [self startAdWithOption:nil];
}

- (bool)startAdWithOption:(NSDictionary *)option {
    if (self.bannerView) {
        [self.bannerView removeFromSuperview];
        self.bannerView = nil;
    }
    @try {
        self.isBannerViewLoaded = false;
        
        self.bannerView = [[GADBannerView alloc] initWithAdSize:self.adSize];
        self.bannerView.adUnitID = ((AdnetworkParam6019 *)self.adParam).unitID;
        self.bannerView.rootViewController = [self topMostViewController];
        self.bannerView.delegate = self;
        
        GADRequest *request = [GADRequest request];
        if (option) {
            AdapterLogP(@"custom event option : %@", option);
            NSString *label = option[@"label"];
            if (label) {
                GADCustomEventExtras *extras = [[GADCustomEventExtras alloc] init];
                [extras setExtras:option forLabel:label];
                [request registerAdNetworkExtras:extras];
            }
        }
        [(AdnetworkConfigure6019 *)self.configure setHasGdprConsent:self.hasGdprConsent request:request];
        [self requireToAsyncRequestAd];
        [self.bannerView loadRequest:request];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
    return true;
}

// 在庫取得有無を返す
- (BOOL)isPrepared {
    return self.isAdLoaded;
}

// 後処理を実装
- (void)dispose {
    [super dispose];
}

- (void)callbackClick {
    [self setCallbackStatus:NativeAdCallbackClick];
}

- (void)dealloc {
    if (self.bannerView) {
        [self.bannerView removeFromSuperview];
        self.bannerView = nil;
    }
}

#pragma mark - GADBannerViewDelegate

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    AdapterTrace;
    if (self.isBannerViewLoaded) {
        return;
    }
    self.isBannerViewLoaded = true;
    
    BannerAdInfo6019 *info = [[BannerAdInfo6019 alloc] initWithVideoUrl:nil
                                                                  title:@""
                                                            description:@""
                                                           adnetworkKey:self.adnetworkKey];
    info.mediaType = ADFNativeAdType_Image;
    info.adapter = self;
    [info setupMediaView:self.bannerView];
    self.adInfo = info;

    [self setCustomMediaview:self.bannerView];
    
    [self setCallbackStatus:NativeAdCallbackLoadFinish];
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    AdapterTraceP(@"error: %@", error);
    [self setError:error];
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
    AdapterTrace;
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {
    AdapterTrace;
}

- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {
    AdapterTrace;
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {
    AdapterTrace;
}

- (void)bannerViewDidRecordClick:(GADBannerView *)bannerView {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackClick];
}

@end

@implementation BannerAdInfo6019

- (void)playMediaView {
    if (self.adapter) {
        [self.adapter setCallbackStatus:NativeAdCallbackRendering];
        [self.adapter startViewabilityCheck];
    }
}

@end

@implementation Banner6060

+ (NSString *)adnetworkName {
    return @"Google Ad Manager";
}

@end

@implementation Banner6220
@end
