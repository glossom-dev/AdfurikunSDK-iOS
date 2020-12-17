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

+ (NSString *)getSDKVersion {
    return @"7.0.2";
}

- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"NADView");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: NADView");
        return NO;
    }
    return YES;
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

    NSNumber *pixelRateNumber = data[@"pixelRate"];
    if ([self isNotNull:pixelRateNumber] && [pixelRateNumber isKindOfClass:[NSNumber class]]) {
        self.viewabilityPixelRate = pixelRateNumber.intValue;
    }
    NSNumber *displayTimeNumber = data[@"displayTime"];
    if ([self isNotNull:displayTimeNumber] && [displayTimeNumber isKindOfClass:[NSNumber class]]) {
        self.viewabilityDisplayTime = displayTimeNumber.intValue;
    }
    NSNumber *timerIntervalNumber = data[@"timerInterval"];
    if ([self isNotNull:timerIntervalNumber] && [timerIntervalNumber isKindOfClass:[NSNumber class]]) {
        self.viewabilityTimerInterval = timerIntervalNumber.intValue;
    }
}

-(void)initAdnetworkIfNeeded {
    self.adSize = CGSizeMake(320.0, 50.0);
}

- (void)clearStatusIfNeeded {
}

- (BOOL)isPrepared {
    return self.isAdLoaded;
}

- (void)startAd {
    if (self.nendKey == nil) {
        return;
    }
    
    [super startAd];
    
    if (self.adView) {
        self.adView = nil;
    }
    
    self.isAdLoaded = false;
    
    @try {
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

- (void)cancel {
}

// 広告ロードが初めて成功した際に通知されます。(任意)
- (void)nadViewDidFinishLoad:(NADView *)adView {
    NSLog(@"%s", __FUNCTION__);
    self.isAdLoaded = true;
    
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
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector: @selector(onNativeMovieAdLoadFinish:)]) {
            [self.delegate onNativeMovieAdLoadFinish:self.adInfo];
        } else {
            NSLog(@"Banner6009: %s onNativeMovieAdLoadFinish selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"Banner6009: %s Delegate is not setting", __FUNCTION__);
    }
}

// 広告受信が成功した際に通知されます。(任意)
- (void)nadViewDidReceiveAd:(NADView *)adView {
    NSLog(@"%s", __FUNCTION__);
}

// 広告受信に失敗した際に通知されます。(任意)
- (void)nadViewDidFailToReceiveAd:(NADView *)adView {
    NSLog(@"%s", __FUNCTION__);
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadError:)]) {
            [self.delegate onNativeMovieAdLoadError:self];
        } else {
            NSLog(@"Banner6009: selector onNativeMovieAdLoadError is not responding");
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

// 広告バナークリック時に通知されます。(任意)
- (void)nadViewDidClickAd:(NADView *)adView {
    NSLog(@"%s", __FUNCTION__);
    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewClick)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewClick];
        } else {
            NSLog(@"Banner6009: %s onADFMediaViewClick selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"Banner6009: %s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

// インフォメーションボタンクリック時に通知されます。(任意)
- (void)nadViewDidClickInformation:(NADView *)adView {
    NSLog(@"%s", __FUNCTION__);
}

@end

@implementation NativeAdInfo6009

- (void)playMediaView {
    if (self.adapter) {
        if (self.mediaView.adapterInnerDelegate) {
            if ([self.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewRendering)]) {
                [self.mediaView.adapterInnerDelegate onADFMediaViewRendering];
            }
        }
        [self.adapter startViewabilityCheck];
    }
}

@end
