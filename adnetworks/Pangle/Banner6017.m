//
//  Banner6017.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2021/01/14.
//  Copyright © 2021 Glossom, Inc. All rights reserved.
//

#import "Banner6017.h"
#import "AdnetworkConfigure6017.h"
#import "AdnetworkParam6017.h"

@interface Banner6017()<PAGBannerAdDelegate>

@property (nonatomic) PAGBannerAd *bannerAd;

@end

@implementation Banner6017

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"14";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"PAGBannerAd";
}

// ADFで定義しているAdnetwork名。
+ (NSString *)adnetworkName {
    return [AdnetworkConfigure6017 adnetworkName];
}

+ (NSString *)getSDKVersion {
    return [AdnetworkConfigure6017 getSDKVersion];
}

// Instance Variableを初期化する。また、必要な場合Configureを生成する
-(id)init {
    self = [super init];
    if (self) {
        self.configure = [AdnetworkConfigure6017 sharedInstance];
        self.adSize = kPAGBannerSize320x50;
    }
    return self;
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6017 alloc] initWithParam:data];
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
    
    UIViewController *topMostVC = [self topMostViewController];
    if (topMostVC == nil) {
        AdapterLog(@"TopMostViewController is nil");
        return false;
    }
    
    if (self.bannerAd) {
        self.bannerAd = nil;
    }

    @try {
        [self requireToAsyncRequestAd];
        PAGBannerRequest *request = [PAGBannerRequest requestWithBannerSize:self.adSize];
        
        __weak typeof(self) weakSelf = self;
        [PAGBannerAd loadAdWithSlotID:((AdnetworkParam6017 *)self.adParam).slotID
                              request:request
                    completionHandler:^(PAGBannerAd * _Nullable bannerAd, NSError * _Nullable error) {
            __strong typeof(self) strongSelf = weakSelf;
            if (!strongSelf) return;
            if (error) {
                [strongSelf setErrorWithMessage:error.localizedDescription code:error.code];
                [strongSelf setCallbackStatus:NativeAdCallbackLoadError];
                return;
            } else if (bannerAd == nil) {
                NSString *errorMsg = @"bannerAd is nil";
                AdapterTraceP(@"error : %@", errorMsg);
                [strongSelf setErrorWithMessage:errorMsg code:0];
                [strongSelf setCallbackStatus:NativeAdCallbackLoadError];
                return;
            }
            [strongSelf loadProcess:bannerAd];
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

- (void)loadProcess:(PAGBannerAd *)bannerAd {
    self.bannerAd = bannerAd;
    self.bannerAd.delegate = self;
    self.bannerAd.rootViewController = [self topMostViewController];
    
    NativeAdInfo6017 *info = [[NativeAdInfo6017 alloc] initWithVideoUrl:nil
                                                                  title:@""
                                                            description:@""
                                                           adnetworkKey:self.adnetworkKey];
    info.mediaType = ADFNativeAdType_Image;
    [info setupMediaView:self.bannerAd.bannerView];
    [self setCustomMediaview:self.bannerAd.bannerView];

    info.adapter = self;
    info.isCustomComponentSupported = false;
    self.adInfo = info;
    
    [self setCallbackStatus:NativeAdCallbackLoadFinish];
}

#pragma mark PAGBannerAdDelegate

- (void)adDidShow:(PAGBannerAd *)ad {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackRendering];
    [self startViewabilityCheck];
}

- (void)adDidClick:(PAGBannerAd *)ad {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackClick];
}

- (void)adDidDismiss:(PAGBannerAd *)ad {
    AdapterTrace;
}

@end

@implementation NativeAdInfo6017

@end

@implementation Banner6090
@end

@implementation Banner6091
@end

@implementation Banner6092
@end

@implementation Banner6093
@end

@implementation Banner6094
@end

@implementation Banner6095
@end

@implementation Banner6096
@end

@implementation Banner6097
@end

@implementation Banner6098
@end
