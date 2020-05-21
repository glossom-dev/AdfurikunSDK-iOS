//
//  ADFAdMobRectangle.m
//
//  Copyright © 2019 Glossom.Inc. All rights reserved.
//

#import "AdfurikunAdMobRectangle.h"

@implementation AdfurikunAdMobRectangle

- (void)requestBannerAd:(GADAdSize)adSize parameter:(NSString *)serverParameter label:(NSString *)serverLabel request:(GADCustomEventRequest *)request {
    [ADFmyRectangle initializeWithAppID:serverParameter];
    self.bannerAd = [ADFmyRectangle getInstance:serverParameter];
    [self.bannerAd loadAndNotifyTo:self];
    self.bannerSize = CGRectMake(0, 0, 300, 250);
}
@end
