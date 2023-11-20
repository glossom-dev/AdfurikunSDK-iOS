//
//  AdfurikunAdMobInterstitial.m
//
//  Copyright © 2019 Glossom.Inc. All rights reserved.
//

#import "AdfurikunAdMobInterstitial.h"

@implementation AdfurikunAdMobInterstitial
@synthesize delegate;

- (void)requestInterstitialAdWithParameter:(NSString *)serverParameter label:(NSString *)serverLabel request:(GADCustomEventRequest *)request {
    [ADFmyInterstitial initializeWithAppID:serverParameter];
    self.interstitialAd = [ADFmyInterstitial getInstance:serverParameter delegate:self];
    [self.interstitialAd load];
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    if ([self.interstitialAd isPrepared]) {
        [self.interstitialAd play];
    }
}

- (void)AdsFetchCompleted:(NSString *)appID isTestMode:(BOOL)isTestMode_inApp {
    NSLog(@"%s", __FUNCTION__);
    [self.delegate customEventInterstitialDidReceiveAd:self];
}

- (void)AdsFetchFailed:(NSString *)appID error:(NSError *)error adnetworkError:(NSArray<AdnetworkError *> *)adnetworkError {
    NSLog(@"%s", __FUNCTION__);
    [self.delegate customEventInterstitial:self didFailAd:error];
}

- (void)AdsDidShow:(NSString *)appID adnetworkKey:(NSString *)adnetworkKey {
    NSLog(@"%s", __FUNCTION__);
    [self.delegate customEventInterstitialWillPresent:self];
}

- (void)AdsDidCompleteShow:(NSString *)appID {
    NSLog(@"%s", __FUNCTION__);
}

- (void)AdsDidHide:(NSString *)appID {
    NSLog(@"%s", __FUNCTION__);
    [self.delegate customEventInterstitialWillDismiss:self];
    [self.delegate customEventInterstitialDidDismiss:self];
}

@end
