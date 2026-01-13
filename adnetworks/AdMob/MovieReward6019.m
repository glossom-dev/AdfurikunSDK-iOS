//
//  MovieReward6019.m
//  MovieRewardTestApp
//
//  Created by Ren Fujii on 2019/11/13.
//  Copyright © 2019 Glossom, Inc. All rights reserved.
//

#import "MovieReward6019.h"
#import "AdnetworkConfigure6019.h"
#import "AdnetworkParam6019.h"

#import <GoogleMobileAds/GoogleMobileAds.h>

@interface MovieReward6019 ()<GADFullScreenContentDelegate>

@property (nonatomic) GADRewardedAd *rewardedAd;

@end

@implementation MovieReward6019

+ (NSString *)getAdapterRevisionVersion {
    return @"18";
}

+ (NSString *)adnetworkClassName {
    return @"GADRewardedAd";
}

+ (NSString *)adnetworkName {
    return [AdnetworkConfigure6019 adnetworkName];
}

-(id)init {
    self = [super init];
    if (self) {
        self.configure = [AdnetworkConfigure6019 sharedInstance];
    }
    return self;
}

- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6019 alloc] initWithParam:data];
    self.configure.param = self.adParam;
}

- (bool)initAdnetworkIfNeeded {
    if (![super initAdnetworkIfNeeded]) {
        return false;
    }

    __weak typeof(self) weakSelf = self;
    [self.configure initAdnetworkSDKWithCompletionHander:^(_Bool result) {
        __strong typeof(self) strongSelf = weakSelf;
        if (!strongSelf) return;
        [self initCompleteAndRetryStartAdIfNeeded];
    }];
    [self.configure soundControl];
    return true;
}

- (bool)startAd {
    if (![super startAd]) {
        return false;
    }
    
    if ([self isPrepared]) {
        [self adRequestSccess:self.rewardedAd];
        return true;
    }
    
    @try {
        GADRequest *request = [GADRequest request];
        [(AdnetworkConfigure6019 *)self.configure setHasGdprConsent:self.hasGdprConsent request:request];

        [self requireToAsyncRequestAd];
        [GADRewardedAd loadWithAdUnitID:((AdnetworkParam6019 *)(self.adParam)).unitID
                                request:request
                      completionHandler:^(GADRewardedAd * _Nullable rewardedAd, NSError * _Nullable error) {
            if (error) {
                [self adRequestFailure:error];
            } else {
                [self adRequestSccess:rewardedAd];
            }
        }];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
    return true;
}

- (BOOL)isPrepared {
    return self.isAdLoaded;
}

- (void)showAd {
    [self showAdWithPresentingViewController:[self topMostViewController]];
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAdWithPresentingViewController:viewController];

    if (!self.rewardedAd) {
        [self setPlayFailCallback:PlayFailCallbackReasonAdInstanceNil exception:nil];
        return;
    }

    if ([self isPrepared]) {
        @try {
            [self requireToAsyncPlay];
            __weak typeof(self) weakSelf = self;
            [self.rewardedAd presentFromRootViewController:[self topMostViewController]
                                  userDidEarnRewardHandler:^{
                __strong typeof(self) strongSelf = weakSelf;
                if (!strongSelf) return;
                strongSelf.isRewarded = true;
                [strongSelf setCallbackStatus:MovieRewardCallbackPlayComplete];
            }];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setPlayFailCallback:PlayFailCallbackReasonException exception:exception];
        }
    } else {
        [self setPlayFailCallback:PlayFailCallbackReasonIsPreparedFalse exception:nil];
    }
}

- (void)adRequestSccess:(GADRewardedAd * _Nullable)rewardedAd {
    AdapterTrace;
    if ([self isNotNull:rewardedAd]) {
        self.rewardedAd = rewardedAd;
        self.rewardedAd.fullScreenContentDelegate = self;
        [self setCallbackStatus:MovieRewardCallbackFetchComplete];
    } else {
        NSString *message = @"rewardedAd is null";
        NSError *error = [NSError errorWithDomain:@"jp.glossom.adfurikun.error"
                                             code:0
                                         userInfo:@{NSLocalizedDescriptionKey: message,
                                                    NSLocalizedRecoverySuggestionErrorKey: message}];
        [self adRequestFailure:error];
    }
}

- (void)adRequestFailure:(NSError *)error {
    AdapterTraceP(@"error: %@", error);
    [self setError:error];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

#pragma mark - GADFullScreenContentDelegate

- (void)adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>)ad {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    AdapterTrace;
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}

- (void)adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    AdapterTrace;
}

- (void)adWillDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
    AdapterTrace;
}

- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackClose];
}

@end

@implementation MovieReward6060

+ (NSString *)adnetworkName {
    return @"Google Ad Manager";
}

@end

@implementation MovieReward6220
@end
