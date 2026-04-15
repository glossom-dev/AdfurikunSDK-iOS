//
//  AdnetworkInitializer6110.h
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2025/11/27.
//  Copyright © 2025 GREE X, Inc. All rights reserved.
//

#import <ADFMovieReward/ADFMovieReward.h>
#import "AdnetworkParam6110.h"

NS_ASSUME_NONNULL_BEGIN

// AdQuality SDKをADF SDK初期化タイミングで実施するClass
@interface AdnetworkInitializer6110 : ADFmyBaseAdnetworkInitializer

@property (nonatomic) AdnetworkParam6110 *param;

@end

NS_ASSUME_NONNULL_END
