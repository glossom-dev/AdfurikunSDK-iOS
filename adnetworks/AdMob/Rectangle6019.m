//
//  Rectangle6019.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/02/18.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "Rectangle6019.h"
#import "Banner6019.h"

#import <GoogleMobileAds/GoogleMobileAds.h>

@implementation Rectangle6019

- (void)initAdnetworkIfNeeded {
    if (self.testFlg) {
        // GADMobileAds.sharedInstance.requestConfiguration.testDeviceIdentifiers = @[@"コンソールに出力されたデバイスIDを入力してください。"];
        //詳細　https://developers.google.com/admob/ios/test-ads?hl=ja
    }
    self.adSize = GADAdSizeMediumRectangle;
    [self initCompleteAndRetryStartAdIfNeeded];
}

@end

@implementation Rectangle6060

@end
