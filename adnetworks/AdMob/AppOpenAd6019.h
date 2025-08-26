//
//  AppOpenAd6019.h
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2023/03/22.
//  Copyright © 2023 Glossom, Inc. All rights reserved.
//

#import <ADFMovieReward/ADFMovieReward.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppOpenAd6019 : ADFmyAppOpenAdAdapterInterface <GADFullScreenContentDelegate>

@end

@interface AppOpenAd6060 : AppOpenAd6019 // GAM
@end

@interface AppOpenAd6220 : AppOpenAd6019
@end

NS_ASSUME_NONNULL_END
