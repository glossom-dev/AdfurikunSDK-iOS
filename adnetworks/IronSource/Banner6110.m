//
//  Banner6110.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2022/08/17.
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import "Banner6110.h"
#import "AdnetworkConfigure6110.h"

@interface Banner6110 ()

@property (nonatomic) NSString *appKey;
@property (nonatomic) NSString *instanceId;

@end

@implementation Banner6110

// SDKからバージョンを取得して返す
// APIがなければ削除
+ (NSString *)getSDKVersion {
    return [IronSource sdkVersion];
}

// Adapterのバージョン。最初は1にして、修正がある度＋1にする
+ (NSString *)getAdapterRevisionVersion {
    return @"6";
}

+ (NSString *)adnetworkClassName {
    return @"IronSource";
}

+ (NSString *)adnetworkName {
    return @"ironSource";
}

// getinfoからのParameter設定
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    NSString *appKey = [data objectForKey:@"app_key"];
    if ([self isString:appKey]) {
        self.appKey = [NSString stringWithFormat:@"%@", appKey];
    }

    NSString *instanceId = [data objectForKey:@"instance_id"];
    if ([self isString:instanceId]) {
        self.instanceId = [NSString stringWithFormat:@"%@", instanceId];
    }
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
    // 一回のみ初期化を行うようなチェックを行う
    if (![self needsToInit]) {
        return;
    }
    
    if (!self.appKey) {
        return;
    }
    
    self.bannerSize = ISBannerSize_BANNER;
    [AdnetworkConfigure6110.sharedInstance initIronSource:self.appKey completion:^{
        [self initCompleteAndRetryStartAdIfNeeded];
        [IronSource setISDemandOnlyBannerDelegate:self forInstanceId:self.instanceId];
    }];
}

// 広告呼び込みを行う
- (void)startAd {
    // 初期化が完了しているかをチェック
    if (![self canStartAd]) {
        return;
    }
    
    UIViewController *topVC = [self topMostViewController];
    if (!topVC) {
        return;
    }
    
    [super startAd];

    if (self.bannerView) {
        self.bannerView = nil;
    }
    
    // Adnetwork SDKの関数を呼び出す際はTryーCatchでException Handlingを行う
    @try {
        // 非同期で行われる場合にはFlag設定を行う
        [self requireToAsyncRequestAd];

        [IronSource loadISDemandOnlyBannerWithInstanceId:self.instanceId
                                          viewController:topVC
                                                    size:self.bannerSize];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (void)startAdWithOption:(NSDictionary *)option {
    [self startAd];
}

- (void)dispose {
    AdapterTrace;
    if (self.bannerView) {
        self.bannerView = nil;
    }
    [IronSource destroyISDemandOnlyBannerWithInstanceId:self.instanceId];
}

-(void)setHasUserConsent:(BOOL)hasUserConsent {
    [super setHasUserConsent:hasUserConsent];
    [IronSource setConsent:hasUserConsent];
    AdapterLogP(@"Adnetwork 6110, gdprConsent : %@, sdk setting value : %d", self.hasGdprConsent, (int)hasUserConsent);
}

- (void)isChildDirected:(BOOL)childDirected {
    [super isChildDirected:childDirected];
    [IronSource setMetaDataWithKey:@"is_child_directed" value:childDirected ? @"YES": @"NO"];
    AdapterLogP(@"Adnetwork %@, childDirected : %@, input parameter : %d", self.adnetworkKey, self.childDirected, (int)childDirected);
}

/*
 * Adnetwork SDKからのCallbackに合わせてStatusを設定する
 [self setCallbackStatus:CALLBACKSTATUS]
 NativeAdCallbackLoadFinish：読み込み完了
 nativeAdInfoSetting Snippetを使って、NativeAdInfoを作成する
 NativeAdCallbackLoadError：読み込み失敗
 NativeAdCallbackRendering：画面に広告表示開始
 NativeAdCallbackPlayStart：動作再生開始、静止画のViewability Impression
 NativeAdCallbackPlayFinish：動画再生完了
 NativeAdCallbackPlayFail：再生失敗
 NativeAdCallbackClick：広告クリック
 */

/**
 Called after a banner ad has been successfully loaded
 @param bannerView The view that contains the ad.
 @param instanceId The demand only instance id to be used to display the banner.
 */
- (void)bannerDidLoad:(ISDemandOnlyBannerView *)bannerView instanceId:(NSString *)instanceId {
    AdapterTrace;
    NativeAdInfo6110 *info = [[NativeAdInfo6110 alloc] initWithVideoUrl:nil
                                                                  title:@""
                                                            description:@""
                                                           adnetworkKey:self.adnetworkKey];
    info.mediaType = ADFNativeAdType_Image;
    [info setupMediaView:bannerView];
    [self setCustomMediaview:bannerView];
    self.bannerView = bannerView;
    
    info.adapter = self;
    info.isCustomComponentSupported = false;
    
    self.adInfo = info;
    
    [self setCallbackStatus:NativeAdCallbackLoadFinish];
}

/**
 Called after a banner has attempted to load an ad but failed.
 @param error The reason for the error
 @param instanceId The demand only instance id that fail to load.
 */
- (void)bannerDidFailToLoadWithError:(NSError *)error instanceId:(NSString *)instanceId {
    AdapterTraceP(@"error : %@", error);
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

/**
 Called when a banner was shown
 @param instanceId The demand only instance id which did show.

 */
- (void)bannerDidShow:(NSString *)instanceId {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackRendering];
    [self startViewabilityCheck];
}

/**
 Called after a banner has been clicked.
 @param instanceId The demand only instance id which clicked.

 */
- (void)didClickBanner:(NSString *)instanceId {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackClick];
}


/**
 Called when a user would be taken out of the application context.
 @param instanceId The demand only instance id that taken out of the application.

 */
- (void)bannerWillLeaveApplication:(NSString *)instanceId {
    AdapterTrace;
}

@end

@implementation NativeAdInfo6110

- (void)playMediaView {
}

@end

@implementation Banner6111
@end

@implementation Banner6112
@end

@implementation Banner6113
@end

@implementation Banner6114
@end

@implementation Banner6115
@end
