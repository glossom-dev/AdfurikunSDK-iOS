//
//  AdnetworkInitializer7503.h
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2026/07/07.
//  Copyright © 2026 GREE X, Inc. All rights reserved.
//

#import <ADFMovieReward/ADFMovieReward.h>
#import "AdnetworkParam7503.h"
#import "InMobiSDK/InMobiSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdnetworkInitializer7503 : ADFmyBaseAdnetworkInitializer

@property (nonatomic) AdnetworkParam7503 *param;

@property (nonatomic) NSNumber *gdprStatus;
@property (nonatomic) NSNumber *isChildDirected;

@end

NS_ASSUME_NONNULL_END
