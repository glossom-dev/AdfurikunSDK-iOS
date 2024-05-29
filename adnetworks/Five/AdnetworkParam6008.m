//
//  AdnetworkParam6008.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/04/24.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import "AdnetworkParam6008.h"

@implementation AdnetworkParam6008

- (instancetype)initWithParam:(NSDictionary *)param {
    self = [super initWithParam:param];
    if (self) {
        NSString *fiveAppId = [param objectForKey:@"app_id"];
        if ([self isString:fiveAppId]) {
            self.fiveAppId = [NSString stringWithFormat:@"%@", fiveAppId];
        }
        NSString *fiveSlotId = [param objectForKey:@"slot_id"];
        if ([self isString:fiveSlotId]) {
            self.fiveSlotId = [NSString stringWithFormat:@"%@", fiveSlotId];
        }
        NSString *submittedPackageName = [param objectForKey:@"package_name"];
        if ([self isString:submittedPackageName]) {
            self.submittedPackageName = [NSString stringWithFormat:@"%@", submittedPackageName];
        }
    }
    return self;
}

- (bool)isValid {
    return self.fiveAppId && self.fiveSlotId && self.submittedPackageName;
}

@end
