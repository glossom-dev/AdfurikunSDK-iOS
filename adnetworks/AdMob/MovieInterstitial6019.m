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

@interface MovieInterstitial6019 ()<GADInterstitialDelegate>
@property(nonatomic) GADInterstitial *interstitial;
@property(nonatomic) NSString *unitID;
@property (nonatomic) BOOL testFlg;
@end

@implementation MovieInterstitial6019

+(NSString *)getAdapterVersion {
    return @"7.68.0.2";
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
    return self.interstitial.isReady;
}

- (void)startAd {
    if (self.unitID == nil) {
        return;
    }
    
    if (!self.interstitial || !self.interstitial.isReady) {
        @try {
            self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:self.unitID];
            self.interstitial.delegate = self;
            GADRequest *request = [GADRequest request];
            [self.interstitial loadRequest:request];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    }
}

- (void)showAd {
    [self showAdWithPresentingViewController:[self topMostViewController]];
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAdWithPresentingViewController:viewController];

    if (self.interstitial.isReady) {
        @try {
            [self.interstitial presentFromRootViewController:viewController];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    }
}

- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"GADInterstitial");
    if (clazz) {
        NSLog(@"Found Class: GADInterstitial");
    } else {
        NSLog(@"Not found Class: GADInterstitial");
        return NO;
    }
    return YES;
}

#pragma mark - GADInterstitialDelegate

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    NSLog(@"%s", __FUNCTION__);
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"%s error: %@", __FUNCTION__, error);
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    NSLog(@"%s", __FUNCTION__);
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    NSLog(@"%s", __FUNCTION__);
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    NSLog(@"%s", __FUNCTION__);
    [self setCallbackStatus:MovieRewardCallbackClose];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    NSLog(@"%s", __FUNCTION__);
}

@end

@implementation MovieInterstitial6060

@end
