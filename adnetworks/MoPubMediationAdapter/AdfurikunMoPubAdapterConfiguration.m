//
//  AdfurikunMoPubAdapterConfiguration.m
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "AdfurikunMoPubAdapterConfiguration.h"
#import <ADFMovieReward/ADFMovieOptions.h>

static NSString *const kAdfurikunAppId = @"appid";

@implementation AdfurikunMoPubAdapterConfiguration

#pragma mark - Caching

+ (void)updateInitializationParameters:(NSDictionary *)parameters {
    NSString *appId = parameters[kAdfurikunAppId];
    if (appId) {
        [AdfurikunMoPubAdapterConfiguration setCachedInitializationParameters:@{kAdfurikunAppId: appId}];
    }
}

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return @"1.0.0.0";
}

- (NSString *)biddingToken {
    return nil;
}

- (NSString *)moPubNetworkName {
    return @"Adfurikun";
}

- (NSString *)networkSdkVersion {
    return [ADFMovieOptions version];
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                                  complete:(void(^)(NSError *))complete {
    complete(nil);
}

@end
