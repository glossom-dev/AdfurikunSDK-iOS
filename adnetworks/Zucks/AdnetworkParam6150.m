//
//  AdnetworkParam6150.m
//
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import "AdnetworkParam6150.h"

@implementation AdnetworkParam6150

- (instancetype)initWithParam:(NSDictionary *)param {
    self = [super initWithParam:param];
    if (self) {
        NSString *frameId = [param objectForKey:@"frame_id"];
        if ([self isString:frameId]) {
            self.frameId = [NSString stringWithFormat:@"%@", frameId];
        }
    }
    return self;
}

- (bool)isValid {
    return self.frameId;
}

@end
