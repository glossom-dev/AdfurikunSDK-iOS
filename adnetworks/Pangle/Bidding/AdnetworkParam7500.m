//
//  AdnetworkParam7500.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2025/12/01.
//  Copyright © 2025 GREE X, Inc. All rights reserved.
//

#import "AdnetworkParam7500.h"

@implementation AdnetworkParam7500

- (instancetype)initWithParam:(NSDictionary *)param {
    self = [super initWithParam:param];
    if (self) {
        self.adxID = [self pangleAdxId];
        [self parseBiddingAdValues:param];
    }
    return self;
}

- (bool)isValid {
    return ([super isValid] && self.adm);
}

@end
