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

- (void)setData:(NSDictionary *)data {
    NSString* admobId = [data objectForKey:@"ad_unit_id"];
    if (admobId != nil && ![admobId isEqual:[NSNull null]]) {
        self.unitID = [[NSString alloc] initWithString:admobId];
    }
    self.testFlg = [[data objectForKey:@"test_flg"] boolValue];
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
    self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:self.unitID];
    self.interstitial.delegate = self;
    GADRequest *request = [GADRequest request];
    [self.interstitial loadRequest:request];
}

- (void)showAd {
    [self showAdWithPresentingViewController:[self topMostViewController]];
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    if (self.interstitial.isReady) {
        [self.interstitial presentFromRootViewController:viewController];
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
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"%s error: %@", __FUNCTION__, error);
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsFetchError:)]) {
            [self setErrorWithMessage:error.localizedDescription code:error.code];
            [self.delegate AdsFetchError:self];
        } else {
            NSLog(@"%s AdsFetchError selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    NSLog(@"%s", __FUNCTION__);
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidShow:)]) {
            [self.delegate AdsDidShow:self];
        } else {
            NSLog(@"%s AdsDidShow selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    NSLog(@"%s", __FUNCTION__);
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidCompleteShow:)]) {
            [self.delegate AdsDidCompleteShow:self];
        } else {
            NSLog(@"%s AdsDidCompleteShow selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
    NSLog(@"%s", __FUNCTION__);
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidHide:)]) {
            [self.delegate AdsDidHide:self];
        } else {
            NSLog(@"%s AdsDidHide selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    NSLog(@"%s", __FUNCTION__);
}

@end
