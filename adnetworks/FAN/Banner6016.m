//
//  Banner6016.m
//
//  Created by Ren Fujii on 2019/08/13.
//  Copyright © 2019 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import "Banner6016.h"

@interface Banner6016 ()<FBAdViewDelegate>
@property (nonatomic, strong)NSString *placement_id;
@property (nonatomic, strong)FBAdView *adView;
@property (nonatomic)BOOL impFlag;
@end

@implementation Banner6016
-(void)setData:(NSDictionary *)data {
    NSString *data_placement_id = [data objectForKey:@"placement_id"];
    if (data_placement_id && ![data_placement_id isEqual:[NSNull null]]) {
        self.placement_id = [NSString stringWithFormat:@"%@",data_placement_id];
    }
}

- (BOOL)isPrepared {
    return self.delegate && self.adView && self.adView.isAdValid;
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd {
    self.adView = [[FBAdView alloc] initWithPlacementID:self.placement_id
                                                 adSize:kFBAdSizeHeight50Banner
                                     rootViewController:[self topMostViewController]];
    self.adView.delegate = self;
    [self.adView loadAd];
}

/**
 * 対象のクラスがあるかどうか？
 */
-(BOOL)isClassReference {
    NSLog(@"Banner6016 isClassReference");
    Class clazz = NSClassFromString(@"FBAdView");
    if (clazz) {
        NSLog(@"found Class: FBAdView");
        return YES;
    } else {
        NSLog(@"Not found Class: FBAdView");
        return NO;
    }
}

#pragma mark - FBAdViewDelegate

- (void)adViewDidLoad:(FBAdView *)adView {
    NativeAdInfo6016 *info = [[NativeAdInfo6016 alloc] initWithVideoUrl:nil title:@"" description:@"" adnetworkKey:@"6016"];
    info.adapter = self;
    [info setupMediaView:adView];
    self.adInfo = info;
    if (self.delegate) {
        if ([self.delegate respondsToSelector: @selector(onNativeMovieAdLoadFinish:)]) {
            [self.delegate onNativeMovieAdLoadFinish:self.adInfo];
        } else {
            NSLog(@"Banner6016: %s onNativeMovieAdLoadFinish selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"Banner6016: %s Delegate is not setting", __FUNCTION__);
    }
}

- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error {
    NSLog(@"FAN Banner load error :%@", error);
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadError:)]) {
            if (error) {
                [self setErrorWithMessage:error.localizedDescription code:error.code];
            }
            [self.delegate onNativeMovieAdLoadError:self];
        } else {
            NSLog(@"Banner6016: selector onNativeMovieAdLoadError is not responding");
        }
    } else {
        NSLog(@"Banner6016: delegate is not set");
    }
}

- (void)adViewWillLogImpression:(FBAdView *)adView {
    if (self.impFlag == NO) {
        return;
    }
    self.impFlag = NO;
    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewPlayStart)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewPlayStart];
        } else {
            NSLog(@"Banner6001: %s onADFMediaViewPlayStart selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"Banner6001: %s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

- (void)adViewDidClick:(FBAdView *)adView {
    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewClick)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewClick];
        } else {
            NSLog(@"Banner6016: %s onADFMediaViewClick selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"Banner6016: %s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

- (void)adViewDidFinishHandlingClick:(FBAdView *)adView {
    NSLog(@"%s", __func__);
}

@end

@implementation NativeAdInfo6016
- (void)playMediaView {
    Banner6016 *adapter = (Banner6016 *)self.adapter;
    if (adapter) {
        adapter.impFlag = YES;
    }
}
@end
