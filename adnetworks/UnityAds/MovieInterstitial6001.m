//
//  MovieInterstitial6001.m
//  MovieRewardSampleDev
//
//  Created by Amin Al on 2018/06/22.
//  Copyright © 2018 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import "MovieInterstitial6001.h"

@implementation MovieInterstitial6001

-(void)initAdnetworkIfNeeded {
    [super initAdnetworkIfNeeded];
    MovieDelegate6001 *delegate = [MovieDelegate6001 sharedInstance];
    [delegate setCancellable];
}

@end

