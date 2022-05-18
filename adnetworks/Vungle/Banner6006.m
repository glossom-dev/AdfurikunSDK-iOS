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

+ (NSString *)getAdapterRevisionVersion {
    return @"5";
}

- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"VungleSDK");
    if (clazz) {
        AdapterLog(@"Found Class: Vungle");
    }
    else {
        AdapterLog(@"Not found Class: Vungle");
        return NO;
    }
    return YES;
}

-(void)setHasUserConsent:(BOOL)hasUserConsent {
    [super setHasUserConsent:hasUserConsent];
    VungleSDK* sdk = [VungleSDK sharedSDK];
    [sdk updateConsentStatus:hasUserConsent ? VungleConsentAccepted : VungleConsentDenied consentMessageVersion:@"1.0.0"];
    AdapterLogP(@"Adnetwork 6006, gdprConsent : %@, sdk setting value : %d", self.hasGdprConsent, (int)(hasUserConsent ? VungleConsentAccepted : VungleConsentDenied));
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
        AdapterLog(@"Vungle data is invalid");
        return;
    }
    if (self.allPlacementIDs.count == 0) {
        self.allPlacementIDs = @[self.placementID];
    }
}

- (void)initVungle {
    @try {
        if ([VungleSDK sharedSDK].isInitialized) {
            return;
        }
        NSError *error;
        if (![[VungleSDK sharedSDK] startWithAppId:self.vungleAppID error:&error]) {
            AdapterLogP(@"Error while starting VungleSDK %@", [error localizedDescription]);
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
        [[VungleSDK sharedSDK] setMuted:false];
    } else if (ADFMovieOptions_Sound_Off == soundState) {
        [[VungleSDK sharedSDK] setMuted:true];
    }

    self.isBannerSize = true;
    [self initCompleteAndRetryStartAdIfNeeded];
}

- (void)clearStatusIfNeeded {

}

- (BOOL)isPrepared {
    if (!self.delegate || !self.placementID) {
        return NO;
    }
    return self.isAdLoaded;
}

// SDKのLoading関数を呼び出す
- (void)startAd {
    if (![self canStartAd]) {
        return;
    }

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
        
        [self requireToAsyncRequestAd];
        
        if (self.isBannerSize) {
            result = [sdk loadPlacementWithID:self.placementID withSize:VungleAdSizeBanner error:&error];
        } else {
            result = [sdk loadPlacementWithID:self.placementID error:&error];
        }
        if (!result && error) {
            AdapterLogP(@"Banner6006: Error occurred when loading placement: %@", error);
        }
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (void)startAdWithOption:(NSDictionary *)option {
    [self startAd];
}

-(void)loadCompleted {
    AdapterLog(@"vungle 6006 loadCompleted");
    if (self.sendCallback) {
        AdapterLog(@"already sended callback");
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
        AdapterLog(@"vungle 6006 addAdViewToView complete");
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
        
        [self setCallbackStatus:NativeAdCallbackLoadFinish];
    } else {
        if (error) {
            AdapterLogP(@"vungle 6006 Error encountered while playing an ad: %@", error);
            [self loadFailed];
            return;
        }
    }
}

-(void)loadFailed {
    if (self.sendCallback) {
        AdapterLog(@"already sended callback");
        return;
    }

    self.sendCallback = true;

    [self setCallbackStatus:NativeAdCallbackLoadError];
}

-(void)adClicked {
    [self setCallbackStatus:NativeAdCallbackClick];
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
        [self.adapter setCallbackStatus:NativeAdCallbackRendering];
        [self.adapter startViewabilityCheck];
    }
}

@end
