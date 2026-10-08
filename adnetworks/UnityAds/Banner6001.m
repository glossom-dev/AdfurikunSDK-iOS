//
//  Banner6001.m
//  MovieRewardTestApp
//
//  Created by Ren Fujii on 2019/07/25.
//  Copyright © 2019 Sungil Kim. All rights reserved.
//
#import <UnityAds/UnityAds.h>
#import "Banner6001.h"
#import "AdnetworkConfigure6001.h"
#import "AdnetworkParam6001.h"

@interface Banner6001 () <UADSBannerAdDelegate>
@property (nonatomic, strong) UADSBannerAd *bannerAd;
@end

@implementation Banner6001

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"14";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"UnityAds.UADSBannerAd";
}

// ADFで定義しているAdnetwork名。
+ (NSString *)adnetworkName {
    return [AdnetworkConfigure6001 adnetworkName];
}

+ (NSString *)getSDKVersion {
    return [AdnetworkConfigure6001 getSDKVersion];
}

// Instance Variableを初期化する。また、必要な場合Configureを生成する
-(id)init {
    self = [super init];
    if (self) {
        self.configure = [AdnetworkConfigure6001 sharedInstance];
    }
    return self;
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6001 alloc] initWithParam:data];
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
        if (self.bannerAd) {
            self.bannerAd = nil;
        }

        AdnetworkParam6001 *param = (AdnetworkParam6001 *)self.adParam;
        UADSBannerLoadConfiguration *configuration =
            [[[UADSBannerLoadConfigurationBuilder alloc] initWithPlacementId:param.placementId
                                                                  bannerSize:CGSizeMake(320.0, 50.0)
                                                                    delegate:self] build];

        __weak typeof(self) weakSelf = self;
        [UADSBannerAd load:configuration
                completion:^(UADSBannerAd * _Nullable banner, id<UnityAdsError> _Nullable error) {
            __strong typeof(self) strongSelf = weakSelf;
            if (!strongSelf) return;

            if (error || !banner) {
                // bannerが取得できずerrorもnilで返るケースがあるため、その場合はデフォルトのメッセージを使う
                NSInteger errorCode = error ? error.code : 0;
                NSString *errorMessage = error ? error.message : @"[ADF] UnityAds load returned nil banner without error";
                AdapterLogP(@"UnityAds Banner load error : code=%ld, message=%@", (long)errorCode, errorMessage);
                [strongSelf setErrorWithMessage:errorMessage code:errorCode];
                [strongSelf setCallbackStatus:NativeAdCallbackLoadError];
                return;
            }

            strongSelf.bannerAd = banner;
            [strongSelf bannerDidLoad:banner];
        }];
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

// startAd前の後処理
- (void)clearStatusIfNeeded {
}

// 後処理を実装
- (void)dispose {
    [super dispose];
}

-(void)dealloc {
    _bannerAd = nil;
}

#pragma mark - UADSBannerAdDelegate

// 旧 bannerViewDidLoad 相当。新APIではロード完了はload:completion:で受け取る
-(void)bannerDidLoad:(UADSBannerAd *)banner {
    AdapterTrace;
    UIView *mediaView = banner.view;
    NativeAdInfo6001 *info = [[NativeAdInfo6001 alloc] initWithVideoUrl:nil
                                                                  title:@""
                                                            description:@""
                                                           adnetworkKey:self.adnetworkKey];
    info.mediaType = ADFNativeAdType_Image;

    info.adapter = self;
    [info setupMediaView:mediaView];
    self.adInfo = info;

    [self setCustomMediaview:mediaView];
    [self startViewabilityCheck];
    [self setCallbackStatus:NativeAdCallbackLoadFinish];
}

-(void)bannerImpression:(UADSBannerAd *)banner {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackRendering];
    [self startViewabilityCheck];
}

-(void)bannerDidClick:(UADSBannerAd *)banner {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackClick];
}

-(void)bannerDidFailShow:(UADSBannerAd *)banner error:(id<UnityAdsError>)error {
    AdapterTraceP(@"UnityAds Banner show error : code=%ld, message=%@", (long)error.code, error.message);
    [self setErrorWithMessage:error.message code:error.code];
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

@end


@implementation NativeAdInfo6001

@end

@implementation Banner6030
@end

@implementation Banner6031
@end

@implementation Banner6032
@end

@implementation Banner6033
@end

@implementation Banner6034
@end

@implementation Banner6035
@end

@implementation Banner6036
@end

@implementation Banner6037
@end

@implementation Banner6038
@end
