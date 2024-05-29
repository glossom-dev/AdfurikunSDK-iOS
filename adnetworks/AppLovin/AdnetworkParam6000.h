//
//  AdnetworkParam6000.h
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/04/23.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import <ADFMovieReward/ADFMovieReward.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdnetworkParam6000 : ADFAdnetworkParam

@property(nonatomic, strong) NSString* appLovinSdkKey;
@property(nonatomic, strong) NSString* submittedPackageName;
@property(nonatomic, strong) NSString* zoneIdentifier;

@end

NS_ASSUME_NONNULL_END
