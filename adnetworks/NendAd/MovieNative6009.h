//
//  MovieNative6009.h
//  MovieRewardSampleDev
//
//  Created by Sungil Kim on 2018/07/12.
//  Copyright © 2018年 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import <NendAd/NendAd.h>
#import <ADFMovieReward/ADFmyMovieNativeInterface.h>
#import <ADFMovieReward/ADFNativeAdInfo.h>

@interface MovieNative6009 : ADFmyMovieNativeInterface
@property (nonatomic, strong) NADNativeVideoView *nativeVideoView;
@property (nonatomic, strong) NADNativeVideoLoader *videoAdLoader;
@end

@interface MovieNativeAdInfo6009 : ADFNativeAdInfo

@end

@interface MovieNative6080 : MovieNative6009

@end

@interface MovieNative6081 : MovieNative6009

@end

@interface MovieNative6082 : MovieNative6009

@end
