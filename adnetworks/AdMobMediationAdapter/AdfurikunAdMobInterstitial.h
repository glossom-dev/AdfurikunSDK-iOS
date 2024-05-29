//
//  AdfurikunAdMobInterstitial.h
//
//  Copyright © 2019 Glossom.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <ADFMovieReward/ADFmyInterstitial.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdfurikunAdMobInterstitial : NSObject <GADMediationAdapter, GADMediationInterstitialAd, ADFmyMovieRewardDelegate>
@property(nonatomic) ADFmyInterstitial *interstitialAd;
@end

NS_ASSUME_NONNULL_END
