//
//  AdfurikunAdMobNativeAd.h
//
//  Copyright © 2019 Glossom.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <ADFMovieReward/ADFmyNativeAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADFAdMobNativeAdCustomInfo : NSObject <GADMediatedUnifiedNativeAd, ADFMediaViewDelegate>
- (id)initWithADFNativeAdInfo:(ADFNativeAdInfo *)adInfo;
@end

@interface AdfurikunAdMobNativeAd : NSObject <GADCustomEventNativeAd, ADFmyNativeAdDelegate>
@property (nonatomic)ADFmyNativeAd *nativeAd;
@end

NS_ASSUME_NONNULL_END
