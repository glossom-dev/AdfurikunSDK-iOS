//
//  MovieInterstitial6005.m (Tapjoy)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import "MovieInterstitial6005.h"

@implementation MovieInterstitial6005

-(void)startAd {
    [super startAd];
    MovieDelegate6005 *delegate = [MovieDelegate6005 sharedInstance];
    [delegate setCancellable];
}

@end
