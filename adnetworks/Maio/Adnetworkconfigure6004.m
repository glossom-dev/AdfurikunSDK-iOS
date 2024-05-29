//
//  Adnetworkconfigure6004.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/04/25.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import "Adnetworkconfigure6004.h"

@implementation Adnetworkconfigure6004

// Adnetwork SDK Version
+ (NSString *)getSDKVersion {
    return [MaioVersion.shared toString];
}

// Adnetwork名
+ (NSString *)adnetworkName {
    return @"maio";
}

+ (instancetype)sharedInstance {
    static Adnetworkconfigure6004 *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

@end
