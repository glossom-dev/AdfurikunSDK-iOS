//
//  MovieInterstitial6010.m
//  MovieRewardSampleDev
//
//  Created by Zheng Gong on 2018/7/13.
//  Copyright © 2018年 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import "MovieInterstitial6010.h"

@implementation MovieInterstitial6010

-(id)init {
    self = [super init];
    if (self) {
        [self setCancellable];
    }
    return self;
}

-(void)setCancellable {
    [super setCancellable];
    
    if (self.amoadInterstitialVideo) {
        [self.amoadInterstitialVideo setCancellable:YES];
    }
}

@end
