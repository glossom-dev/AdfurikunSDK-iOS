//
//  MovieNative6016.h
//  MovieRewardSampleDev
//
//  Created by Amin Al on 2018/09/10.
//  Copyright © 2018 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ADFMovieReward/ADFmyMovieNativeInterface.h>
#import <ADFMovieReward/ADFNativeAdInfo.h>
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface MovieNative6016 : ADFmyMovieNativeInterface

@end

@interface MovieNativeAdInfo6016 : ADFNativeAdInfo

@property (nonatomic) FBNativeAd *nativeAd;

@property (nonatomic) FBNativeBannerAd *nativeBannerAd;

@property (nonatomic) FBMediaView *fbMediaView;

@property (nonatomic) FBMediaView *fbAdIconView;

@property (nonatomic) FBAdChoicesView *fbAdChoicesView;

@property (nonatomic) UIButton *fbCallToActionButton;

@property (nonatomic) UILabel *fbSocialContextLabel;

@property (nonatomic) UILabel *fbAdBodyLabel;

@property (nonatomic) UILabel *fbAdTitleLabel;

@property (nonatomic) UILabel *fbAdAdvertiserNameLabel;

@property (nonatomic) UILabel *fbAdSponsoredLabel;

@end

@interface MovieNative6040 : MovieNative6016

@end

@interface MovieNative6041 : MovieNative6016

@end
