//
//  AdnetworkParam6001.h
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/04/26.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import <ADFMovieReward/ADFMovieReward.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdnetworkParam6001 : ADFBiddingAdnetworkParam

@property (nonatomic, strong) NSString *gameId;
@property (nonatomic, strong) NSString *placementId;
@property (nonatomic, strong) NSString *adm;
@property (nonatomic, strong) NSString *objectId;

@end

NS_ASSUME_NONNULL_END
