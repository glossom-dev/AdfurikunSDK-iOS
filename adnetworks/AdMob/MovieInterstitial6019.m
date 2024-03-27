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
    return @"15";
}

+ (NSString *)adnetworkClassName {
    return @"GADInterstitialAd";
}

+ (NSString *)adnetworkName {
    return @"AdMob";
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
    [self initCompleteAndRetryStartAdIfNeeded];
}

- (BOOL)isPrepared {
    return self.isAdLoaded;
}

- (void)startAd {
    if (![self canStartAd]) {
        return;
    }

    if (self.unitID == nil) {
        return;
    }
    
    if ([self isPrepared]) {
        [self adRequestSccess:self.interstitial];
        return;
    }
    
    [super startAd];
    
    @try {
        GADRequest *request = [GADRequest request];
        if (self.hasGdprConsent) {
            GADExtras *extras = [[GADExtras alloc] init];
            extras.additionalParameters = @{@"npa": self.hasGdprConsent.boolValue ? @"1" : @"0"};
            [request registerAdNetworkExtras:extras];
            AdapterLogP(@"[ADF] Adnetwork 6019, gdprConsent : %@, sdk setting value : %@", self.hasGdprConsent, extras.additionalParameters);
        }
        [self requireToAsyncRequestAd];
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
            [self requireToAsyncPlay];
            [self.interstitial presentFromRootViewController:viewController];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    }
}

- (void)isChildDirected:(BOOL)childDirected {
    [super isChildDirected:childDirected];
    GADMobileAds.sharedInstance.requestConfiguration.tagForChildDirectedTreatment = [NSNumber numberWithBool:childDirected];
    AdapterLogP(@"Adnetwork %@, childDirected : %@, input parameter : %d", self.adnetworkKey, self.childDirected, (int)childDirected);
}

- (void)adRequestSccess:(GADInterstitialAd * _Nullable)interstitialAd {
    AdapterTrace;
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
    AdapterTraceP(@"error: %@", error);
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

#pragma mark - GADFullScreenContentDelegate

- (void)adDidRecordImpression:(nonnull id<GADFullScreenPresentingAd>)ad {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    AdapterTraceP(@"error: %@", error);
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
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    [self setCallbackStatus:MovieRewardCallbackClose];
}

@end

@implementation MovieInterstitial6160
@end

@implementation MovieInterstitial6161
@end

@implementation MovieInterstitial6162
@end

@implementation MovieInterstitial6163
@end

@implementation MovieInterstitial6164
@end

@implementation MovieInterstitial6060

+ (NSString *)adnetworkName {
    return @"Google Ad Manager";
}

@end
