//
//  AdnetworkParameter6001.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/04/26.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import "AdnetworkParameter6001.h"

@implementation AdnetworkParameter6001

- (instancetype)initWithParam:(NSDictionary *)param {
    self = [super initWithParam:param];
    if (self) {
        NSString *dataGameId = [param objectForKey:@"game_id"];
        if ([self isString:dataGameId]) {
            self.gameId = [NSString stringWithFormat:@"%@", dataGameId];
        }
        NSString *dataPlacementId = [param objectForKey:@"placement_id"];
        if ([self isString:dataPlacementId]) {
            self.placementId = [NSString stringWithFormat:@"%@",dataPlacementId];
        }

    }
    return self;
}

- (bool)isValid {
    return self.gameId && self.placementId;
}

@end
