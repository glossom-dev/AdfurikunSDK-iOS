//
//  Banner6019.h
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/02/10.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import <ADFMovieReward/ADFMovieReward.h>
#import "MovieNative6019.h"

#import <GoogleMobileAds/GoogleMobileAds.h>

NS_ASSUME_NONNULL_BEGIN

@interface Banner6019 : ADFmyMovieNativeInterface<GADBannerViewDelegate>

@property (nonatomic, strong, nullable) GADBannerView *bannerView;
@property (nonatomic) GADAdSize adSize;
@property (nonatomic) BOOL isBannerViewLoaded;

@end

@interface BannerAdInfo6019 : ADFNativeAdInfo

@end

@interface Banner6160 : Banner6019
@end

@interface Banner6161 : Banner6019
@end

@interface Banner6162 : Banner6019
@end

@interface Banner6163 : Banner6019
@end

@interface Banner6164 : Banner6019
@end

@interface Banner6060 : Banner6019 // GAM
@end

NS_ASSUME_NONNULL_END
