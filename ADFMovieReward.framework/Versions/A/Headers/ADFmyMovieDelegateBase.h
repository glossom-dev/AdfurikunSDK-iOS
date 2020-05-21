//
//  ADFmyMovieDelegateBase.h
//  ADFMovieReword
//
//  Created by Toru Furuya on 2017/01/18.
//  (c) 2017 ADFULLY Inc.
//

#import <Foundation/Foundation.h>

#import "ADFmyMovieRewardInterface.h"

@interface ADFmyMovieDelegateBase : NSObject

- (void)setMovieReward:(ADFmyMovieRewardInterface *)movieReward inZone:(NSString *)zoneId;
- (ADFmyMovieRewardInterface *)getMovieRewardWithZone:(NSString *)zoneId;
- (NSDictionary<NSString *, ADFmyMovieRewardInterface *> *)getAllMovieReward;

-(void)setCallbackStatus:(MovieRewardCallbackStatus)status zone:(NSString *)zoneId;

@end
