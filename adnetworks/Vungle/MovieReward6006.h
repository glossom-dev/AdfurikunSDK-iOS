//
//  MovieReward6006.h(Vungle)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <ADFMovieReward/ADFmyMovieRewardInterface.h>
#import <ADFMovieReward/ADFmyMovieDelegateBase.h>

#import <VungleSDK/VungleSDK.h>

#import "Banner6006.h"

@interface MovieReward6006 : ADFmyMovieRewardInterface

@end

@interface MovieDelegate6006 : ADFmyMovieDelegateBase<VungleSDKDelegate>

+ (instancetype)sharedInstance;
- (void)setBanner:(Banner6006 *)banner inZone:(NSString *)zoneId;
- (void)removeBannerInZone:(NSString *)zoneId;
- (Banner6006 *)getBannerWithZone:(NSString *)zoneId;

@end
