//
//  AdnetworkParam7501.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2026/03/03.
//  Copyright © 2026 GREE X, Inc. All rights reserved.
//

#import "AdnetworkParam7501.h"

@implementation AdnetworkParam7501

- (instancetype)initWithParam:(NSDictionary *)param {
    self = [super initWithParam:param];
    if (self) {
        [self parseBiddingAdValues:param];
    }
    return self;
}

- (bool)isValid {
    return ([super isValid] && self.adm);
}

@end
