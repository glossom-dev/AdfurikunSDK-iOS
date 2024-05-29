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

@property (nonatomic, strong) VungleBanner *bannerAd;
@property (nonatomic) UIView *adView;

@end

@implementation Banner6006

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"11";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"VungleAdsSDK.VungleBanner";
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
        self.bannerSize = BannerSizeRegular;
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
        if (self.bannerAd) {
            self.bannerAd.delegate = nil;
            self.bannerAd = nil;
        }
        
        [self requireToAsyncRequestAd];
        
        self.bannerAd = [[VungleBanner alloc] initWithPlacementId:((AdnetworkParam6006 *)self.adParam).placementID
                                                             size:self.bannerSize];
        self.bannerAd.delegate = self;
        [self.bannerAd load:nil];
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

-(void)destroyAdViewIfNeeded {
    AdapterTrace;
    if (self.adView) {
        for (id subview in self.adView.subviews) {
          [subview removeFromSuperview];
        }
        [self.adView removeFromSuperview];
        self.adView = nil;
    }
    
}

- (void)dispose {
    [super dispose];
    
    [self destroyAdViewIfNeeded];
    
    if (self.bannerAd) {
        self.bannerAd.delegate = nil;
        self.bannerAd = nil;
    }
}

#pragma mark - VungleBanner Delegate Methods
// Ad load Events
- (void)bannerAdDidLoad:(VungleBanner *)banner {
    AdapterTrace;
    self.creativeId = banner.creativeId;
    
    CGRect viewSize = CGRectMake(0.0, 0.0, 300.0, 250.0);
    if (self.bannerSize == BannerSizeRegular) {
        viewSize = CGRectMake(0.0, 0.0, 320.0, 50.0);
    }
    
    [self destroyAdViewIfNeeded];
    
    self.adView = [[UIView alloc] initWithFrame:viewSize];
    [self.bannerAd presentOn:self.adView];
    AdapterLog(@"vungle 6006 addAdViewToView complete");
    NativeAdInfo6006 *info = [[NativeAdInfo6006 alloc] initWithVideoUrl:nil
                                                                  title:@""
                                                            description:@""
                                                           adnetworkKey:self.adnetworkKey];
    info.mediaType = ADFNativeAdType_Image;
    info.adapter = self;
    [info setupMediaView:self.adView];
    self.adInfo = info;
    
    [self setCustomMediaview:self.adView];
    
    [self setCallbackStatus:NativeAdCallbackLoadFinish];
}

- (void)bannerAdDidFailToLoad:(VungleBanner *)banner
                    withError:(NSError *)withError {
    AdapterTraceP(@"error : %@", withError);
    [self setLastError:withError];
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

// Ad Lifecycle Events
- (void)bannerAdWillPresent:(VungleBanner *)banner {
    AdapterTrace;
}

- (void)bannerAdDidPresent:(VungleBanner *)banner {
    AdapterTrace;
}

- (void)bannerAdDidFailToPresent:(VungleBanner *)banner
                       withError:(NSError *)withError {
    AdapterTraceP(@"error : %@", withError);
    [self setLastError:withError];
    [self setCallbackStatus:NativeAdCallbackPlayFail];
}

- (void)bannerAdDidTrackImpression:(VungleBanner *)banner {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackPlayStart];
}

- (void)bannerAdDidClick:(VungleBanner *)banner {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackClick];
}

- (void)bannerAdWillLeaveApplication:(VungleBanner *)banner {
    AdapterTrace;
}

- (void)bannerAdWillClose:(VungleBanner *)banner {
    AdapterTrace;
}

- (void)bannerAdDidClose:(VungleBanner *)banner {
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
