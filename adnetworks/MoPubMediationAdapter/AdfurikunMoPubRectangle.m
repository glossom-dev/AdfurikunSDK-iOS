//
//  AdfurikunMoPubRectangle.m
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "AdfurikunMoPubRectangle.h"
#import <ADFMovieReward/ADFmyRectangle.h>

@interface AdfurikunMoPubRectangle ()
@property (nonatomic, copy)NSString *appId;
@property (nonatomic)ADFmyRectangle *banner;
@property (nonatomic)CGRect adViewRect;
@end

@implementation AdfurikunMoPubRectangle

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    self.adViewRect = CGRectMake(0, 0, 300, 250);
    self.appId = info[@"appid"];
    self.banner = [ADFmyRectangle getInstance:self.appId];
    [self.banner loadAndNotifyTo:self];
    MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], self.appId);
}

@end
