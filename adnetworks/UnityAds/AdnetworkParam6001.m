//
//  AdnetworkParam6001.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/04/26.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import "AdnetworkParam6001.h"

@implementation AdnetworkParam6001

- (instancetype)initWithParam:(NSDictionary *)param {
    self = [super initWithParam:param];
    if (self) {
        [self commonParamParse:param];
    }
    return self;
}

- (void)commonParamParse:(NSDictionary *)param {
    NSString *dataGameId = [param objectForKey:@"game_id"];
    if ([self isString:dataGameId]) {
        self.gameId = [NSString stringWithFormat:@"%@", dataGameId];
    }
    NSString *dataPlacementId = [param objectForKey:@"placement_id"];
    if ([self isString:dataPlacementId]) {
        self.placementId = [NSString stringWithFormat:@"%@",dataPlacementId];
    }
}

- (bool)isValid {
    return self.gameId && self.placementId;
}

@end
