//
//  MovieNative6018.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2019/11/06.
//  Copyright © 2019 Glossom, Inc. All rights reserved.
//

#import "MovieNative6018.h"

@interface MovieNative6018()<FADDelegate>
@property (nonatomic, copy) NSString *lineAdsAppId;
@property (nonatomic, copy) NSString *lineAdsSlotId;
@property (nonatomic, copy) NSString* submittedPackageName;
@property (nonatomic) BOOL testFlg;
@property (nonatomic) FADNative *nativeAd;
@end

@implementation MovieNative6018

+ (NSString *)getSDKVersion {
    return FADSettings.version;
}

-(BOOL)isClassReference {
    Class clazz = NSClassFromString(@"FADNative");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: FADNative");
        return NO;
    }
    return YES;
}

- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    NSString *appId = [data objectForKey:@"app_id"];
    if (appId && ![appId isEqual:[NSNull null]]) {
        self.lineAdsAppId = appId;
    }
    NSString *slotId = [data objectForKey:@"slot_id"];
    if (slotId && ![slotId isEqual:[NSNull null]]) {
        self.lineAdsSlotId = slotId;
    }
    NSString *packageName = [data objectForKey:@"package_name"];
    if (packageName && ![packageName isEqual:[NSNull null]]) {
        self.submittedPackageName = packageName;
    }
    NSNumber *testFlg = [data objectForKey:@"test_flg"];
    if (testFlg && ![testFlg isEqual:[NSNull null]]) {
        self.testFlg = [testFlg boolValue];
    }

    NSNumber *pixelRateNumber = data[@"pixelRate"];
    if (pixelRateNumber && ![[NSNull null] isEqual:pixelRateNumber]) {
        self.viewabilityPixelRate = pixelRateNumber.intValue;
    }
    NSNumber *displayTimeNumber = data[@"displayTime"];
    if (displayTimeNumber && ![[NSNull null] isEqual:displayTimeNumber]) {
        self.viewabilityDisplayTime = displayTimeNumber.intValue;
    }
    NSNumber *timerIntervalNumber = data[@"timerInterval"];
    if (timerIntervalNumber && ![[NSNull null] isEqual:timerIntervalNumber]) {
        self.viewabilityTimerInterval = timerIntervalNumber.intValue;
    }
}

- (void)initAdnetworkIfNeeded {
    if (self.lineAdsAppId && self.lineAdsAppId.length > 0) {
        [MovieConfigure6018 configureWithAppId:self.lineAdsAppId isTest:self.testFlg];
    }
}

- (void)startAd {
    [super startAd];

    if (self.lineAdsSlotId) {
        self.nativeAd = [[FADNative alloc] initWithSlotId:self.lineAdsSlotId videoViewWidth:1.0];
        self.nativeAd.delegate = self;

        [self.nativeAd loadAdAsync];
    }
}

- (void)cancel {
}

#pragma mark -  FADDelegate
- (void)fiveAdDidLoad:(id<FADAdInterface>)ad {
    NSLog(@"%s, createType : %@", __func__, ((ad.creativeType == 1) ? @"movie" : @"image"));
    MovieNativeAdInfo6018 *info = [[MovieNativeAdInfo6018 alloc] initWithVideoUrl:nil
                                                                            title:@""
                                                                      description:@""
                                                                     adnetworkKey:@"6018"];
    if (ad.creativeType == kFADCreativeTypeImage) {
        info.mediaType = ADFNativeAdType_Image;
    } else if (ad.creativeType == kFADCreativeTypeMovie) {
        info.mediaType = ADFNativeAdType_Movie;
    }

    info.adapter = self;
    info.nativeAd = ad;
    info.isCustomComponentSupported = true;
    
    [info setupMediaView:[UIView new]];
    self.adInfo = info;
    self.isAdLoaded = YES;

    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadFinish:)]) {
            [self.delegate onNativeMovieAdLoadFinish:self.adInfo];
        }
    }
}

- (void)fiveAd:(id<FADAdInterface>)ad didFailedToReceiveAdWithError:(FADErrorCode)errorCode {
    NSLog(@"%s, error code : %d", __func__, errorCode);
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadError:)]) {
            [self setErrorWithMessage:nil code:errorCode];
            [self.delegate onNativeMovieAdLoadError:self];
        } else {
            NSLog(@"%s onNativeMovieAdLoadError selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

- (void)fiveAdDidClick:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewClick)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewClick];
        } else {
            NSLog(@"%s onADFMediaViewClick selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

- (void)fiveAdDidClose:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
}

- (void)fiveAdDidStart:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);

    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewPlayStart)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewPlayStart];
        } else {
            NSLog(@"%s onADFMediaViewPlayStart selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

- (void)fiveAdDidPause:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
}

- (void)fiveAdDidReplay:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
}

- (void)fiveAdDidResume:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
}

- (void)fiveAdDidViewThrough:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);

    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewPlayFinish)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewPlayFinish];
        } else {
            NSLog(@"%s onADFMediaViewPlayFinish selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

- (void)fiveAdDidStall:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
}

- (void)fiveAdDidRecover:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
}

- (void)fiveAdDidImpressionImage:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewRendering)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewRendering];
        } else {
            NSLog(@"%s onADFMediaViewRendering selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }

    [self startViewabilityCheck];
}

@end

@implementation MovieConfigure6018
+ (void)configureWithAppId:(NSString *)lineAdsAppId isTest:(BOOL)isTest {
    static dispatch_once_t adfLineAdsOnceToken;
    dispatch_once_on_main_thread_five_custom_layout(&adfLineAdsOnceToken, ^{
        FADConfig *config = [[FADConfig alloc] initWithAppId:lineAdsAppId];
        config.fiveAdFormat = [NSSet setWithObjects:
                               [NSNumber numberWithInt:kFADFormatCustomLayout],
                               nil];
        if (isTest) {
            config.isTest =  YES;
        }

        if (![FADSettings isConfigRegistered]) {
            [FADSettings registerConfig:config];
        }
    });
}

void dispatch_once_on_main_thread_five_custom_layout(dispatch_once_t *predicate,
                                                     dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        dispatch_once(predicate, block);
    } else {
        if (DISPATCH_EXPECT(*predicate == 0L, NO)) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                dispatch_once(predicate, block);
            });
        }
    }
}

@end

@implementation MovieNativeAdInfo6018

- (void)playMediaView {
    NSLog(@"%s", __func__);
}

- (NSDictionary *)getCustomNativeAdComponents {
    if (self.nativeAd) {
        return @{
                 @"adInfo": self.nativeAd,
                 @"videoView": [self.nativeAd getAdMainView],
                 @"adTitle": self.nativeAd.getAdTitle,
                 @"descriptionText": self.nativeAd.getDescriptionText,
                 @"advertiserName": self.nativeAd.getAdvertiserName,
                 @"buttonText": self.nativeAd.getButtonText
                };
    }
    return nil;
}

- (void)registerInteractionViews:(NSArray<__kindof UIView *> *)views {
    [self.nativeAd registerViewForInteraction:[self.nativeAd getAdMainView]
                      withInformationIconView:nil
                           withClickableViews:views];
}

@end
