//
//  AdfurikunMaxReward.m
//
//  Copyright © 2023 Glossom.Inc. All rights reserved.
//

#import "AdfurikunMaxReward.h"

#define ADAPTER_VERSION @"1.0.0"

@interface AdfurikunMaxReward ()

@property(nonatomic) ADFmyMovieReward *movieReward;
@property(nonatomic, weak) id<MARewardedAdapterDelegate> maxDelegate;

@end

@implementation AdfurikunMaxReward

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void (^)(MAAdapterInitializationStatus, NSString * _Nullable))completionHandler {
    NSLog(@"%s", __FUNCTION__);
    completionHandler(MAAdapterInitializationStatusInitializedSuccess, nil);
}

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters withCompletionHandler:(void (^)(void))completionHandler {
    NSLog(@"%s", __FUNCTION__);
    completionHandler();
}

- (NSString *)SDKVersion {
    return [ADFMovieOptions version];
}

- (NSString *)adapterVersion {
    return ADAPTER_VERSION;
}

- (void)destroy {
    self.movieReward.delegate = nil;
    self.movieReward = nil;
}

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate {
    NSString *appId = parameters.thirdPartyAdPlacementIdentifier;
    NSLog(@"%s , appId: %@", __FUNCTION__, appId);
    self.maxDelegate = delegate;
    if (self.movieReward == nil || [[NSNull null] isEqual:self.movieReward]) {
        self.movieReward = [ADFmyMovieReward getInstance:appId delegate:self];
    }
    [self.movieReward load];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate {
    if ([self.movieReward isPrepared]) {
        NSLog(@"%s", __FUNCTION__);
        if (parameters.localExtraParameters && parameters.localExtraParameters.count > 0) {
            [self.movieReward playWithCustomParam:parameters.localExtraParameters];
        } else {
            [self.movieReward play];
        }
    } else {
        NSLog(@"%s , error: adNotReady", __FUNCTION__);
        [self.maxDelegate didFailToDisplayRewardedAdWithError: MAAdapterError.adNotReady];
    }
}

- (void)AdsFetchCompleted:(NSString *)appID isTestMode:(BOOL)isTestMode_inApp {
    NSLog(@"%s", __FUNCTION__);
    [self.maxDelegate didLoadRewardedAd];
}

- (void)AdsFetchFailed:(NSString *)appID error:(NSError *)error adnetworkError:(NSArray<AdnetworkError *> *)adnetworkError {
    NSLog(@"%s , error: %@", __FUNCTION__, error.localizedDescription);
    [self.maxDelegate didFailToLoadRewardedAdWithError:MAAdapterError.noFill];
}

- (void)AdsDidShow:(NSString *)appID adnetworkKey:(NSString *)adnetworkKey {
    NSLog(@"%s", __FUNCTION__);
    [self.maxDelegate didDisplayRewardedAd];
    [self.maxDelegate didStartRewardedAdVideo];
}

- (void)AdsDidCompleteShow:(NSString *)appID {
    NSLog(@"%s", __FUNCTION__);
    [self.maxDelegate didCompleteRewardedAdVideo];
}

- (void)AdsDidHide:(NSString *)appID {
    NSLog(@"%s", __FUNCTION__);
    [self.maxDelegate didRewardUserWithReward:self.reward];
    [self.maxDelegate didHideRewardedAd];
}

- (void)AdsPlayFailed:(NSString *)appID adnetworkError:(AdnetworkError *)adnetworkError {
    NSLog(@"%s", __FUNCTION__);
    [self.maxDelegate didFailToDisplayRewardedAdWithError:MAAdapterError.internalError];
}

@end

