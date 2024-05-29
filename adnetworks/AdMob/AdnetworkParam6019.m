//
//  AdnetworkParam6019.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/04/23.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import "AdnetworkParam6019.h"

@implementation AdnetworkParam6019

- (instancetype)initWithParam:(NSDictionary *)param {
    self = [super initWithParam:param];
    if (self) {
        NSString* admobId = [param objectForKey:@"ad_unit_id"];
        if ([self isString:admobId]) {
            self.unitID = [[NSString alloc] initWithFormat:@"%@", admobId];
        }
        
        // NativeAdで使う
        NSString* adChoicesPlacement = [param objectForKey:@"adChoices_placement"];
        if ([self isString:adChoicesPlacement]) {
            self.adChoicesPlacement = [[NSString alloc] initWithFormat:@"%@", adChoicesPlacement];
        }
    }
    return self;
}

- (bool)isValid {
    return (self.unitID != nil);
}

@end
