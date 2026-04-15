//
//  AdnetworkParam7500.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2025/12/01.
//  Copyright © 2025 GREE X, Inc. All rights reserved.
//

#import "AdnetworkParam7500.h"

@implementation AdnetworkParam7500

- (instancetype)initWithParam:(NSDictionary *)param {
    self = [super initWithParam:param];
    if (self) {
        self.adxID = [self pangleAdxId];

        NSDictionary *content = [param objectForKey:@"content"];
        if (content && [content isKindOfClass:[NSDictionary class]]) {
            NSDictionary *adValues = [content objectForKey:@"ad_values"];
            if (adValues && [adValues isKindOfClass:[NSDictionary class]]) {
                NSString *adm = [adValues objectForKey:@"adm"];
                if ([self isString:adm]) {
                    self.adm = [NSString stringWithFormat:@"%@", adm];
                }
                [self commonParamParse:adValues];
            }
        }
    }
    return self;
}

- (bool)isValid {
    return (self.appID && self.slotID && self.adm);
}

@end
