//
//  Rectangle6020.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/06/19.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "Rectangle6020.h"
#import "MoPub.h"

@implementation Rectangle6020

- (instancetype)init {
    self = [super init];
    if (self) {
        self.adSize = CGSizeMake(300, 250);
    }
    return self;
}

@end
