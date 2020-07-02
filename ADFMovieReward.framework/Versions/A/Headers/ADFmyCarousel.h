//
//  ADFmyCarousel.h
//  ADFMovieReward
//
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "ADFmyNativeAd.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ADFmyCarouselDelegate <NSObject>
@required
- (void)onCarouselLoadFinish:(UIView *)carouselView;
@optional
- (void)onCarouselLoadError:(ADFMovieError *)error;
- (void)onCarouselViewImpressionAppID:(NSString *)appID index:(NSInteger)index;
- (void)onCarouselViewClickAppID:(NSString *)appID index:(NSInteger)index;
@end

@interface ADFmyCarousel : NSObject
+ (instancetype)initializeWithAppIDList:(NSArray<NSString *> *)appIdList;
- (void)loadAndNotify:(id<ADFmyCarouselDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
