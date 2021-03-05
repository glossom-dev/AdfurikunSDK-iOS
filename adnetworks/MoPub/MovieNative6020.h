//
//  MovieNative6020.h
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/07/27.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import <MoPub/MoPub.h>
#import <ADFMovieReward/ADFMovieReward.h>

NS_ASSUME_NONNULL_BEGIN

@interface MovieNative6020 : ADFmyMovieNativeInterface <MPNativeAdDelegate>

@end

@interface MovieNativeAdView6020 : UIView <MPNativeAdRendering>

@end

@interface MovieNativeAdInfo6020 : ADFMovieNativeAdInfo

@property (nonatomic, strong) MPNativeAd *nativeAd;

@end

NS_ASSUME_NONNULL_END
