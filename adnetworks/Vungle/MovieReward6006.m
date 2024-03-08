//
//  MovieReward6006.m(Vungle)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//
#import <UIKit/UIKit.h>
#import "MovieReward6006.h"
#import "AdnetworkParam6006.h"
#import <ADFMovieReward/ADFMovieOptions.h>

@interface MovieReward6006()

@property (nonatomic, strong) VungleRewarded *rewardedAd;
@property (nonatomic) AdnetworkParam6006 *param;

@end

@implementation MovieReward6006

+ (NSString *)getSDKVersion {
    return [VungleAds sdkVersion];
}

+ (NSString *)getAdapterRevisionVersion {
    return @"9";
}

+ (NSString *)adnetworkClassName {
    return @"VungleAdsSDK.VungleRewarded";
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
    MovieReward6006 *newSelf = [super copyWithZone:zone];
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
        if (self.rewardedAd) {
            self.rewardedAd = nil;
        }
        [self requireToAsyncRequestAd];
        
        self.rewardedAd = [[VungleRewarded alloc] initWithPlacementId:self.param.placementID];
        self.rewardedAd.delegate = self;
        [self.rewardedAd load:nil];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (BOOL)isPrepared {
    if (!self.delegate || !self.rewardedAd) {
        return NO;
    }
    return self.isAdLoaded && [self.rewardedAd canPlayAd];
}

/**
 *  広告の表示を行う
 */
- (void)showAd {
    UIViewController *topMostViewController = [self topMostViewController];
    [self showAdWithPresentingViewController:topMostViewController];
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    if (!self.rewardedAd || !self.param) {
        return;
    }
    
    [super showAdWithPresentingViewController:viewController];
    
    @try {
        [self requireToAsyncPlay];
        
        [self.rewardedAd presentWith:viewController];
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

#pragma mark - VungleRewarded Delegate Methods
// Ad load events
- (void)rewardedAdDidLoad:(VungleRewarded *)rewarded {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

- (void)rewardedAdDidFailToLoad:(VungleRewarded *)rewarded withError:(NSError *)withError {
    AdapterTraceP(@"error : %@", withError);
    [self setLastError:withError];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

- (void)rewardedAdWillPresent:(VungleRewarded *)rewarded {
    AdapterTrace;
}

- (void)rewardedAdDidPresent:(VungleRewarded *)rewarded {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)rewardedAdDidFailToPresent:(VungleRewarded *)rewarded withError:(NSError *)withError {
    AdapterTraceP(@"error : %@", withError);
    [self setLastError:withError];
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}

- (void)rewardedAdDidTrackImpression:(VungleRewarded *)rewarded {
    AdapterTrace;
}

- (void)rewardedAdDidClick:(VungleRewarded *)rewarded {
    AdapterTrace;
}

- (void)rewardedAdWillLeaveApplication:(VungleRewarded *)rewarded {
    AdapterTrace;
}

- (void)rewardedAdDidRewardUser:(VungleRewarded *)rewarded {
    AdapterTrace;
}

- (void)rewardedAdWillClose:(VungleRewarded *)rewarded {
    AdapterTrace;
}

- (void)rewardedAdDidClose:(VungleRewarded *)rewarded {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    [self setCallbackStatus:MovieRewardCallbackClose];
}

@end
