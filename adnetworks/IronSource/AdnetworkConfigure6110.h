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

@interface AdnetworkConfigure6110 : ADFmyAdapterLogger<ISInitializationDelegate, ISRewardedVideoManualDelegate, ISInterstitialDelegate, ISBannerDelegate>

+ (instancetype)sharedInstance;
- (void)initIronSource:(NSString *)appKey completion:(completionHandlerType)completionHandler;
- (void)destroyBannerView;

@property (nonatomic, weak) ADFmyMovieRewardInterface *movieRewardAdapter;
@property (nonatomic, weak) ADFmyMovieRewardInterface *interstitialAdapter;
@property (nonatomic, weak) ADFmyMovieNativeInterface *bannerAdapter;

@end

NS_ASSUME_NONNULL_END
