//
//  Banner6006.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/10/13.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "Banner6006.h"
#import "AdnetworkConfigure6006.h"
#import "AdnetworkParam6006.h"

@interface Banner6006()

@property (nonatomic, strong) VungleBannerView *bannerView;

@end

@implementation Banner6006

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"12";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"VungleAdsSDK.VungleBannerView";
}

// ADFで定義しているAdnetwork名。
+ (NSString *)adnetworkName {
    return [AdnetworkConfigure6006 adnetworkName];
}

+ (NSString *)getSDKVersion {
    return [AdnetworkConfigure6006 getSDKVersion];
}

// Instance Variableを初期化する。また、必要な場合Configureを生成する
-(id)init {
    self = [super init];
    if (self) {
        self.configure = [AdnetworkConfigure6006 sharedInstance];
        self.bannerSize = VungleAdSize.VungleAdSizeBannerRegular;
    }
    return self;
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6006 alloc] initWithParam:data];
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
        if (self.bannerView) {
            self.bannerView.delegate = nil;
            self.bannerView = nil;
        }
        
        [self requireToAsyncRequestAd];
        
        self.bannerView = [[VungleBannerView alloc] initWithPlacementId:((AdnetworkParam6006 *)self.adParam).placementID
                                                         vungleAdSize:self.bannerSize];
        self.bannerView.delegate = self;
        [self.bannerView load:nil];
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

- (void)dispose {
    [super dispose];
    
    if (self.bannerView) {
        self.bannerView.delegate = nil;
        self.bannerView = nil;
    }
}

#pragma mark - VungleBannerViewDelegate Delegate Methods
// Ad load Events
- (void)bannerAdDidLoad:(VungleBannerView *)bannerView {
    AdapterTrace;
    self.creativeId = bannerView.creativeId;
    NativeAdInfo6006 *info = [[NativeAdInfo6006 alloc] initWithVideoUrl:nil
                                                                  title:@""
                                                            description:@""
                                                           adnetworkKey:self.adnetworkKey];
    info.mediaType = ADFNativeAdType_Image;
    [info setupMediaView:bannerView];
    [self setCustomMediaview:bannerView];
    
    info.adapter = self;
    info.isCustomComponentSupported = false;
    
    self.adInfo = info;
    
    [self setCallbackStatus:NativeAdCallbackLoadFinish];
}

- (void)bannerAdDidFail:(VungleBannerView *)bannerView withError:(NSError *)withError {
    AdapterTraceP(@"error : %@", withError);
    [self setErrorWithMessage:withError.localizedDescription code:withError.code];
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

// Ad Lifecycle Events

- (void)bannerAdWillPresent:(VungleBannerView *)bannerView {
    AdapterTrace;
}

- (void)bannerAdDidPresent:(VungleBannerView *)bannerView {
    AdapterTrace;
}

- (void)bannerAdDidClose:(VungleBannerView *)bannerView {
    AdapterTrace;
}

- (void)bannerAdDidTrackImpression:(VungleBannerView *)bannerView {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackPlayStart];
}

- (void)bannerAdDidClick:(VungleBannerView *)bannerView {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackClick];
}

- (void)bannerAdWillLeaveApplication:(VungleBannerView *)bannerView {
    AdapterTrace;
}

@end

@implementation NativeAdInfo6006

- (void)playMediaView {
    if (self.adapter) {
        [self.adapter setCallbackStatus:NativeAdCallbackRendering];
    }
}

@end

@implementation Banner6200
@end

@implementation Banner6201
@end

@implementation Banner6202
@end

@implementation Banner6203
@end

@implementation Banner6204
@end

@implementation Banner6205
@end

@implementation Banner6206
@end

@implementation Banner6207
@end

@implementation Banner6208
@end
