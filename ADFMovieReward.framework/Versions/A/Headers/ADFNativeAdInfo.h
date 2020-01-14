//
//  ADFNativeAdInfo.h
//  ADFMovieReward
//
//  Created by Sungil Kim on 2019/06/26.
//  Copyright © 2019 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADFMovieNativeAdInfo.h"

typedef NS_ENUM(NSInteger, ADFNativeAdType) {
    ADFNativeAdType_Unknown,
    ADFNativeAdType_Movie,
    ADFNativeAdType_Image,
};

@interface ADFNativeAdInfo : ADFMovieNativeAdInfo
@end
