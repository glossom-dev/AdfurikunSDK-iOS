//
//  AdnetworkParam6140.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2022/10/03.
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import "AdnetworkParam6140.h"

@implementation AdnetworkParam6140

- (instancetype)initWithParam:(NSDictionary *)param {
    self = [super initWithParam:param];
    if (self) {
        [self commonParamParse:param];
    }
    return self;
}

- (bool)isValid {
    return (self.appId && self.placementId);
}

- (void)commonParamParse:(NSDictionary *)param {
    NSString *appId = [param objectForKey:@"app_id"];
    if ([self isString:appId]) {
        self.appId = [NSString stringWithFormat:@"%@", appId];
    }
    
    NSString *placementId = [param objectForKey:@"placement_id"];
    if ([self isString:placementId]) {
        self.placementId = [NSString stringWithFormat:@"%@", placementId];
    }
}

@end
