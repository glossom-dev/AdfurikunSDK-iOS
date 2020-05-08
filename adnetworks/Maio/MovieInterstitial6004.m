//
//  MovieInterstitial6004.m
//  SampleViewRecipe
//
//  Created by Junhua Li on 2016/11/03.
//
//

#import "MovieInterstitial6004.h"

@implementation MovieInterstitial6004

-(void)initAdnetworkIfNeeded {
    [super initAdnetworkIfNeeded];
    MovieDelegate6004 *delegate = [MovieDelegate6004 sharedInstance];
    [delegate setCancellable];
}

@end
