//
//  AdnetworkConfigure6019.h
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/04/15.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import <ADFMovieReward/ADFMovieReward.h>
#import <ADFMovieReward/ADFmyAdnetworkConfigure.h>
#import <ADFMovieReward/ADFmyBaseAdapterInterface.h>

#import <GoogleMobileAds/GoogleMobileAds.h>

#import "AdnetworkParam6019.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdnetworkConfigure6019 : ADFmyAdnetworkConfigure

- (void)setHasGdprConsent:(nullable NSNumber *)hasGdprConsent request:(GADRequest *)request;

@end

NS_ASSUME_NONNULL_END
