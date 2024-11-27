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
#import "AdnetworkParameter6001.h"

@interface Banner6001 () <UADSBannerViewDelegate>
@property (nonatomic, strong) UADSBannerView *bannerView;
@end

@implementation Banner6001

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"12";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"UADSBannerView";
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
    
    self.adParam = [[AdnetworkParameter6001 alloc] initWithParam:data];
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
            self.bannerView = nil;
        }
        self.bannerView = [[UADSBannerView alloc] initWithPlacementId:((AdnetworkParameter6001 *)self.adParam).placementId size:CGSizeMake(320.0, 50.0)];
        self.bannerView.delegate = self;
        [self.bannerView load];
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
    _bannerView = nil;
}

#pragma mark - UADSBannerViewDelegate

-(void)bannerViewDidLoad:(UADSBannerView *)bannerView {
    AdapterTrace;
    NativeAdInfo6001 *info = [[NativeAdInfo6001 alloc] initWithVideoUrl:nil
                                                                  title:@""
                                                            description:@""
                                                           adnetworkKey:self.adnetworkKey];
    info.mediaType = ADFNativeAdType_Image;

    info.adapter = self;
    [info setupMediaView:bannerView];
    self.adInfo = info;

    [self setCustomMediaview:bannerView];
    [self startViewabilityCheck];
    [self setCallbackStatus:NativeAdCallbackLoadFinish];
}

-(void)bannerViewDidShow:(UADSBannerView *)bannerView {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackRendering];
    [self startViewabilityCheck];
}

-(void)bannerViewDidClick:(UADSBannerView *)bannerView {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackClick];
}

-(void)bannerViewDidLeaveApplication:(UADSBannerView *)bannerView {
    AdapterTrace;
}

-(void)bannerViewDidError:(UADSBannerView *)bannerView error:(UADSBannerError *)error {
    AdapterTraceP(@"UnityAds Banner load error :%d", (int)error.code);
    if (error) {
        [self setErrorWithMessage:@"" code:error.code];
    }
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
