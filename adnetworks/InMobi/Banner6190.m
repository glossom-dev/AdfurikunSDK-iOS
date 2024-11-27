//
//  Banner6190.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/10/29.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import "Banner6190.h"

@interface Banner6190()
@property (nonatomic, strong) IMBanner *banner;
@end

@implementation Banner6190

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"1";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"InMobiSDK.IMBanner";
}

// ADFで定義しているAdnetwork名。
+ (NSString *)adnetworkName {
    return [AdnetworkConfigure6190 adnetworkName];
}

+ (NSString *)getSDKVersion {
    return [AdnetworkConfigure6190 getSDKVersion];
}

// Instance Variableを初期化する。また、必要な場合Configureを生成する
-(id)init {
    self = [super init];
    if (self) {
        self.configure = [AdnetworkConfigure6190 sharedInstance];
        self.bannerSize = CGRectMake(0.0, 0.0, 320.0, 50.0);
    }
    return self;
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6190 alloc] initWithParam:data];
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
        // 初期化完了後の実装が必要な場合こちらに追加する
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
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
        
        if (self.banner) {
            self.banner.delegate = nil;
            self.banner = nil;
        }
        
        AdnetworkParam6190 *param = (AdnetworkParam6190 *)self.adParam;
        self.banner = [[IMBanner alloc] initWithFrame: self.bannerSize
                                          placementId:param.placementId.integerValue];
        self.banner.delegate = self;
        [self.banner shouldAutoRefresh:false];
        
        [self.banner load];
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
    if (self.banner) {
        self.banner.delegate = nil;
        self.banner = nil;
    }
}

#pragma mark IMBannerDelegate
- (void)banner:(IMBanner*)banner didReceiveWithMetaInfo:(IMAdMetaInfo*)info {
    AdapterTrace;
}

- (void)bannerDidFinishLoading:(IMBanner *)banner {
    AdapterTrace;
    NativeAdInfo6190 *info = [[NativeAdInfo6190 alloc] initWithVideoUrl:nil
                                                                  title:@""
                                                            description:@""
                                                           adnetworkKey:self.adnetworkKey];
    
    info.mediaType = ADFNativeAdType_Image;
    info.isCustomComponentSupported = false;
    info.adapter = self;
    [info setupMediaView:self.banner];
    [self setCustomMediaview:self.banner];

    self.adInfo = info;
      
    self.creativeId = banner.creativeId;
    
    [self setCallbackStatus:NativeAdCallbackLoadFinish];
}

- (void)banner:(IMBanner *)banner didFailToLoadWithError:(IMRequestStatus *)error {
    AdapterTraceP(@"banner failed to load ad : %@", error);
    [self setError:error];
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

- (void)bannerWillPresentScreen:(IMBanner *)banner {
    AdapterTrace;
}

- (void)bannerDidPresentScreen:(IMBanner *)banner {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackClick];
}

- (void)bannerWillDismissScreen:(IMBanner *)banner {
    AdapterTrace;
}

- (void)bannerDidDismissScreen:(IMBanner *)banner {
    AdapterTrace;
}

- (void)userWillLeaveApplicationFromBanner:(IMBanner *)banner {
    AdapterTrace;
}

-(void)banner:(IMBanner *)banner didInteractWithParams:(NSDictionary *)params{
    AdapterTrace;
}

-(void)banner:(IMBanner*)banner rewardActionCompletedWithRewards:(NSDictionary*)rewards{
    AdapterTrace;
}

@end

@implementation NativeAdInfo6190

- (void)playMediaView {
    if (self.adapter) {
        [self.adapter setCallbackStatus:NativeAdCallbackRendering];
        [self.adapter startViewabilityCheck];
    }
}

@end

@implementation Banner6191
@end

@implementation Banner6192
@end

@implementation Banner6193
@end

@implementation Banner6194
@end

@implementation Banner6195
@end

@implementation Banner6196
@end

@implementation Banner6197
@end

@implementation Banner6198
@end

@implementation Banner6199
@end
