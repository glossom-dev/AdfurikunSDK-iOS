//
//  MovieReward6019.m
//  MovieRewardTestApp
//
//  Created by Ren Fujii on 2019/11/13.
//  Copyright © 2019 Glossom, Inc. All rights reserved.
//

#import "MovieReward6019.h"
#import <ADFMovieReward/ADFMovieOptions.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface MovieReward6019 ()<GADFullScreenContentDelegate>
@property(nonatomic) GADRewardedAd *rewardedAd;
@property(nonatomic) NSString *unitID;
@property(nonatomic) BOOL testFlg;
@property(nonatomic) BOOL isAdsCompleteShow;
@end

@implementation MovieReward6019

+ (NSString *)getAdapterRevisionVersion {
    return @"6";
}

-(id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    NSString* admobId = [data objectForKey:@"ad_unit_id"];
    if ([self isNotNull:admobId]) {
        self.unitID = [[NSString alloc] initWithFormat:@"%@", admobId];
    }
    NSNumber *testFlg = [data objectForKey:@"test_flg"];
    if ([self isNotNull:testFlg] && [testFlg isKindOfClass:[NSNumber class]]) {
        self.testFlg = [testFlg boolValue];
    }

    self.isAdsCompleteShow = NO;
}

- (void)initAdnetworkIfNeeded {
    if (self.testFlg) {
        //GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[@"コンソールに出力されたデバイスIDを入力してください。"]; //詳細　https://developers.google.com/admob/ios/test-ads?hl=ja
    }
    ADFMovieOptions_Sound soundState = [ADFMovieOptions getSoundState];
    if (ADFMovieOptions_Sound_On == soundState) {
        GADMobileAds.sharedInstance.applicationMuted = NO;
    } else if (ADFMovieOptions_Sound_Off == soundState) {
        GADMobileAds.sharedInstance.applicationMuted = YES;
    }
    [self initCompleteAndRetryStartAdIfNeeded];
}

- (void)startAd {
    if (![self canStartAd]) {
        return;
    }

    if (self.unitID == nil) {
        return;
    }
    
    if ([self isPrepared]) {
        [self adRequestSccess:self.rewardedAd];
        return;
    }
    
    @try {
        GADRequest *request = [GADRequest request];
        [GADRewardedAd loadWithAdUnitID:self.unitID
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
}

- (BOOL)isPrepared {
    return [self.rewardedAd canPresentFromRootViewController:[self topMostViewController] error:nil];
}

- (void)showAd {
    [self showAdWithPresentingViewController:[self topMostViewController]];
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAdWithPresentingViewController:viewController];

    if ([self isPrepared]) {
        @try {
            [self.rewardedAd presentFromRootViewController:[self topMostViewController]
                                  userDidEarnRewardHandler:^{
                [self adCompleteShow];
            }];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    }
}

- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"GADRewardedAd");
    if (clazz) {
        NSLog(@"Found Class: GADRewardedAd");
    } else {
        NSLog(@"Not found Class: GADRewardedAd");
        return NO;
    }
    return YES;
}

- (void)adRequestSccess:(GADRewardedAd * _Nullable)rewardedAd {
    NSLog(@"%s", __FUNCTION__);
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
    NSLog(@"%s error: %@", __FUNCTION__, error);
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

- (void)adCompleteShow {
    self.isAdsCompleteShow = YES;
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
}

#pragma mark - GADFullScreenContentDelegate

- (void)adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"%s", __FUNCTION__);
    self.isAdsCompleteShow = NO;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    NSLog(@"%s", __FUNCTION__);
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}

- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"%s", __FUNCTION__);
}

- (void)adWillDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
    NSLog(@"%s", __FUNCTION__);
}

- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"%s", __FUNCTION__);
    if (!self.isAdsCompleteShow) {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
    [self setCallbackStatus:MovieRewardCallbackClose];
}

@end

@implementation MovieReward6060

@end
