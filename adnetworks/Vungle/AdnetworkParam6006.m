//
//  AdnetworkParam6006.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/02/29.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import "AdnetworkParam6006.h"

@implementation AdnetworkParam6006

- (instancetype)initWithParam:(NSDictionary *)data {
    self = [super initWithParam:data];
    if (self) {
        NSString* vungleAppID = [data objectForKey:@"application_id"];
        if ([self isString:vungleAppID]) {
            self.vungleAppID = [[NSString alloc] initWithFormat:@"%@", vungleAppID];
        }
        NSString *placementID = [data objectForKey:@"placement_reference_id"];
        if ([self isString:placementID]) {
            self.placementID = [NSString stringWithFormat:@"%@", placementID];
        }
        NSArray *placementIDs = [data objectForKey:@"all_placements"];
        if ([self isString:placementIDs] && [placementIDs isKindOfClass:[NSArray class]]) {
            self.allPlacementIDs = [NSArray arrayWithArray:placementIDs];
        }
        if (self.allPlacementIDs.count == 0) {
            self.allPlacementIDs = @[self.placementID];
        }
    }
    return self;
}

- (bool)isValid {
    return (self.vungleAppID && self.placementID);
}

@end
