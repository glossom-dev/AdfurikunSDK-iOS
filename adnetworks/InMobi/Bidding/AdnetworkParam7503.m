//
//  AdnetworkParam7503.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2026/07/07.
//  Copyright © 2026 GREE X, Inc. All rights reserved.
//

#import "AdnetworkParam7503.h"

@implementation AdnetworkParam7503

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
