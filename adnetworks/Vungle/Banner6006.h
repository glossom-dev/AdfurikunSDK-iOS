//
//  Banner6006.h
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/10/13.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import <ADFMovieReward/ADFMovieReward.h>
#import <VungleSDK/VungleSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface Banner6006 : ADFmyMovieNativeInterface

@property (nonatomic) BOOL isNeedToStartAd;
@property (nonatomic) BOOL isBannerSize;

-(void)loadCompleted;
-(void)loadFailed;
-(void)adClicked;

@end

@interface NativeAdInfo6006 : ADFNativeAdInfo

@end

NS_ASSUME_NONNULL_END
