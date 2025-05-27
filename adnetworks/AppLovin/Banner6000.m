//
//  Banner6000.m
//
//  Created by Ren Fujii on 2019/07/26.
//  Copyright © 2019 ADFULLY Inc.
//
#import <AppLovinSDK/AppLovinSDK.h>
#import "Banner6000.h"
#import "AdnetworkConfigure6000.h"
#import "AdnetworkParam6000.h"

@interface Banner6000 () <ALAdLoadDelegate, ALAdDisplayDelegate>
@property (nonatomic, strong)ALAdView *adView;
@end

@implementation Banner6000

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"12";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"ALAdView";
}

// ADFで定義しているAdnetwork名。
+ (NSString *)adnetworkName {
    return [AdnetworkConfigure6000 adnetworkName];
}

+ (NSString *)getSDKVersion {
    return [AdnetworkConfigure6000 getSDKVersion];
}

+ (bool)isSupportForChild {
    return [AdnetworkConfigure6000 isSupportForChild];
}

// Instance Variableを初期化する。また、必要な場合Configureを生成する
-(id)init {
    self = [super init];
    if (self) {
        self.configure = [AdnetworkConfigure6000 sharedInstance];
    }
    return self;
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6000 alloc] initWithParam:data];
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
        if (!strongSelf.adView) {
            strongSelf.adView = [[ALAdView alloc] initWithSdk:[ALSdk shared]
                                                         size:ALAdSize.banner
                                               zoneIdentifier:((AdnetworkParam6000 *)strongSelf.adParam).zoneIdentifier];
            strongSelf.adView.adLoadDelegate = strongSelf;
            strongSelf.adView.adDisplayDelegate = strongSelf;
        }
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
        [self.adView loadNextAd];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
    return true;
}

- (bool)startAdWithOption:(NSDictionary *)option {
    return [self startAd];
}

// 在庫取得有無を返す
- (BOOL)isPrepared {
    return self.isAdLoaded;
}

// 後処理を実装
- (void)dispose {
    [super dispose];
}

#pragma mark - Ad Load Delegate

- (void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad {
    AdapterTrace;
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadFinish:)]) {
            NativeAdInfo6000 *info = [[NativeAdInfo6000 alloc] initWithVideoUrl:nil
                                                                          title:@""
                                                                    description:@""
                                                                   adnetworkKey:self.adnetworkKey];
            info.mediaType = ADFNativeAdType_Image;
            info.adapter = self;
            [info setupMediaView:self.adView];
            self.adInfo = info;
            
            [self setCallbackStatus:NativeAdCallbackLoadFinish];
            
        } else {
            AdapterLog(@"Banner6000: onNativeMovieAdLoadFinish selector is not responding");
        }
    } else {
        AdapterLog(@"Banner6000: Delegate is not setting");
    }
}

- (void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code {
    AdapterTraceP(@"code : %d", code);
    if (code) {
        [self setErrorWithMessage:nil code:code];
    }
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

#pragma mark - Ad Display Delegate

- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view {
    AdapterTrace;
}

- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view {
    AdapterTrace;
}

- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackClick];
}

@end

@implementation Banner6011
@end

@implementation Banner6012
@end

@implementation Banner6013
@end

@implementation Banner6014
@end

@implementation Banner6015
@end

@implementation Banner6210
@end

@implementation Banner6211
@end

@implementation Banner6212
@end

@implementation Banner6213
@end

@implementation NativeAdInfo6000

- (void)playMediaView {
    if (self.adapter) {
        [self.adapter setCallbackStatus:NativeAdCallbackRendering];
        [self.adapter setCustomMediaview:self.mediaView];
        [self.adapter startViewabilityCheck];
    }
}

@end
