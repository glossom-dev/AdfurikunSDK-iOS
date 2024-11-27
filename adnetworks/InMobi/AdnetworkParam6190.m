//
//  AdnetworkParam6190.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/10/28.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import "AdnetworkParam6190.h"

@implementation AdnetworkParam6190

- (instancetype)initWithParam:(NSDictionary *)param {
    self = [super initWithParam:param];
    if (self) {
        NSString *accountId = [param objectForKey:@"account_id"];
        if ([self isString:accountId]) {
            self.accountId = [NSString stringWithFormat:@"%@", accountId];
        }

        NSString *placementId = [param objectForKey:@"placement_id"];
        if ([self isString:placementId]) {
            self.placementId = [NSString stringWithFormat:@"%@", placementId];
        }
    }
    return self;
}

- (bool)isValid {
    return self.accountId && self.placementId && self.placementId.integerValue > 0;
}

@end
