//
//  Banner6006.h
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/10/13.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import <ADFMovieReward/ADFMovieReward.h>
#import <VungleAdsSDK/VungleAdsSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface Banner6006 : ADFmyMovieNativeInterface <VungleBannerDelegate>

@property (nonatomic) BannerSize bannerSize;

@end

@interface NativeAdInfo6006 : ADFNativeAdInfo

@end

NS_ASSUME_NONNULL_END
