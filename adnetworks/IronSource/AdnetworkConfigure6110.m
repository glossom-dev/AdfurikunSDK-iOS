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

@property (nonatomic) NSMutableArray <completionHandlerType> *handlers;
@property (nonatomic) bool isInitialized;
@property (nonatomic, nullable) ISBannerView *bannerView;

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
        self.handlers = [NSMutableArray new];
        self.isInitialized = false;
    }
    return self;
}

- (void)initIronSource:(NSString *)appKey completion:(completionHandlerType)completionHandler {
    if (self.isInitialized) {
        completionHandler();
        return;
    }
    
    [self.handlers addObject:completionHandler];
    
    @try {
        [IronSource setRewardedVideoManualDelegate:self];
        [IronSource setInterstitialDelegate:self];
        [IronSource setBannerDelegate:self];
        
        [IronSource initWithAppKey:appKey delegate:self];
    } @catch (NSException *exception) {
        AdapterLogP(@"[ADF] adnetwork exception : %@", exception);
    }
}

- (void)destroyBannerView {
    if (self.bannerView) {
        [IronSource destroyBanner:self.bannerView];
        self.bannerView = nil;
    }
}

#pragma mark -ISInitializationDelegate

- (void)initializationDidComplete {
    AdapterTrace;
    self.isInitialized = true;
    
    for (completionHandlerType handler in self.handlers) {
        handler();
    }
}


#pragma mark - RewardedVideoManualListener
/**
 Called after an rewarded video has been loaded in manual mode
 */
- (void)rewardedVideoDidLoad {
    AdapterTrace;
    if (self.movieRewardAdapter) {
        self.movieRewardAdapter.isAdLoaded = true;
        [self.movieRewardAdapter setCallbackStatus:MovieRewardCallbackFetchComplete];
    }
}

/**
 Called after a rewarded video has attempted to load but failed in manual mode
 
 @param error The reason for the error
 */
- (void)rewardedVideoDidFailToLoadWithError:(NSError *)error {
    AdapterTraceP(@"error : %@", error);
    if (self.movieRewardAdapter) {
        [self.movieRewardAdapter setLastError:error];
        [self.movieRewardAdapter setCallbackStatus:MovieRewardCallbackFetchFail];
    }
}

//Called after a rewarded video has changed its availability.
//@param available The new rewarded video availability. YES if available //and ready to be shown, NO otherwise.
- (void) rewardedVideoHasChangedAvailability:(BOOL)available {
    AdapterTraceP(@"available : %d", available);
}

// Invoked when the user completed the video and should be rewarded.
// If using server-to-server callbacks you may ignore this events and wait *for the callback from the ironSource server.
// @param placementInfo An object that contains the placement's reward name and amount.
- (void)didReceiveRewardForPlacement:(ISPlacementInfo *)placementInfo {
    AdapterTraceP(@"placementInfo : %@", placementInfo);
    if (self.movieRewardAdapter) {
        [self.movieRewardAdapter setCallbackStatus:MovieRewardCallbackPlayComplete];
    }
}

//Called after a rewarded video has attempted to show but failed.
//@param error The reason for the error
- (void)rewardedVideoDidFailToShowWithError:(NSError *)error {
    AdapterTraceP(@"error : %@", error);
    if (self.movieRewardAdapter) {
        [self.movieRewardAdapter setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

//Called after a rewarded video has been opened.
- (void)rewardedVideoDidOpen {
    AdapterTrace;
    if (self.movieRewardAdapter) {
        [self.movieRewardAdapter setCallbackStatus:MovieRewardCallbackPlayStart];
    }
}

//Called after a rewarded video has been dismissed.
- (void)rewardedVideoDidClose {
    AdapterTrace;
    if (self.movieRewardAdapter) {
        [self.movieRewardAdapter setCallbackStatus:MovieRewardCallbackClose];
        self.movieRewardAdapter.isAdLoaded = false;
    }
}

//Invoked when the end user clicked on the RewardedVideo ad
- (void)didClickRewardedVideo:(ISPlacementInfo *)placementInfo{
    AdapterTrace;
}

// -------------------------------------------------------
// Optional events - Are not available for all networks
// -------------------------------------------------------

//Called after a rewarded video has started playing.
- (void)rewardedVideoDidStart {
    AdapterTrace;
}

//Called after a rewarded video has finished playing.
- (void)rewardedVideoDidEnd {
    AdapterTrace;
}

#pragma mark - ISInterstitialDelegate
// Invoked when Interstitial Ad is ready to be shown after load function was //called.
-(void)interstitialDidLoad {
    AdapterTrace;
    if (self.interstitialAdapter) {
        self.interstitialAdapter.isAdLoaded = true;
        [self.interstitialAdapter setCallbackStatus:MovieRewardCallbackFetchComplete];
    }
}
// Called if showing the Interstitial for the user has failed.
// You can learn about the reason by examining the ‘error’ value
-(void)interstitialDidFailToShowWithError:(NSError *)error {
    AdapterTraceP(@"error : %@", error);
    if (self.interstitialAdapter) {
        [self.interstitialAdapter setLastError:error];
        [self.interstitialAdapter setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}
// Called each time the end user has clicked on the Interstitial ad, for supported networks only
-(void)didClickInterstitial {
    AdapterTrace;
}
// Called each time the Interstitial window is about to close
-(void)interstitialDidClose {
    AdapterTrace;
    if (self.interstitialAdapter) {
        [self.interstitialAdapter setCallbackStatus:MovieRewardCallbackPlayComplete];
        [self.interstitialAdapter setCallbackStatus:MovieRewardCallbackClose];
        self.interstitialAdapter.isAdLoaded = false;
    }
}
// Called each time the Interstitial window is about to open
-(void)interstitialDidOpen {
    AdapterTrace;
    if (self.interstitialAdapter) {
        [self.interstitialAdapter setCallbackStatus:MovieRewardCallbackPlayStart];
    }
}
// Invoked when there is no Interstitial Ad available after calling load function.
// @param error - will contain the failure code and description.
-(void)interstitialDidFailToLoadWithError:(NSError *)error {
    AdapterTraceP(@"error : %@", error);
    if (self.interstitialAdapter) {
        [self.interstitialAdapter setLastError:error];
        [self.interstitialAdapter setCallbackStatus:MovieRewardCallbackFetchFail];
    }
}

// Invoked right before the Interstitial screen is about to open.
// NOTE - This event is available only for some of the networks.
// You should NOT treat this event as an interstitial impression, but rather use InterstitialAdOpenedEvent
-(void)interstitialDidShow {
    AdapterTrace;
}

#pragma mark - ISBannerDelegate
- (void)bannerDidLoad:(ISBannerView *)bannerView {
    AdapterTrace;

    if (self.bannerAdapter) {
        /** Called after a banner ad has been successfully loaded
         */
        NativeAdInfo6110 *info = [[NativeAdInfo6110 alloc] initWithVideoUrl:nil
                                                                      title:@""
                                                                description:@""
                                                               adnetworkKey:@"6110" ];
        info.mediaType = ADFNativeAdType_Image;
        [info setupMediaView:bannerView];
        [self.bannerAdapter setCustomMediaview:bannerView];
        self.bannerView = bannerView;
        
        info.adapter = self.bannerAdapter;
        info.isCustomComponentSupported = false;
        
        self.bannerAdapter.adInfo = info;
        self.bannerAdapter.isAdLoaded = true;
        
        [self.bannerAdapter setCallbackStatus:NativeAdCallbackLoadFinish];
    }
}
/**
 Called after a banner has attempted to load an ad but failed.
 
 @param error The reason for the error
 */
- (void)bannerDidFailToLoadWithError:(NSError *)error {
    AdapterTrace;
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
