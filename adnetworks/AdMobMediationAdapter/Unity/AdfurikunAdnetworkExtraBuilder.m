//
//  AdfurikunAdnetworkExtraBuilder.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2025/09/25.
//  Copyright © 2025 GREE X, Inc. All rights reserved.
//

#import "AdfurikunAdnetworkExtraBuilder.h"
#import "AdfurikunAdnetworkExtra.h"

@implementation AdfurikunAdnetworkExtraBuilder

- (nonnull id<GADAdNetworkExtras>)adNetworkExtrasWithDictionary:(nonnull NSDictionary<NSString *, NSString *> *)extras {
    AdfurikunAdnetworkExtra *extra = [[AdfurikunAdnetworkExtra alloc] init];
    
    NSString *value;
    
    value = extras[@"ADF_IS_DEBUG_MODE"];
    if (value) {
        extra.enableDebugLog = value.boolValue;
    }

    value = extras[@"ADF_SOUND_STATE"];
    if (value) {
        extra.soundState = (value.boolValue) ? @1 : @0;
    }

    value = extras[@"ADF_HAS_USER_CONSENT"];
    if (value) {
        extra.hasUserConsent = (value.boolValue) ? @1 : @0;
    }

    value = extras[@"ADF_IS_CHILD_DIRECTED"];
    if (value) {
        extra.childDirected = (value.boolValue) ? @1 : @0;
    }

    value = extras[@"ADF_USER_IS_MINOR"];
    if (value) {
        extra.setUserIsMinor = value.boolValue;
    }

    value = extras[@"ADF_CUSTOM_PARAMS"];
    if (value) {
        // NSString → NSData
        NSData *jsonData = [value dataUsingEncoding:NSUTF8StringEncoding];

        // NSData → NSDictionary
        NSError *error;
        NSDictionary *customParam = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                    options:0
                                                                      error:&error];

        if (!error) {
            extra.customParameter = [NSDictionary dictionaryWithDictionary:customParam];
        }
    }

    value = extras[@"ADF_LOAD_TIMEOUT"];
    if (value) {
        extra.loadTimeout = value.floatValue;
    }

    return extra;
}

@end
