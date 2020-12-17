//
//  Banner6002.h
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/10/08.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import <ADFMovieReward/ADFMovieReward.h>
#import <AdColony/AdColony.h>
#import "MovieReward6002.h"

NS_ASSUME_NONNULL_BEGIN

@interface Banner6002 : ADFmyMovieNativeInterface

@property (nonatomic) AdColonyAdSize adSize;

@end

@interface NativeAdInfo6002 : ADFNativeAdInfo

@end

NS_ASSUME_NONNULL_END
