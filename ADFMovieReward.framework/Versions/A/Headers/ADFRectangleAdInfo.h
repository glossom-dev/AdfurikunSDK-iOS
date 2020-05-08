//
//  ADFRectangleAdInfo.h
//  ADFMovieReward
//
//  Created by Ren Fujii on 2019/05/10.
//  Copyright © 2019年 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADFMovieNativeAdInfo.h"
#import "ADFMediaView.h"

/**
 レクタングル広告の情報を格納したオブジェクト
 */

@interface ADFRectangleAdInfo : ADFMovieNativeAdInfo
- (NSDictionary*)getCustomRectangleComponents;
@end
