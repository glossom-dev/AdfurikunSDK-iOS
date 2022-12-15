//
//  Banner6120.h
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2022/09/14.
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import <ADFMovieReward/ADFMovieReward.h>
#import <MTGSDK/MTGSDK.h>
#import <MTGSDKBanner/MTGBannerAdView.h>
#import <MTGSDKBanner/MTGBannerAdViewDelegate.h>

#import "MovieNative6120.h"

NS_ASSUME_NONNULL_BEGIN

@interface Banner6120 : ADFmyMovieNativeInterface <MTGBannerAdViewDelegate>

@property (nonatomic) MTGBannerSizeType adSize;

@end

@interface Banner6121 : Banner6120
@end

@interface Banner6122 : Banner6120
@end

@interface Banner6123 : Banner6120
@end

@interface Banner6124 : Banner6120
@end

@interface Banner6125 : Banner6120
@end

NS_ASSUME_NONNULL_END
