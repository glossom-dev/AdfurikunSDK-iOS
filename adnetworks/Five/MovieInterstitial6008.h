//
//  MovieInterstitial6008.h(Five)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <FiveAd/FiveAd.h>
#import <ADFMovieReward/ADFmyMovieRewardInterface.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^completionHandlerType)(void);

@interface MovieInterstitial6008 : ADFmyMovieRewardInterface

@property (nonatomic)FADNeedGdprNonPersonalizedAdsTreatment gdprStatus;

@end
@interface MovieConfigure6008 : NSObject

+ (instancetype)sharedInstance;
- (void)configureWithAppId:(NSString *)fiveAppId isTest:(BOOL)isTest gdprStatus:(FADNeedGdprNonPersonalizedAdsTreatment)gdprStatus completion:(completionHandlerType)completionHandler;

@end

@interface MovieInterstitial6070 : MovieInterstitial6008
@end

@interface MovieInterstitial6071 : MovieInterstitial6008
@end

@interface MovieInterstitial6072 : MovieInterstitial6008
@end

@interface MovieInterstitial6073 : MovieInterstitial6008
@end

@interface MovieInterstitial6074 : MovieInterstitial6008
@end

NS_ASSUME_NONNULL_END
