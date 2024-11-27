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

@interface Banner6006 : ADFmyMovieNativeInterface <VungleBannerViewDelegate>

@property (nonatomic) VungleAdSize *bannerSize;

@end

@interface NativeAdInfo6006 : ADFNativeAdInfo

@end

@interface Banner6200 : Banner6006
@end

@interface Banner6201 : Banner6006
@end

@interface Banner6202 : Banner6006
@end

@interface Banner6203 : Banner6006
@end

@interface Banner6204 : Banner6006
@end

@interface Banner6205 : Banner6006
@end

@interface Banner6206 : Banner6006
@end

@interface Banner6207 : Banner6006
@end

@interface Banner6208 : Banner6006
@end


NS_ASSUME_NONNULL_END
