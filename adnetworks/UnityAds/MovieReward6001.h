//
//  MovieReward6001.h(UnityAds)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <ADFMovieReward/ADFmyMovieRewardInterface.h>
#import <ADFMovieReward/ADFmyMovieDelegateBase.h>

#import <UnityAds/UnityAds.h>

@interface MovieReward6001 : ADFmyMovieRewardInterface

@end

@interface MovieDelegate6001 : ADFmyMovieDelegateBase<UnityAdsDelegate, UnityAdsShowDelegate>

+ (instancetype)sharedInstance;

@end

@interface MovieReward6030 : MovieReward6001

@end

@interface MovieReward6031 : MovieReward6001

@end
