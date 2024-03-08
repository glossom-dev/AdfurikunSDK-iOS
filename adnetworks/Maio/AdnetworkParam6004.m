//
//  AdnetworkParam6004.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/02/22.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import "AdnetworkParam6004.h"

@implementation AdnetworkParam6004

- (instancetype)initWithParam:(NSDictionary *)param {
    self = [super initWithParam:param];
    if (self) {
        NSString *maioMediaId = [param objectForKey:@"media_id"];
        if ([self isString:maioMediaId]) {
            self.maioMediaId = [NSString stringWithFormat:@"%@", maioMediaId];
        }

        NSString *maioZoneId = [param objectForKey:@"spot_id"];
        if ([self isString:maioZoneId]) {
            self.maioZoneId = [NSString stringWithFormat:@"%@", maioZoneId];
        }
    }
    return self;
}

- (bool)isValid {
    return (self.maioMediaId && self.maioZoneId);
}

@end
