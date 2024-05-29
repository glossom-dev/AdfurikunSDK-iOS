//
//  AdnetworkParam6000.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/04/23.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import "AdnetworkParam6000.h"

@implementation AdnetworkParam6000

- (instancetype)initWithParam:(NSDictionary *)param {
    self = [super initWithParam:param];
    if (self) {
        NSString *appLovinSdkKey = [param objectForKey:@"sdkkey"];
        if ([self isString:appLovinSdkKey]) {
            self.appLovinSdkKey = [NSString stringWithFormat:@"%@", appLovinSdkKey];
        }
        
        //申請されたパッケージ名を受け取り
        NSString *submittedPackageName = [param objectForKey:@"package_name"];
        if ([self isString:submittedPackageName]) {
            self.submittedPackageName = [NSString stringWithFormat:@"%@", submittedPackageName];
        }
        
        NSString *zoneIdentifier = [param objectForKey:@"zone_id"];
        if ([self isString:zoneIdentifier]) {
            self.zoneIdentifier = [NSString stringWithFormat:@"%@", zoneIdentifier];
        }

    }
    return self;
}

- (bool)isValid {
    return self.appLovinSdkKey && self.submittedPackageName && self.zoneIdentifier;
}


@end
