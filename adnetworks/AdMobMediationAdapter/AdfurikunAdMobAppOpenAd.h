//
//  AdfurikunAdMobAppOpenAd.h
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2025/09/25.
//  Copyright © 2025 GREE X, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <ADFMovieReward/ADFMovieReward.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdfurikunAdMobAppOpenAd : NSObject <GADMediationAdapter, GADMediationAppOpenAd, ADFmyAppOpenAdDelegate>

@property (nonatomic) ADFmyAppOpenAd *appOpenAd;

@end

NS_ASSUME_NONNULL_END
