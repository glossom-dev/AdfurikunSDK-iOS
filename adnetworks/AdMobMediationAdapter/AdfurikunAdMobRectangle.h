//
//  AdfurikunAdMobRectangle.h
//
//  Copyright © 2019 Glossom.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <ADFMovieReward/ADFmyRectangle.h>
#import "AdfurikunAdMobBanner.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdfurikunAdMobRectangle : AdfurikunAdMobBanner
@property(nonatomic) ADFmyRectangle *bannerAd;
@end

NS_ASSUME_NONNULL_END
