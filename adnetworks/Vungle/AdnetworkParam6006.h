//
//  AdnetworkParam6006.h
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/02/29.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import <ADFMovieReward/ADFMovieReward.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdnetworkParam6006 : ADFAdnetworkParam

@property (nonatomic, strong)NSString* vungleAppID;
@property (nonatomic) NSString *placementID;
@property (nonatomic) NSArray *allPlacementIDs;

@end

NS_ASSUME_NONNULL_END
