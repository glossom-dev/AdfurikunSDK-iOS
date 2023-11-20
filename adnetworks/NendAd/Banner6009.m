//
//  Banner6009.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/11/09.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "Banner6009.h"

@interface Banner6009()<NADViewDelegate>

@property (nonatomic) NSString *nendKey;
@property (nonatomic) NSInteger nendAdspotId;
@property (nonatomic) NADView *adView;

@end

@implementation Banner6009

+ (NSString *)getAdapterRevisionVersion {
    return @"7";
}

+ (NSString *)adnetworkClassName {
    return @"NADView";
}

+ (NSString *)adnetworkName {
    return @"nend";
}

- (void)dispose {
    [super dispose];
}

- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    NSString *nendKey = [data objectForKey:@"api_key"];
    if ([self isNotNull:nendKey]) {
        self.nendKey = [NSString stringWithFormat:@"%@", nendKey];
    }
    NSString *spotId = [data objectForKey:@"adspot_id"];
    if ([self isNotNull:spotId] && ([spotId isKindOfClass:[NSString class]] || [spotId isKindOfClass:[NSNumber class]])) {
        self.nendAdspotId = [spotId integerValue];
    }
}

-(void)initAdnetworkIfNeeded {
    self.adSize = CGSizeMake(320.0, 50.0);
    [self initCompleteAndRetryStartAdIfNeeded];
}

- (void)clearStatusIfNeeded {
}

- (BOOL)isPrepared {
    return self.isAdLoaded;
}

- (void)startAd {
    if (![self canStartAd]) {
        return;
    }

    if (self.nendKey == nil) {
        return;
    }
    
    [super startAd];
    
    if (self.adView) {
        self.adView = nil;
    }
    
    @try {
        [self requireToAsyncRequestAd];
        
        self.adView = [[NADView alloc] initWithIsAdjustAdSize:false];
        [self.adView setNendID:self.nendAdspotId apiKey:self.nendKey];
        [self.adView setDelegate:self];
        [self.adView load];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (void)startAdWithOption:(NSDictionary *)option {
    [self startAd];
}

// 広告ロードが初めて成功した際に通知されます。(任意)
- (void)nadViewDidFinishLoad:(NADView *)adView {
    AdapterTrace;
    
    for (UIView *subview in adView.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"NADAdDefaultView")]) {
            [subview setTranslatesAutoresizingMaskIntoConstraints:false];
            [adView addConstraints:@[
                [NSLayoutConstraint constraintWithItem:subview
                                             attribute:NSLayoutAttributeCenterX
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:adView
                                             attribute:NSLayoutAttributeCenterX
                                            multiplier:1.0
                                              constant:0.0],
                [NSLayoutConstraint constraintWithItem:subview
                                             attribute:NSLayoutAttributeCenterY
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:adView
                                             attribute:NSLayoutAttributeCenterY
                                            multiplier:1.0
                                              constant:0.0],
                [NSLayoutConstraint constraintWithItem:subview
                                             attribute:NSLayoutAttributeWidth
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:nil
                                             attribute:NSLayoutAttributeWidth
                                            multiplier:1.0
                                              constant:self.adSize.width],
                [NSLayoutConstraint constraintWithItem:subview
                                             attribute:NSLayoutAttributeHeight
                                             relatedBy:NSLayoutRelationEqual
                                                toItem:nil
                                             attribute:NSLayoutAttributeHeight
                                            multiplier:1.0
                                              constant:self.adSize.height],
            ]];
            break;
        }
    }
    
    NativeAdInfo6009 *info = [[NativeAdInfo6009 alloc] initWithVideoUrl:nil
                                                                  title:@""
                                                            description:@""
                                                           adnetworkKey:@"6009"];
    info.mediaType = ADFNativeAdType_Image;
    info.adapter = self;
    [info setupMediaView:self.adView];
    self.adInfo = info;

    [self setCustomMediaview:self.adView];
    [self.adView pause];
    
    [self setCallbackStatus:NativeAdCallbackLoadFinish];
}

// 広告受信が成功した際に通知されます。(任意)
- (void)nadViewDidReceiveAd:(NADView *)adView {
    AdapterTrace;
}

// 広告受信に失敗した際に通知されます。(任意)
- (void)nadViewDidFailToReceiveAd:(NADView *)adView {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

// 広告バナークリック時に通知されます。(任意)
- (void)nadViewDidClickAd:(NADView *)adView {
    AdapterTrace;
    [self setCallbackStatus:NativeAdCallbackClick];
}

// インフォメーションボタンクリック時に通知されます。(任意)
- (void)nadViewDidClickInformation:(NADView *)adView {
    AdapterTrace;
}

@end

@implementation NativeAdInfo6009

- (void)playMediaView {
    if (self.adapter) {
        [self.adapter setCallbackStatus:NativeAdCallbackRendering];
        [self.adapter startViewabilityCheck];
    }
}

@end

@implementation Banner6080

@end

@implementation Banner6081

@end

@implementation Banner6082

@end
