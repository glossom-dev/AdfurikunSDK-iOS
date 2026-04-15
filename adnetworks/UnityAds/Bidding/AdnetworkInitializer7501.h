//
//  AdnetworkInitializer7501.h
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2025/12/02.
//  Copyright © 2025 GREE X, Inc. All rights reserved.
//

#import <ADFMovieReward/ADFMovieReward.h>
#import <UnityAds/UnityAds.h>

#import "AdnetworkParam6001.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdnetworkInitializer7501 : ADFmyBaseAdnetworkInitializer <UnityAdsInitializationDelegate>

@property (nonatomic) AdnetworkParam6001 *param;
@property (nonatomic) ADFInitAdnetworkForBiddingCompleteHandler handler;
@end

NS_ASSUME_NONNULL_END
