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

@interface Banner6110 : ADFmyMovieNativeInterface <ISDemandOnlyBannerDelegate>

@property (nonatomic) ISBannerSize *bannerSize;
@property (nonatomic, nullable) ISDemandOnlyBannerView *bannerView;

@end

@interface NativeAdInfo6110 : ADFNativeAdInfo

@end

@interface Banner6111 : Banner6110
@end

@interface Banner6112 : Banner6110
@end

@interface Banner6113 : Banner6110
@end

@interface Banner6114 : Banner6110
@end

@interface Banner6115 : Banner6110
@end

@interface Banner6116 : Banner6110
@end

@interface Banner6117 : Banner6110
@end

@interface Banner6118 : Banner6110
@end

@interface Banner6119 : Banner6110
@end

NS_ASSUME_NONNULL_END
