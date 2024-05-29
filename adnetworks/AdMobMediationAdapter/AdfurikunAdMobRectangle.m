//
//  ADFAdMobRectangle.m
//
//  Copyright © 2019 Glossom.Inc. All rights reserved.
//

#import "AdfurikunAdMobRectangle.h"

@implementation AdfurikunAdMobRectangle

- (ADFmyBanner *)createADFBanner:(NSString *)appId {
    self.bannerSize = CGRectMake(0, 0, 300, 250);
    return [ADFmyRectangle getInstance:appId];
}

@end
