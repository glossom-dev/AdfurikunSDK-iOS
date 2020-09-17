//
//  MovieNative6018.h
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2019/11/06.
//  Copyright © 2019 Glossom, Inc. All rights reserved.
//

#import <ADFMovieReward/ADFmyMovieNativeInterface.h>
#import <ADFMovieReward/ADFMovieNativeAdInfo.h>
#import <FiveAd/FiveAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface MovieNative6018 : ADFmyMovieNativeInterface

@end

@interface MovieConfigure6018 : NSObject
+ (void)configureWithAppId:(NSString *)lineAdsAppId isTest:(BOOL)isTest;
@end

@interface MovieNativeAdInfo6018 : ADFMovieNativeAdInfo
@property (nonatomic) FADNative *nativeAd;
@end

NS_ASSUME_NONNULL_END
