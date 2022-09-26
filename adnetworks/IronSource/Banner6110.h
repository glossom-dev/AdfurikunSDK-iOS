//
//  Banner6110.h
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2022/08/17.
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import <ADFMovieReward/ADFMovieReward.h>
#import <IronSource/IronSource.h>

NS_ASSUME_NONNULL_BEGIN

@interface Banner6110 : ADFmyMovieNativeInterface

@property (nonatomic) ISBannerSize *bannerSize;
@property (nonatomic, nullable) ISBannerView *bannerView;

@end

@interface NativeAdInfo6110 : ADFNativeAdInfo

@end

NS_ASSUME_NONNULL_END
