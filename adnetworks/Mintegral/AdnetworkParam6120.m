//
//  AdnetworkParam6120.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2022/09/02.
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import "AdnetworkParam6120.h"

@implementation AdnetworkParam6120

- (instancetype)initWithParam:(NSDictionary *)param {
    self = [super initWithParam:param];
    if (self) {
        NSString *appKey = [param objectForKey:@"app_key"];
        if ([self isString:appKey]) {
            self.appKey = [NSString stringWithFormat:@"%@", appKey];
        }

        NSString *appId = [param objectForKey:@"app_id"];
        if ([self isString:appId]) {
            self.appId = [NSString stringWithFormat:@"%@", appId];
        }

        NSString *placementId = [param objectForKey:@"placement_id"];
        if ([self isString:placementId]) {
            self.placementId = [NSString stringWithFormat:@"%@", placementId];
        }

        NSString *unitId = [param objectForKey:@"unit_id"];
        if ([self isString:unitId]) {
            self.unitId = [NSString stringWithFormat:@"%@", unitId];
        }
    }
    return self;
}

- (bool)isValid {
    return (self.appKey && self.appId && self.placementId && self.unitId);
}

@end
