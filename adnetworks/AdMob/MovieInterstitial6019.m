//
//  MovieInterstitial6019.m
//  MovieRewardTestApp
//
//  Created by Ren Fujii on 2019/11/14.
//  Copyright © 2019 Glossom, Inc. All rights reserved.
//

#import "MovieInterstitial6019.h"
#import <ADFMovieReward/ADFMovieOptions.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface MovieInterstitial6019 ()<GADFullScreenContentDelegate>
@property(nonatomic) GADInterstitialAd *interstitial;
@property(nonatomic) NSString *unitID;
@property (nonatomic) BOOL testFlg;
@end

@implementation MovieInterstitial6019

+ (NSString *)getAdapterRevisionVersion {
    return @"4";
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
}

- (BOOL)isPrepared {
    return [self.interstitial canPresentFromRootViewController:[self topMostViewController] error:nil];
}

- (void)startAd {
    if (self.unitID == nil) {
        return;
    }
    
    if ([self isPrepared]) {
        [self adRequestSccess:self.interstitial];
        return;
    }
    
    @try {
        GADRequest *request = [GADRequest request];
        [GADInterstitialAd loadWithAdUnitID:self.unitID
                                    request:request
                          completionHandler:^(GADInterstitialAd * _Nullable interstitialAd, NSError * _Nullable error) {
            if (error) {
                [self adRequestFailure:error];
            } else {
                [self adRequestSccess:interstitialAd];
            }
        }];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (void)showAd {
    [self showAdWithPresentingViewController:[self topMostViewController]];
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAdWithPresentingViewController:viewController];

    if ([self isPrepared]) {
        @try {
            [self.interstitial presentFromRootViewController:viewController];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    }
}

- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"GADInterstitialAd");
    if (clazz) {
        NSLog(@"Found Class: GADInterstitialAd");
    } else {
        NSLog(@"Not found Class: GADInterstitialAd");
        return NO;
    }
    return YES;
}

- (void)adRequestSccess:(GADInterstitialAd * _Nullable)interstitialAd {
    NSLog(@"%s", __FUNCTION__);
    if ([self isNotNull:interstitialAd]) {
        self.interstitial = interstitialAd;
        self.interstitial.fullScreenContentDelegate = self;
        [self setCallbackStatus:MovieRewardCallbackFetchComplete];
    } else {
        NSString *message = @"interstitialAd is null";
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

#pragma mark - GADFullScreenContentDelegate

- (void)adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"%s", __FUNCTION__);
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    NSLog(@"%s", __FUNCTION__);
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}

- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"%s called", __func__);
}

- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"%s", __FUNCTION__);
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    [self setCallbackStatus:MovieRewardCallbackClose];
}

@end

@implementation MovieInterstitial6060

@end
