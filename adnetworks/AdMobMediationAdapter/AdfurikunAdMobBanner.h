//
//  AdfurikunAdMobBanner.h
//
//  Copyright © 2019 Glossom.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <ADFMovieReward/ADFmyBanner.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdfurikunAdMobBanner : NSObject <GADMediationAdapter, GADMediationBannerAd, ADFmyNativeAdDelegate, ADFMediaViewDelegate>
@property(nonatomic)ADFmyBanner *bannerAd;
@property CGRect bannerSize;
- (ADFmyBanner *)createADFBanner:(NSString *)appId;
@end

NS_ASSUME_NONNULL_END
