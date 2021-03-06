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
@property (nonatomic, nullable) NSString *unitID;
@property (nonatomic) GADAdSize adSize;
@property (nonatomic) BOOL testFlg;

@end

@interface Banner6060 : Banner6019

@end

NS_ASSUME_NONNULL_END
