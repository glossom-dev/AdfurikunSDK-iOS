//
//  AdfurikunAdMobReward.m
//
//  Copyright © 2019 Glossom.Inc. All rights reserved.
//

#import "AdfurikunAdMobReward.h"
#import <ADFMovieReward/ADFMovieOptions.h>

@interface AdfurikunAdMobReward () <GADMediationRewardedAd, ADFmyMovieRewardDelegate>
@property(nonatomic, weak, nullable) id<GADMediationRewardedAdEventDelegate> delegate;
@property(nonatomic) GADMediationRewardedLoadCompletionHandler closure;
@end

@implementation AdfurikunAdMobReward

+ (GADVersionNumber)adSDKVersion {
    NSString *versionString = ADFMovieOptions.version;
    NSMutableArray *versionComponents = [[versionString componentsSeparatedByString:@"."] mutableCopy];
    GADVersionNumber version = {0};
    if (versionComponents.count == 3) {
        [versionComponents addObject:@"0"];
    }
    if (versionComponents.count == 4) {
        version.majorVersion = [versionComponents[0] integerValue];
        version.minorVersion = [versionComponents[1] integerValue];
        
        // Adapter versions have 2 patch versions. Multiply the first patch by 100.
        version.patchVersion = [versionComponents[2] integerValue] * 100
        + [versionComponents[3] integerValue];
    }
    return version;
}

+ (GADVersionNumber)adapterVersion {
    NSString *versionString = @"1.0.0";
    NSArray *versionComponents = [versionString componentsSeparatedByString:@"."];
    GADVersionNumber version = {0};
    if (versionComponents.count == 3) {
        version.majorVersion = [versionComponents[0] integerValue];
        version.minorVersion = [versionComponents[1] integerValue];
        version.patchVersion = [versionComponents[2] integerValue];
    }
    return version;
}

- (void)loadRewardedAdForAdConfiguration:(GADMediationRewardedAdConfiguration *)adConfiguration completionHandler:(GADMediationRewardedLoadCompletionHandler)completionHandler {
    self.closure = completionHandler;
    NSString *adUnit = adConfiguration.credentials.settings[@"parameter"];
    self.movieReward = [ADFmyMovieReward getInstance:adUnit delegate:self];
    [self.movieReward load];
}

+ (Class<GADAdNetworkExtras>)networkExtrasClass {
    return nil;
}

- (void)presentFromViewController:(nonnull UIViewController *)viewController {
    if ([self.movieReward isPrepared]) {
        [self.movieReward play];
    }
}

- (void)AdsFetchCompleted:(NSString *)appID isTestMode:(BOOL)isTestMode_inApp {
    self.delegate = self.closure(self, nil);
}

- (void)AdsFetchFailed:(NSString *)appID error:(NSError *)error {
    self.closure(nil, error);
}

- (void)AdsDidShow:(NSString *)appID adNetworkKey:(NSString *)adNetworkKey {
    NSLog(@"%s", __FUNCTION__);
    [self.delegate willPresentFullScreenView];
    [self.delegate reportImpression];
    [self.delegate didStartVideo];
}

- (void)AdsDidCompleteShow:(NSString *)appID {
    NSLog(@"%s", __FUNCTION__);
    [self.delegate didEndVideo];
}

- (void)AdsDidHide:(NSString *)appID {
    NSLog(@"%s", __FUNCTION__);
    [self.delegate willDismissFullScreenView];
    [self.delegate didDismissFullScreenView];
}

@end
