//
//  AdfurikunMoPubInterstitial.m
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "AdfurikunMoPubInterstitial.h"
#import <ADFMovieReward/ADFmyInterstitial.h>

@interface AdfurikunMoPubInterstitial ()<ADFmyMovieRewardDelegate>
@property (nonatomic, copy)NSString *appId;
@property (nonatomic)ADFmyInterstitial *reward;
@end

@implementation AdfurikunMoPubInterstitial

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    self.appId = info[@"appid"];
    self.reward = [ADFmyInterstitial getInstance:self.appId delegate:self];
    [self.reward load];
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.appId);
}

- (BOOL)isRewardExpected {
    return NO;
}

@end
