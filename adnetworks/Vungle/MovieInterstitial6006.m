//
//  MovieInterstitial6006.m(Vungle)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import "MovieInterstitial6006.h"
#import "AdnetworkParam6006.h"
#import <ADFMovieReward/ADFMovieOptions.h>

@interface MovieInterstitial6006()

@property (nonatomic, strong) VungleInterstitial *interstitialAd;
@property (nonatomic) AdnetworkParam6006 *param;

@end

@implementation MovieInterstitial6006

+ (NSString *)getSDKVersion {
    return [VungleAds sdkVersion];
}

+ (NSString *)getAdapterRevisionVersion {
    return @"1";
}

+ (NSString *)adnetworkClassName {
    return @"VungleAdsSDK.VungleInterstitial";
}

+ (NSString *)adnetworkName {
    return @"Vungle";
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MovieInterstitial6006 *newSelf = [super copyWithZone:zone];
    if (newSelf) {
        newSelf.param = self.param;
    }
    return newSelf;
}

/**
 *  データの設定
 */
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.param = [[AdnetworkParam6006 alloc] initWithParam:data];
}

- (void)initAdnetworkIfNeeded {
    if (![self.param isValid]) {
        return;
    }
    
    if ([VungleAds isInitialized]) {
        [self initCompleteAndRetryStartAdIfNeeded];
        return;
    }
    
    [VungleAds setDebugLoggingEnabled:[ADFMovieOptions getTestMode]];
    
    @try {
        [VungleAds initWithAppId:self.param.vungleAppID completion:^(NSError * _Nullable error){
            if (!error) {
                [self initCompleteAndRetryStartAdIfNeeded];
            }
        }];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

/**
 *  広告の読み込みを開始する
 */
- (void)startAd {
    if (![self canStartAd]) {
        return;
    }
    
    if (![self.param isValid]) {
        return;
    }
    
    [super startAd];
    
    @try {
        if (self.interstitialAd) {
            self.interstitialAd = nil;
        }
        [self requireToAsyncRequestAd];
        
        self.interstitialAd = [[VungleInterstitial alloc] initWithPlacementId:self.param.placementID];
        self.interstitialAd.delegate = self;
        [self.interstitialAd load:nil];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (BOOL)isPrepared {
    if (!self.delegate || !self.interstitialAd) {
        return NO;
    }
    return self.isAdLoaded && [self.interstitialAd canPlayAd];
}

/**
 *  広告の表示を行う
 */
- (void)showAd {
    UIViewController *topMostViewController = [self topMostViewController];
    [self showAdWithPresentingViewController:topMostViewController];
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    if (!self.interstitialAd || !self.param) {
        return;
    }
    
    [super showAdWithPresentingViewController:viewController];
    
    @try {
        [self requireToAsyncPlay];
        
        [self.interstitialAd presentWith:viewController];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

- (void)setHasUserConsent:(BOOL)hasUserConsent {
    [super setHasUserConsent:hasUserConsent];
    
    [VunglePrivacySettings setGDPRStatus:hasUserConsent];
    AdapterLogP(@"Adnetwork 6006, gdprConsent : %@, sdk setting value : %d", self.hasGdprConsent, (int)(hasUserConsent));
}

- (void)isChildDirected:(BOOL)childDirected {
    [super isChildDirected:childDirected];
    
    [VunglePrivacySettings setCOPPAStatus:childDirected];
    AdapterLogP(@"Adnetwork 6006, childDirected : %@, sdk setting value : %d", self.childDirected, (int)(childDirected));
}

#pragma mark - VungleInterstitial Delegate Methods
// Ad load events
- (void)interstitialAdDidLoad:(VungleInterstitial *)interstitial {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

- (void)interstitialAdDidFailToLoad:(VungleInterstitial *)interstitial
                          withError:(NSError *)withError {
    AdapterTraceP(@"error : %@", withError);
    [self setLastError:withError];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

// Ad Lifecycle Events
- (void)interstitialAdWillPresent:(VungleInterstitial *)interstitial {
    AdapterTrace;
}

- (void)interstitialAdDidPresent:(VungleInterstitial *)interstitial {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)interstitialAdDidFailToPresent:(VungleInterstitial *)interstitial
                             withError:(NSError *)withError {
    AdapterTraceP(@"error : %@", withError);
    [self setLastError:withError];
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}

- (void)interstitialAdDidTrackImpression:(VungleInterstitial *)interstitial {
    AdapterTrace;
}

- (void)interstitialAdDidClick:(VungleInterstitial *)interstitial {
    AdapterTrace;
}

- (void)interstitialAdWillLeaveApplication:(VungleInterstitial *)interstitial {
    AdapterTrace;
}

- (void)interstitialAdWillClose:(VungleInterstitial *)interstitial {
    AdapterTrace;
}

- (void)interstitialAdDidClose:(VungleInterstitial *)interstitial {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    [self setCallbackStatus:MovieRewardCallbackClose];
}

@end
