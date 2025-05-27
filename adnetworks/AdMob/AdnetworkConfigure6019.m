//
//  AdnetworkConfigure6019.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2024/04/15.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import "AdnetworkConfigure6019.h"

#import <ADFMovieReward/AdfurikunSdk.h>

#import <GoogleMobileAds/GoogleMobileAds.h>

@implementation AdnetworkConfigure6019

+ (NSString *)adnetworkName {
    return @"AdMob";
}

+ (instancetype)sharedInstance {
    static AdnetworkConfigure6019 *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (void)setHasGdprConsent:(NSNumber *)hasGdprConsent request:(GADRequest *)request {
    if (hasGdprConsent) {
        GADExtras *extras = [[GADExtras alloc] init];
        extras.additionalParameters = @{@"npa": hasGdprConsent.boolValue ? @"1" : @"0"};
        [request registerAdNetworkExtras:extras];
        AdapterLogP(@"gdprConsent : %@, sdk setting value : %@", hasGdprConsent, extras.additionalParameters);
    }
}

- (void)isChildDirected:(BOOL)childDirected {
    AdapterTraceP(@"childDirected : %d", (int)childDirected);
    GADMobileAds.sharedInstance.requestConfiguration.tagForChildDirectedTreatment = [NSNumber numberWithBool:childDirected];
}

- (void)initAdnetworkSDK {
    if ([AdfurikunSdk getTestMode]) {
        AdapterLog(@"Test Mode ON!!!");
        //GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[@"コンソールに出力されたデバイスIDを入力してください。"];
        //詳細　https://developers.google.com/admob/ios/test-ads?hl=ja
    }

    if (!self.param) {
        [self initFail];
        return;
    }
    [self initSuccess];
}

- (void)soundControl {
    AdapterTraceP(@"soundState: %d", (int)[AdfurikunSdk getSoundState]);
    AdfurikunSdkSound soundState = [AdfurikunSdk getSoundState];
    if (AdfurikunSdkSoundOn == soundState) {
        GADMobileAds.sharedInstance.applicationMuted = NO;
    } else if (AdfurikunSdkSoundOff == soundState) {
        GADMobileAds.sharedInstance.applicationMuted = YES;
    }
}

@end
