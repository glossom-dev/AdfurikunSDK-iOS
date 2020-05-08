//
//  ADFmyCarousel.h
//  ADFMovieReward
//
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "ADFmyRectangle.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ADFmyCarouselDelegate <NSObject>
@required
- (void)onCarouselLoadFinish:(UIView *)carouselView;
@optional
- (void)onCarouselLoadError:(ADFMovieError *)error;
- (void)onCarouselViewImpressionKey:(NSString *)key appID:(NSString *)appID index:(NSInteger)index;
- (void)onCarouselViewClickKey:(NSString *)key appID:(NSString *)appID index:(NSInteger)index;
@end

@interface ADFmyCarousel : NSObject
+ (instancetype)initializeWithAppIDList:(NSDictionary<NSString *, NSString *> *)appIdDic;
- (void)loadAndNotify:(id<ADFmyCarouselDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
