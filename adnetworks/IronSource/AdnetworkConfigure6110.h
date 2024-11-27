//
//  AdnetworkConfigure6110.h
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2022/08/15.
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ADFMovieReward/ADFMovieReward.h>
#import <IronSource/IronSource.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^completionHandlerType)(void);

@interface AdnetworkConfigure6110 : ADFmyAdnetworkConfigure<ISDemandOnlyRewardedVideoDelegate, ISDemandOnlyInterstitialDelegate, LevelPlayRewardedVideoManualDelegate>

- (void)setMovieRewardAdapter:(ADFmyMovieRewardInterface *)adapter instanceId:(NSString *)instanceId;
- (void)removeMovieRewardAdapterWithInstanceId:(NSString *)instanceId;

- (void)setInterstitialAdapter:(ADFmyMovieRewardInterface *)adapter instanceId:(NSString *)instanceId;
- (void)removeInterstitialAdapterWithInstanceId:(NSString *)instanceId;

@end

NS_ASSUME_NONNULL_END
