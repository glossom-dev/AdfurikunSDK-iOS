//
//  AdnetworkParam6017.m
//  MovieRewardTestApp
//
//  Created by Ren Fujii on 2023/02/13.
//  Copyright © 2023 Glossom, Inc. All rights reserved.
//

#import "AdnetworkParam6017.h"

@implementation AdnetworkParam6017

- (instancetype)initWithParam:(NSDictionary *)param {
    self = [super initWithParam:param];
    if (self) {
        NSString *appId = [param objectForKey:@"appid"];
        if ([self isString:appId]) {
            self.appID = [NSString stringWithFormat:@"%@", appId];
        }

        NSString *slotId = [param objectForKey:@"ad_slot_id"];
        if ([self isString:appId]) {
            self.slotID = [NSString stringWithFormat:@"%@", slotId];
        }
    }
    return self;
}

- (bool)isValid {
    return (self.appID && self.slotID);
}

@end
