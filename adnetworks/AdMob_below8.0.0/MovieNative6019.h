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

@interface MovieNativeAdView6019 : GADUnifiedNativeAdView

- (void)setupAdView:(GADUnifiedNativeAd *)nativeAd;
- (BOOL)isVideoContents;

@end

@interface MovieNativeAdInfo6019 : ADFNativeAdInfo

@property (nonatomic) MovieNativeAdView6019* nativeAdView;

@end

@interface MovieNative6060 : MovieNative6019

@end

NS_ASSUME_NONNULL_END
