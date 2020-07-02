//
//  AdfurikunMoPubNativeAd.m
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "AdfurikunMoPubNativeAd.h"
#import "AdfurikunMoPubNativeAdAdapter.h"
#import <ADFMovieReward/ADFmyNativeAd.h>

@interface AdfurikunMoPubNativeAd () <ADFmyNativeAdDelegate>
@property (nonatomic)ADFmyNativeAd *adfurikunNativeAd;
@property (nonatomic)NSString *appId;
@end

@implementation AdfurikunMoPubNativeAd

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info {
    [self requestAdWithCustomEventInfo:info adMarkup:nil];
}

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    self.appId = info[@"appid"];
    self.adfurikunNativeAd = [ADFmyNativeAd getInstance:self.appId];
    [self.adfurikunNativeAd loadAndNotifyTo:self];
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.appId);
}

#pragma mark - ADFmyNativeAdDelegate

- (void)onNativeAdLoadFinish:(ADFNativeAdInfo *)info appID:(NSString *)appID {
    AdfurikunMoPubNativeAdAdapter *adapter = [[AdfurikunMoPubNativeAdAdapter alloc] initWithAdInfo:info appId:appID];
    MPNativeAd *moPubNativeAd = [[MPNativeAd alloc] initWithAdAdapter:adapter];
    MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], appID);
    [self.delegate nativeCustomEvent:self didLoadAd:moPubNativeAd];
}

- (void)onNativeAdLoadError:(ADFMovieError *)error appID:(NSString *)appID {
    NSError *err = [[NSError alloc] initWithDomain:@"jp.glossom.adfurikun.error" code:error.errorCode userInfo:@{NSLocalizedDescriptionKey: error.errorMessage}];
    MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:err], appID);
    [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:err];
}

@end
