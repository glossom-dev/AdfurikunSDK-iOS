//
//  MovieNative6019.h
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/02/10.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import <ADFMovieReward/ADFMovieReward.h>

#import <GoogleMobileAds/GoogleMobileAds.h>

NS_ASSUME_NONNULL_BEGIN

@interface MovieNative6019 : ADFmyMovieNativeInterface

@end

@interface MovieNativeAdView6019 : GADNativeAdView

- (void)setupAdView:(GADNativeAd *)nativeAd;
- (BOOL)isVideoContents;

@end

@interface MovieNativeAdInfo6019 : ADFNativeAdInfo

@property (nonatomic) MovieNativeAdView6019* nativeAdView;

@end

@interface MovieNative6160 : MovieNative6019
@end

@interface MovieNative6161 : MovieNative6019
@end

@interface MovieNative6162 : MovieNative6019
@end

@interface MovieNative6163 : MovieNative6019
@end

@interface MovieNative6164 : MovieNative6019
@end

@interface MovieNative6060 : MovieNative6019 // GAM

@end

NS_ASSUME_NONNULL_END
