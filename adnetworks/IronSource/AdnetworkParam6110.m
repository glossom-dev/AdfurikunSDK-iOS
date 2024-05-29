//
//  AdnetworkParam6110.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/04/25.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import "AdnetworkParam6110.h"

@implementation AdnetworkParam6110

- (instancetype)initWithParam:(NSDictionary *)param {
    self = [super initWithParam:param];
    if (self) {
        NSString *appKey = [param objectForKey:@"app_key"];
        if ([self isString:appKey]) {
            self.appKey = [NSString stringWithFormat:@"%@", appKey];
        }
        
        NSString *instanceId = [param objectForKey:@"instance_id"];
        if ([self isString:instanceId]) {
            self.instanceId = [NSString stringWithFormat:@"%@", instanceId];
        }
    }
    return self;
}

- (bool)isValid {
    return self.appKey && self.instanceId;
}

@end
