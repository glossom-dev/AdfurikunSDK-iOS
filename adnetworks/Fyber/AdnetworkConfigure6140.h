//
//  AdnetworkConfigure6140.h
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/04/24.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import <ADFMovieReward/ADFMovieReward.h>
#import <IASDKCore/IASDKCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdnetworkConfigure6140 : ADFmyAdnetworkConfigure <IAGlobalAdDelegate>

@property (nonatomic) NSString *creativeId;

@end

NS_ASSUME_NONNULL_END
