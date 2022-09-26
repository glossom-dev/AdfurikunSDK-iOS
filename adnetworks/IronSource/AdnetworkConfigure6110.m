//
//  AdnetworkConfigure6110.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2022/08/15.
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import "AdnetworkConfigure6110.h"
#import "Banner6110.h"

@interface AdnetworkConfigure6110 ()

@property (nonatomic) bool isInitialized;
@property (nonatomic) NSMutableDictionary <NSString *, ADFmyMovieRewardInterface*> *movieRewardAdapters;
@property (nonatomic) NSMutableDictionary <NSString *, ADFmyMovieRewardInterface*> *interstitialAdapters;
@property (nonatomic) NSMutableDictionary <NSString *, ADFmyMovieNativeInterface*> *bannerAdapters;

@end

@implementation AdnetworkConfigure6110

+ (instancetype)sharedInstance {
    static AdnetworkConfigure6110 *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AdnetworkConfigure6110 alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isInitialized = false;
        self.movieRewardAdapters = [NSMutableDictionary new];
        self.interstitialAdapters = [NSMutableDictionary new];
        self.bannerAdapters = [NSMutableDictionary new];
    }
    return self;
}

- (void)initIronSource:(NSString *)appKey completion:(completionHandlerType)completionHandler {
    if (self.isInitialized) {
        completionHandler();
        return;
    }
    
    @try {
        [IronSource setISDemandOnlyRewardedVideoDelegate:self];
        [IronSource setISDemandOnlyInterstitialDelegate:self];
        [IronSource setBannerDelegate:self];
        
        [IronSource initISDemandOnly:appKey adUnits:@[IS_REWARDED_VIDEO, IS_INTERSTITIAL, IS_BANNER]];
        
        NSString *mediationString = [NSString stringWithFormat:@"Adfurikun%@SDK%@", [Banner6110 getAdapterRevisionVersion], [ADFMovieOptions version]];
        AdapterLogP(@"mediation string : %@", mediationString);
        [IronSource setMediationType:mediationString];
        
        self.isInitialized = true;
        completionHandler();
        
    } @catch (NSException *exception) {
        AdapterLogP(@"[ADF] adnetwork exception : %@", exception);
    }
}

- (void)setMovieRewardAdapter:(ADFmyMovieRewardInterface *)adapter instanceId:(NSString *)instanceId {
    [self.movieRewardAdapters setObject:adapter forKey:instanceId];
}

- (void)removeMovieRewardAdapterWithInstanceId:(NSString *)instanceId {
    [self.movieRewardAdapters removeObjectForKey:instanceId];
}

- (void)setInterstitialAdapter:(ADFmyMovieRewardInterface *)adapter instanceId:(NSString *)instanceId {
    [self.interstitialAdapters setObject:adapter forKey:instanceId];
}

- (void)removeInterstitialAdapterWithInstanceId:(NSString *)instanceId {
    [self.interstitialAdapters removeObjectForKey:instanceId];
}

- (void)setBannerAdapter:(ADFmyMovieNativeInterface *)adapter instanceId:(NSString *)instanceId {
    [self.bannerAdapters setObject:adapter forKey:instanceId];
}

- (void)removeBannerAdapterWithInstanceId:(NSString *)instanceId {
    [self.bannerAdapters removeObjectForKey:instanceId];
}


#pragma mark - ISDemandOnlyRewardedVideoDelegate
//Called after a rewarded video has been requested and load succeed.
- (void)rewardedVideoDidLoad:(NSString *)instanceId {
    AdapterTraceP(@"instance id : %@", instanceId);
    ADFmyMovieRewardInterface *adapter = [self.movieRewardAdapters objectForKey:instanceId];
    if (adapter) {
        adapter.isAdLoaded = true;
        [adapter setCallbackStatus:MovieRewardCallbackFetchComplete];
    }
}

//Called after a rewarded video has attempted to load but failed.
//@param error The reason for the error
- (void)rewardedVideoDidFailToLoadWithError:(NSError *)error instanceId:(NSString* )instanceId {
    AdapterTraceP(@"instance id : %@, error : %@", instanceId, error);
    ADFmyMovieRewardInterface *adapter = [self.movieRewardAdapters objectForKey:instanceId];
    if (adapter) {
        [adapter setLastError:error];
        [adapter setCallbackStatus:MovieRewardCallbackFetchFail];
    }
}

//Called after a rewarded video has attempted to show but failed.
//@param error The reason for the error
- (void)rewardedVideoDidFailToShowWithError:(NSError *)error instanceId:(NSString *)instanceId {
    AdapterTraceP(@"instance id : %@, error : %@", instanceId, error);
    ADFmyMovieRewardInterface *adapter = [self.movieRewardAdapters objectForKey:instanceId];
    if (adapter) {
        [adapter setLastError:error];
        [adapter setCallbackStatus:MovieRewardCallbackPlayFail];
        adapter.isAdLoaded = false;
    }
}

//Called after a rewarded video has been opened.
- (void)rewardedVideoDidOpen:(NSString *)instanceId {
    AdapterTraceP(@"instance id : %@", instanceId);
    ADFmyMovieRewardInterface *adapter = [self.movieRewardAdapters objectForKey:instanceId];
    if (adapter) {
        [adapter setCallbackStatus:MovieRewardCallbackPlayStart];
    }
}

//Called after a rewarded video has been viewed completely and the user is //eligible for reward.
- (void)rewardedVideoAdRewarded:(NSString *)instanceId {
    AdapterTraceP(@"instance id : %@", instanceId);
    ADFmyMovieRewardInterface *adapter = [self.movieRewardAdapters objectForKey:instanceId];
    if (adapter) {
        [adapter setCallbackStatus:MovieRewardCallbackPlayComplete];
    }
}

//Called after a rewarded video has been dismissed.
- (void)rewardedVideoDidClose:(NSString *)instanceId {
    AdapterTraceP(@"instance id : %@", instanceId);
    ADFmyMovieRewardInterface *adapter = [self.movieRewardAdapters objectForKey:instanceId];
    if (adapter) {
        [adapter setCallbackStatus:MovieRewardCallbackClose];
        adapter.isAdLoaded = false;
    }
}

//Invoked when the end user clicked on the RewardedVideo ad
- (void)rewardedVideoDidClick:(NSString *)instanceId {
    AdapterTraceP(@"instance id : %@", instanceId);
}

#pragma mark - ISDemandOnlyInterstitialDelegate
/**
 Called after an interstitial has been loaded
 */
- (void)interstitialDidLoad:(NSString *)instanceId {
    AdapterTraceP(@"instance id : %@", instanceId);
    ADFmyMovieRewardInterface *adapter = [self.interstitialAdapters objectForKey:instanceId];
    if (adapter) {
        adapter.isAdLoaded = true;
        [adapter setCallbackStatus:MovieRewardCallbackFetchComplete];
    }
}

/**
 Called after an interstitial has attempted to load but failed.

 @param error The reason for the error
 */
- (void)interstitialDidFailToLoadWithError:(NSError *)error instanceId:(NSString *)instanceId {
    AdapterTraceP(@"instance id : %@, error : %@", instanceId, error);
    ADFmyMovieRewardInterface *adapter = [self.interstitialAdapters objectForKey:instanceId];
    if (adapter) {
        if (error) {
            [adapter setErrorWithMessage:error.localizedDescription code:error.code];
        }
        [adapter setCallbackStatus:MovieRewardCallbackPlayFail];
        adapter.isAdLoaded = false;
    }
}

/**
 Called after an interstitial has been opened.
 */
- (void)interstitialDidOpen:(NSString *)instanceId {
    AdapterTraceP(@"instance id : %@", instanceId);
    ADFmyMovieRewardInterface *adapter = [self.interstitialAdapters objectForKey:instanceId];
    if (adapter) {
        [adapter setCallbackStatus:MovieRewardCallbackPlayStart];
    }
}

/**
  Called after an interstitial has been dismissed.
 */
- (void)interstitialDidClose:(NSString *)instanceId {
    AdapterTraceP(@"instance id : %@", instanceId);
    ADFmyMovieRewardInterface *adapter = [self.interstitialAdapters objectForKey:instanceId];
    if (adapter) {
        [adapter setCallbackStatus:MovieRewardCallbackPlayComplete];
        [adapter setCallbackStatus:MovieRewardCallbackClose];
        adapter.isAdLoaded = false;
    }
}

/**
 Called after an interstitial has attempted to show but failed.

 @param error The reason for the error
 */
- (void)interstitialDidFailToShowWithError:(NSError *)error instanceId:(NSString *)instanceId {
    AdapterTraceP(@"instance id : %@, error : %@", instanceId, error);
    ADFmyMovieRewardInterface *adapter = [self.interstitialAdapters objectForKey:instanceId];
    if (adapter) {
        if (error) {
            [adapter setErrorWithMessage:error.localizedDescription code:error.code];
        }
        [adapter setCallbackStatus:MovieRewardCallbackPlayFail];
        adapter.isAdLoaded = false;
    }
}

/**
 Called after an interstitial has been clicked.
 */
- (void)didClickInterstitial:(NSString *)instanceId {
    AdapterTraceP(@"instance id : %@", instanceId);
}

#pragma mark - ISBannerDelegate
- (void)bannerDidLoad:(ISBannerView *)bannerView {
    AdapterTrace;

    ADFmyMovieNativeInterface *adapter = [self.bannerAdapters objectForKey:kAdnetwork6110DefaultInstanceId];
    if (adapter) {
        NativeAdInfo6110 *info = [[NativeAdInfo6110 alloc] initWithVideoUrl:nil
                                                                      title:@""
                                                                description:@""
                                                               adnetworkKey:@"6110" ];
        info.mediaType = ADFNativeAdType_Image;
        [info setupMediaView:bannerView];
        [adapter setCustomMediaview:bannerView];
        ((Banner6110 *)adapter).bannerView = bannerView;
        
        info.adapter = adapter;
        info.isCustomComponentSupported = false;
        
        adapter.adInfo = info;
        adapter.isAdLoaded = true;
        
        [adapter setCallbackStatus:NativeAdCallbackLoadFinish];
    }
}

/**
 Called after a banner has attempted to load an ad but failed.
 
 @param error The reason for the error
 */
- (void)bannerDidFailToLoadWithError:(NSError *)error {
    AdapterTrace;
    ADFmyMovieNativeInterface *adapter = [self.bannerAdapters objectForKey:kAdnetwork6110DefaultInstanceId];
    if (adapter) {
        if (error) {
            [adapter setErrorWithMessage:error.localizedDescription code:error.code];
        }
        [adapter setCallbackStatus:NativeAdCallbackLoadError];
    }
}
    
/**
 Called after a banner has been clicked.
 */
- (void)didClickBanner {
    AdapterTrace;
}
/**
 Called when a banner is about to present a full screen content.
 */
- (void)bannerWillPresentScreen {
    AdapterTrace;
    ADFmyMovieNativeInterface *adapter = [self.bannerAdapters objectForKey:kAdnetwork6110DefaultInstanceId];
    if (adapter) {
        [adapter setCallbackStatus:NativeAdCallbackClick];
    }
}
/**
 Called after a full screen content has been dismissed.
 */
- (void)bannerDidDismissScreen {
    AdapterTrace;
}
/**
 Called when a user would be taken out of the application context.
 */
- (void)bannerWillLeaveApplication {
    AdapterTrace;
}

@end
