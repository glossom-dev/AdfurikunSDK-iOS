//
//  MovieNative6009.m
//  MovieRewardSampleDev
//
//  Created by Sungil Kim on 2018/07/12.
//  Copyright © 2018年 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import "MovieNative6009.h"
#import <NendAd/NendAd.h>
#import <ADFMovieReward/ADFMovieOptions.h>

@interface MovieNative6009()<NADNativeVideoDelegate, NADNativeVideoViewDelegate>

@property (nonatomic, strong) NSString *nendKey;
@property (nonatomic) NSInteger nendAdspotId;
@property (nonatomic) BOOL didInit;
@property (nonatomic) NADNativeVideoClickAction clickAction;

@end

@implementation MovieNative6009

+ (NSString *)getAdapterRevisionVersion {
    return @"3";
}

- (BOOL)isClassReference {
    // Nend:iOS 8.1以上が動作保障対象となります。それ以外のOSおよび端末では正常に動作しない場合があります。
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_1) {
        return NO;
    }

    Class clazz = NSClassFromString(@"NADNativeVideoLoader");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: NendAd");
        return NO;
    }
    return YES;
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
    
    self.clickAction = NADNativeVideoClickActionLP;
    NSNumber *clickAction = [data objectForKey:@"click_action"];
    if ([self isNotNull:clickAction] && ([clickAction isKindOfClass:[NSNumber class]] || [clickAction isKindOfClass:[NSString class]])) {
        if (clickAction.integerValue == NADNativeVideoClickActionFullScreen || clickAction.integerValue == NADNativeVideoClickActionLP) {
            self.clickAction = clickAction.integerValue;
        }
    }
}

-(void)initAdnetworkIfNeeded {
    if (!self.didInit && self.nendAdspotId && self.nendKey) {
        @try {
            self.videoAdLoader = [[NADNativeVideoLoader alloc] initWithSpotID:self.nendAdspotId apiKey:self.nendKey clickAction:self.clickAction];
            self.videoAdLoader.mediationName = @"adfurikun";
            // 動画広告のターゲティング
            [self setTargeting];
            
            self.didInit = YES;
            
            [self initCompleteAndRetryStartAdIfNeeded];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    }
}

- (void)startAd {
    if (![self canStartAd]) {
        return;
    }

    [super startAd];
    
    MovieNative6009 __weak *weakSelf = self;
    @try {
        [self.videoAdLoader loadAdWithCompletionHandler:^(NADNativeVideo * _Nullable videoAd, NSError * _Nullable error) {
            if (weakSelf) {
                if (videoAd) {
                    NSLog(@"nend NativeAd Load completed");
                    MovieNativeAdInfo6009 *info = [[MovieNativeAdInfo6009 alloc] initWithVideoUrl:nil
                                                                                            title:videoAd.title
                                                                                      description:videoAd.explanation
                                                                                     adnetworkKey:@"6009"];
                    info.mediaType = ADFNativeAdType_Movie;
                    
                    info.adapter = weakSelf;
                    
                    videoAd.mutedOnFullScreen = true;
                    videoAd.delegate = weakSelf;
                    
                    weakSelf.nativeVideoView = [[NADNativeVideoView alloc] initWithFrame:CGRectZero rootViewController:[self topMostViewController]];
                    weakSelf.nativeVideoView.delegate = weakSelf;
                    weakSelf.nativeVideoView.videoAd = videoAd;
                    [info setupMediaView:weakSelf.nativeVideoView];
                    
                    weakSelf.adInfo = info;
                    weakSelf.isAdLoaded = true;
                    
                    [weakSelf setCallbackStatus:NativeAdCallbackLoadFinish];
                } else {
                    weakSelf.isAdLoaded = false;
                    NSLog(@"nend NativeAd load error : %@", error.localizedDescription);
                    [weakSelf setErrorWithMessage:error.localizedDescription code:error.code];
                    [self setCallbackStatus:NativeAdCallbackLoadError];
                }
            }
        }];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (void)setTargeting {
    @try {
        NADUserFeature *feature = [NADUserFeature new];
        // 年齢
        int age = [ADFMovieOptions getUserAge];
        if (age > 0) {
            feature.age = age;
            self.videoAdLoader.userFeature = feature;
        }
        // 性別
        ADFMovieOptions_Gender gender = [ADFMovieOptions getUserGender];
        if (ADFMovieOptions_Gender_Male == gender) {
            feature.gender = NADGenderMale;
            self.videoAdLoader.userFeature = feature;
        } else if (ADFMovieOptions_Gender_Female == gender) {
            feature.gender = NADGenderFemale;
            self.videoAdLoader.userFeature = feature;
        }
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

-(void)dealloc{
    self.didInit = NO;
    self.adInfo = nil;
    self.nativeVideoView = nil;
    self.videoAdLoader = nil;
}

#pragma mark - NADNativeVideoDelegate
- (void)nadNativeVideoDidImpression:(NADNativeVideo *)ad {
    NSLog(@"%s", __func__);
}

- (void)nadNativeVideoDidClickAd:(NADNativeVideo *)ad {
    NSLog(@"%s", __func__);
    [self setCallbackStatus:NativeAdCallbackClick];
}

- (void)nadNativeVideoDidClickInformation:(NADNativeVideo *)ad {
    NSLog(@"%s", __func__);
}

#pragma mark - NADNativeVideoViewDelegate
- (void)nadNativeVideoViewDidStartPlay:(NADNativeVideoView *)videoView {
    NSLog(@"%s", __func__);
    [self setCallbackStatus:NativeAdCallbackPlayStart];
}

- (void)nadNativeVideoViewDidStartFullScreenPlaying:(NADNativeVideoView *)videoView {
    NSLog(@"%s", __func__);
}

- (void)nadNativeVideoViewDidStopPlay:(NADNativeVideoView *)videoView {
    NSLog(@"%s", __func__);
}

- (void)nadNativeVideoViewDidStopFullScreenPlaying:(NADNativeVideoView *)videoView {
    NSLog(@"%s", __func__);
}

- (void)nadNativeVideoViewDidFailToPlay:(NADNativeVideoView *)videoView {
    NSLog(@"%s", __func__);
    [self setCallbackStatus:NativeAdCallbackPlayFail];
}

- (void)nadNativeVideoViewDidCompletePlay:(NADNativeVideoView *)videoView {
    NSLog(@"%s", __func__);
    [self setCallbackStatus:NativeAdCallbackPlayFinish];
}

- (void)nadNativeVideoViewDidOpenFullScreen:(NADNativeVideoView *)videoView {
    NSLog(@"%s", __func__);
}

- (void)nadNativeVideoViewDidCloseFullScreen:(NADNativeVideoView *)videoView {
    NSLog(@"%s", __func__);
}

@end

@implementation MovieNativeAdInfo6009

- (void)playMediaView {
    NSLog(@"%s", __func__);
}

- (void)registerInteractionViews:(NSArray<__kindof UIView *> *)views {
    MovieNative6009 *native = (MovieNative6009 *)self.adapter;
    if (native && native.nativeVideoView && native.nativeVideoView.videoAd) {
        [native.nativeVideoView.videoAd registerInteractionViews:views];
    }
}

- (void)unregisterInteractionViews {
    MovieNative6009 *native = (MovieNative6009 *)self.adapter;
    if (native && native.nativeVideoView && native.nativeVideoView.videoAd) {
        [native.nativeVideoView.videoAd unregisterInteractionViews];
    }
}

- (void)dealloc {
    [self unregisterInteractionViews];
}

@end

@implementation MovieNative6080

@end

@implementation MovieNative6081

@end

@implementation MovieNative6082

@end
