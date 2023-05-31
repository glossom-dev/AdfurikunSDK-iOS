//
//  MovieNative6017.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/10/23.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "MovieNative6017.h"
#import "MovieReward6017.h"

#pragma mark MovieNative6017

@interface MovieNative6017()

@property (nonatomic) BUNativeAd *nativeAd;
@property (nonatomic) BUNativeAdRelatedView *relatedView;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) NSString *pangleAppID;
@property (nonatomic) NSString *pangleSlotID;
@property (nonatomic) BOOL didSendPlayStartCallback;
@property (nonatomic) BOOL didSendPlayFinishCallback;

@end

@implementation MovieNative6017

+ (NSString *)getSDKVersion {
    return BUAdSDKManager.SDKVersion;
}

+ (NSString *)getAdapterRevisionVersion {
    return @"6";
}

- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"BUNativeAd");
    if (clazz) {
        AdapterLog(@"found Class: BUNativeAd");
        return YES;
    }
    else {
        AdapterLog(@"Not found Class: BUNativeAd");
        return NO;
    }
    return YES;
}

// getinfoから取得したデータを内部変数に保存する
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    NSString *appID = [data objectForKey:@"appid"];
    if ([self isNotNull:appID]) {
        self.pangleAppID = [NSString stringWithFormat:@"%@", appID];
    }
    NSString *slotID = [data objectForKey:@"ad_slot_id"];
    if ([self isNotNull:slotID]) {
        self.pangleSlotID = [NSString stringWithFormat:@"%@", slotID];
    }
}

// SDKの初期化ロジックを入れる。ただし、Instance化を毎回する必要がある場合にはこちらではなくてSstartAdで行うこと
-(void)initAdnetworkIfNeeded {
    if (![self needsToInit]) {
        return;
    }

    AdapterLog(@"MovieNatve6017 initAdnetworkIfNeeded");
    if (self.pangleAppID) {
        @try {
            [self requireToAsyncInit];
            
            [MovieConfigure6017.sharedInstance configureWithAppId:self.pangleAppID
                                                       gdprStatus:self.hasGdprConsent
                                                    childDirected:self.childDirected
                                                       completion:^{
                [self initCompleteAndRetryStartAdIfNeeded];
            }];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    }
}

- (void)clearStatusIfNeeded {
}

- (BOOL)isPrepared {
    return self.isAdLoaded;
}

// SDKのLoading関数を呼び出す
- (void)startAd {
    if (![self canStartAd]) {
        return;
    }

    if (self.pangleAppID == nil || self.pangleSlotID == nil) {
        return;
    }
    AdapterTrace;
    
    if (self.nativeAd) {
        self.nativeAd = nil;
    }
    
    [super startAd];
    
    @try {
        [self requireToAsyncRequestAd];
        
        self.nativeAd = [BUNativeAd new];
        BUAdSlot *slot = [[BUAdSlot alloc] init];
        BUSize *imgSize = [BUSize sizeBy:BUProposalSize_Feed690_388];
        //BUSize *imgSize = [BUSize sizeBy:BUProposalSize_Banner600_90];
        slot.ID = self.pangleSlotID;
        slot.AdType = BUAdSlotAdTypeFeed;
        slot.position = BUAdSlotPositionFeed;
        slot.imgSize = imgSize;
        self.nativeAd.adslot = slot;
        
        self.nativeAd.rootViewController = [self topMostViewController];
        self.nativeAd.delegate = self;
        
        [self.nativeAd loadAdData];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (void)startAdWithOption:(NSDictionary *)option {
    [self startAd];
}

#pragma mark BUNativeAdDelegate

/**
This method is called when native ad material loaded successfully.
*/
- (void)nativeAdDidLoad:(BUNativeAd *)nativeAd {
    AdapterTraceP(@"nativeAd : %@", nativeAd);
    BUMaterialMeta *adMeta = nativeAd.data;
    MovieNativeAdInfo6017 *info = [[MovieNativeAdInfo6017 alloc] initWithVideoUrl:nil
                                                                            title:adMeta.AdTitle
                                                                      description:adMeta.AdDescription
                                                                     adnetworkKey:@"6017"];
    if (adMeta.imageMode == BUFeedVideoAdModeImage ||
        adMeta.imageMode == BUFeedVideoAdModePortrait ||
        adMeta.imageMode == BUFeedADModeSquareVideo) {
        if (self.relatedView) {
            self.relatedView = nil;
        }
        
        info.mediaType = ADFNativeAdType_Movie;
        self.relatedView = [[BUNativeAdRelatedView alloc] init];
        [self.relatedView refreshData:nativeAd];
        self.relatedView.videoAdView.delegate = self;
        [info setupMediaView:self.relatedView.videoAdView];
        [self setCustomMediaview:self.relatedView.videoAdView];
        
        [self.nativeAd registerContainer:self.relatedView.videoAdView withClickableViews:@[self.relatedView.videoAdView]];
    } else {
        if (adMeta.imageAry.count == 0 || adMeta.imageAry.firstObject.imageURL.length == 0) {
            AdapterLogP(@"metadata is invalid %@", adMeta);
            [self sendLoadError:nil];
            return;
        }

        if (self.imageView) {
            self.imageView = nil;
        }
        
        info.mediaType = ADFNativeAdType_Image;
        BUImage *buImage = adMeta.imageAry.firstObject;
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:buImage.imageURL]]];
        self.imageView = [[UIImageView alloc] initWithImage:image];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [info setupMediaView:self.imageView];
        [self setCustomMediaview:self.imageView];
        
        [self.nativeAd registerContainer:self.imageView withClickableViews:@[self.imageView]];
    }
    info.adapter = self;
    info.isCustomComponentSupported = false;
    self.nativeAd = nativeAd;
    
    self.didSendPlayStartCallback = false;
    self.didSendPlayFinishCallback = false;
    
    self.adInfo = info;

    [self setCallbackStatus:NativeAdCallbackLoadFinish];
}

- (void)sendLoadError:(NSError *)error {
    AdapterLogP(@"error : %@", error);
    if (error) {
        [self setErrorWithMessage:error.localizedDescription code:error.code];
    }
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

- (void)sendRendering {
    [self setCallbackStatus:NativeAdCallbackRendering];
}

- (void)sendPlayStart {
    if (self.didSendPlayStartCallback) {
        return;;
    }
    self.didSendPlayStartCallback = true;
    [self setCallbackStatus:NativeAdCallbackPlayStart];
}

/**
This method is called when native ad materia failed to load.
@param error : the reason of error
*/
- (void)nativeAd:(BUNativeAd *)nativeAd didFailWithError:(NSError *_Nullable)error {
    AdapterTraceP(@"error : %@", error);
    [self sendLoadError:error];
}

/**
This method is called when native ad slot has been shown.
*/
- (void)nativeAdDidBecomeVisible:(BUNativeAd *)nativeAd {
    AdapterTrace;
    if (self.adInfo.mediaType == ADFNativeAdType_Image) {
        [self sendRendering];
        [self startViewabilityCheck];
    }
}

/**
This method is called when native ad is clicked.
*/
- (void)nativeAdDidClick:(BUNativeAd *)nativeAd withView:(UIView *_Nullable)view {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackClick];
}

/**
This method is called when the user clicked dislike reasons.
Only used for dislikeButton in BUNativeAdRelatedView.h
@param filterWords : reasons for dislike
*/
- (void)nativeAd:(BUNativeAd *)nativeAd dislikeWithReason:(NSArray<BUDislikeWords *> *)filterWords {
    AdapterTrace;
}

#pragma mark BUVideoAdViewDelegate

/**
This method is called when videoadview failed to play.
@param error : the reason of error
*/
- (void)videoAdView:(BUVideoAdView *)videoAdView didLoadFailWithError:(NSError *_Nullable)error {
    AdapterTraceP(@"error : %@", error);
    [self setCallbackStatus:NativeAdCallbackPlayFail];
}

/**
This method is called when videoadview playback status changed.
@param playerState : player state after changed
*/
- (void)videoAdView:(BUVideoAdView *)videoAdView stateDidChanged:(BUPlayerPlayState)playerState {
    AdapterTraceP(@"state : %d", (int)playerState);
    if (playerState == BUPlayerStatePlaying) {
        [self sendPlayStart];
    }
}

/**
This method is called when videoadview end of play.
*/
- (void)playerDidPlayFinish:(BUVideoAdView *)videoAdView {
    AdapterTrace;
    if (self.didSendPlayFinishCallback) {
        return;;
    }
    self.didSendPlayFinishCallback = true;

    [self setCallbackStatus:NativeAdCallbackPlayFinish];
}

@end

#pragma mark MovieNativeAdInfo6017

@implementation MovieNativeAdInfo6017

- (void)playMediaView {
    NSLog(@"[ADF] %s", __func__);
}

@end

@implementation MovieNative6090

@end

@implementation MovieNative6091

@end

@implementation MovieNative6092

@end
