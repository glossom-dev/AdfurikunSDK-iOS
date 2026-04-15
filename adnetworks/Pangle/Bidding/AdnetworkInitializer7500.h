//
//  AdnetworkInitializer7500.h
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2025/10/29.
//  Copyright © 2025 GREE X, Inc. All rights reserved.
//

#import <ADFMovieReward/ADFMovieReward.h>
#import "AdnetworkParam7500.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdnetworkInitializer7500 : ADFmyBaseAdnetworkInitializer

@property (nonatomic) AdnetworkParam7500 *param;

@property (nonatomic) NSNumber *gdprStatus;
@property (nonatomic) NSNumber *isChildDirected;

@end

NS_ASSUME_NONNULL_END
