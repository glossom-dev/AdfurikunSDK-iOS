//
//  Banner6006.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/10/13.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "Banner6006.h"
#import "MovieReward6006.h"

@interface Banner6006()

@property (nonatomic, strong)NSString* vungleAppID;
@property (nonatomic) NSString *placementID;
@property (nonatomic) NSArray *allPlacementIDs;
@property (nonatomic) UIView *adView;
@property (nonatomic) BOOL sendCallback;

@end

@implementation Banner6006

+ (NSString *)getSDKVersion {
    return VungleSDKVersion;
}

- (BOOL)isClassReference {
    NSLog(@"Banner6006 isClassReference");
    Class clazz = NSClassFromString(@"VungleSDK");
    if (clazz) {
        NSLog(@"Found Class: Vungle");
    }
    else {
        NSLog(@"Not found Class: Vungle");
        return NO;
    }
    return YES;
}

- (void)dispose {
    [super dispose];
    if (self.placementID) {
        @try {
            MovieDelegate6006 *delegate = [MovieDelegate6006 sharedInstance];
            [delegate removeBannerInZone:self.placementID];
            
            VungleSDK* sdk = [VungleSDK sharedSDK];
            [sdk finishDisplayingAd:self.placementID];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    }
}

// getinfoから取得したデータを内部変数に保存する
- (void)setData:(NSDictionary *)data {
    [super setData:data];

    NSString* vungleAppID = [data objectForKey:@"application_id"];
    if ([self isNotNull:vungleAppID]) {
        self.vungleAppID = [[NSString alloc] initWithFormat:@"%@", vungleAppID];
    }
    NSString *placementID = [data objectForKey:@"placement_reference_id"];
    if ([self isNotNull:placementID]) {
        self.placementID = [NSString stringWithFormat:@"%@", placementID];
    }
    NSArray *placementIDs = [data objectForKey:@"all_placements"];
    if ([self isNotNull:placementIDs] && [placementIDs isKindOfClass:[NSArray class]]) {
        self.allPlacementIDs = [NSArray arrayWithArray:placementIDs];
    }

    if (self.vungleAppID == nil || self.placementID == nil) {
        NSLog(@"%s Vungle data is invalid", __PRETTY_FUNCTION__);
        return;
    }
    if (self.allPlacementIDs.count == 0) {
        self.allPlacementIDs = @[self.placementID];
    }

    NSNumber *pixelRateNumber = data[@"pixelRate"];
    if ([self isNotNull:pixelRateNumber] && [pixelRateNumber isKindOfClass:[NSNumber class]]) {
        self.viewabilityPixelRate = pixelRateNumber.intValue;
    }
    NSNumber *displayTimeNumber = data[@"displayTime"];
    if ([self isNotNull:displayTimeNumber] && [displayTimeNumber isKindOfClass:[NSNumber class]]) {
        self.viewabilityDisplayTime = displayTimeNumber.intValue;
    }
    NSNumber *timerIntervalNumber = data[@"timerInterval"];
    if ([self isNotNull:timerIntervalNumber] && [timerIntervalNumber isKindOfClass:[NSNumber class]]) {
        self.viewabilityTimerInterval = timerIntervalNumber.intValue;
    }
}

- (void)initVungle {
    @try {
        if ([VungleSDK sharedSDK].isInitialized) {
            return;
        }
        NSError *error;
        if (![[VungleSDK sharedSDK] startWithAppId:self.vungleAppID error:&error]) {
            NSLog(@"%s Error while starting VungleSDK %@", __FUNCTION__, [error localizedDescription]);
        }
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

-(void)initAdnetworkIfNeeded {
    MovieDelegate6006 *delegate = [MovieDelegate6006 sharedInstance];
    [delegate setBanner:self inZone:self.placementID];
    [[VungleSDK sharedSDK] setDelegate:delegate];
    [[VungleSDK sharedSDK] setLoggingEnabled:YES];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self initVungle];
    });
    //音出力設定
    ADFMovieOptions_Sound soundState = [ADFMovieOptions getSoundState];
    if (ADFMovieOptions_Sound_On == soundState) {
        [VungleSDK sharedSDK].muted = false;
    } else if (ADFMovieOptions_Sound_Off == soundState) {
        [VungleSDK sharedSDK].muted = true;
    }

    self.isBannerSize = true;
}

- (void)clearStatusIfNeeded {

}

- (BOOL)isPrepared {
    if (!self.delegate || !self.placementID) {
        return NO;
    }
    return [[VungleSDK sharedSDK] isAdCachedForPlacementID:self.placementID];
}

// SDKのLoading関数を呼び出す
- (void)startAd {
    @try {
        VungleSDK *sdk = [VungleSDK sharedSDK];
        if (!sdk.initialized) {
            self.isNeedToStartAd = YES;
            return;
        }
        
        [super startAd];
        
        if (!self.placementID) {
            return;
        }
        
        self.isAdLoaded = false;
        self.sendCallback = false;
        
        NSError* error;
        BOOL result = false;
        if (self.isBannerSize) {
            result = [sdk loadPlacementWithID:self.placementID withSize:VungleAdSizeBanner error:&error];
        } else {
            result = [sdk loadPlacementWithID:self.placementID error:&error];
        }
        if (!result && error) {
            NSLog(@"Banner6006: Error occurred when loading placement: %@", error);
        }
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (void)startAdWithOption:(NSDictionary *)option {
    [self startAd];
}

- (void)cancel {
}

-(void)loadCompleted {
    NSLog(@"%s vungle 6006 loadCompleted", __FUNCTION__);
    if (self.sendCallback) {
        NSLog(@"%s already sended callback", __FUNCTION__);
        return;
    }

    NSError *error;
    NSDictionary *options = @{};
    VungleSDK* sdk = [VungleSDK sharedSDK];
    [self destroyAdViewIfNeeded];
    CGRect viewSize = CGRectMake(0.0, 0.0, 300.0, 250.0);
    if (self.isBannerSize) {
        viewSize = CGRectMake(0.0, 0.0, 320.0, 50.0);
    }
    self.adView = [[UIView alloc] initWithFrame:viewSize];
    if ([sdk addAdViewToView:self.adView withOptions:options placementID:self.placementID error:&error]) {
        NSLog(@"%s vungle 6006 addAdViewToView complete", __FUNCTION__);
        self.isAdLoaded = true;

        NativeAdInfo6006 *info = [[NativeAdInfo6006 alloc] initWithVideoUrl:nil
                                                                      title:@""
                                                                description:@""
                                                               adnetworkKey:@"6006"];
        info.mediaType = ADFNativeAdType_Image;
        info.adapter = self;
        [info setupMediaView:self.adView];
        self.adInfo = info;

        [self setCustomMediaview:self.adView];

        self.sendCallback = true;
        if (self.delegate) {
            if ([self.delegate respondsToSelector: @selector(onNativeMovieAdLoadFinish:)]) {
                [self.delegate onNativeMovieAdLoadFinish:self.adInfo];
            } else {
                NSLog(@"Banner6006: %s onNativeMovieAdLoadFinish selector is not responding", __FUNCTION__);
            }
        } else {
            NSLog(@"Banner6006: %s Delegate is not setting", __FUNCTION__);
        }
    } else {
        if (error) {
            NSLog(@"%s vungle 6006 Error encountered while playing an ad: %@", __FUNCTION__, error);
            [self loadFailed];
            return;
        }
    }
}

-(void)loadFailed {
    if (self.sendCallback) {
        NSLog(@"%s already sended callback", __FUNCTION__);
        return;
    }

    self.sendCallback = true;

    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadError:)]) {
            [self.delegate onNativeMovieAdLoadError:self];
        } else {
            NSLog(@"Banner6006: selector onNativeMovieAdLoadError is not responding");
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

-(void)adClicked {
    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewClick)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewClick];
        } else {
            NSLog(@"Banner6006: %s onADFMediaViewClick selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"Banner6006: %s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

-(void)destroyAdViewIfNeeded {
    if (self.adView) {
        [self.adView removeFromSuperview];
        self.adView = nil;
    }
}

@end

@implementation NativeAdInfo6006

- (void)playMediaView {
    if (self.adapter) {
        if (self.mediaView.adapterInnerDelegate) {
            if ([self.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewRendering)]) {
                [self.mediaView.adapterInnerDelegate onADFMediaViewRendering];
            }
        }
        [self.adapter startViewabilityCheck];
    }
}

@end
