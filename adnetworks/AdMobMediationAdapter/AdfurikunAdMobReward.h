//
//  AdfurikunAdMobReward.h
//
//  Copyright © 2019 Glossom.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <ADFMovieReward/ADFMovieReward.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdfurikunAdMobReward : NSObject <GADMediationAdapter>
@property (nonatomic) ADFmyMovieReward *movieReward;
@end

NS_ASSUME_NONNULL_END
