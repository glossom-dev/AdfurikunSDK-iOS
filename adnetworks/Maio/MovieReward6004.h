//
//  MovieReword6004.h
//  SampleViewRecipe
//
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <ADFMovieReward/ADFmyMovieRewardInterface.h>
#import <ADFMovieReward/ADFmyMovieDelegateBase.h>
#import <Maio/Maio.h>


@interface MovieReward6004 : ADFmyMovieRewardInterface

@end


/**
 *  Maio用のDelegateクラス
 */
@interface MovieDelegate6004 : ADFmyMovieDelegateBase<MaioDelegate>
@property (nonatomic) BOOL closeFlg;
+ (instancetype)sharedInstance;

@end
