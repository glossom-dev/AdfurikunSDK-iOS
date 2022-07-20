//
//  ADFAdMobRectangle.m
//
//  Copyright © 2019 Glossom.Inc. All rights reserved.
//

#import "AdfurikunAdMobRectangle.h"

@implementation AdfurikunAdMobRectangle

- (void)loadBannerForAdConfiguration:(GADMediationBannerAdConfiguration *)adConfiguration
                   completionHandler:(GADMediationBannerLoadCompletionHandler)completionHandler {
    self.closure = completionHandler;
    NSString *adUnit = adConfiguration.credentials.settings[@"parameter"];
    if (adUnit) {
        [ADFmyRectangle initializeWithAppID:adUnit];
        self.bannerAd = [ADFmyRectangle getInstance:adUnit];
        [self.bannerAd loadAndNotifyTo:self];
        self.bannerSize = CGRectMake(0, 0, 300, 250);
    }
}


@end
