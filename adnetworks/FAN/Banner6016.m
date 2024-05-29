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

+ (NSString *)getAdapterRevisionVersion {
    return @"6";
}

+ (NSString *)adnetworkClassName {
    return @"FBAdView";
}

+ (NSString *)adnetworkName {
    return @"Facebook Audience Network";
}

-(void)setData:(NSDictionary *)data {
    [super setData:data];
    
    NSString *data_placement_id = [data objectForKey:@"placement_id"];
    if ([self isNotNull:data_placement_id]) {
        self.placement_id = [NSString stringWithFormat:@"%@",data_placement_id];
    }
}

- (BOOL)isPrepared {
    return self.delegate && self.adView && self.adView.isAdValid;
}

/**
 *  広告の読み込みを開始する
 */
-(bool)startAd {
    if (![self canStartAd]) {
        return true;
    }

    if (self.placement_id) {
        @try {
            [super startAd];
            
            self.adView = [[FBAdView alloc] initWithPlacementID:self.placement_id
                                                         adSize:kFBAdSizeHeight50Banner
                                             rootViewController:[self topMostViewController]];
            self.adView.delegate = self;
            [self requireToAsyncRequestAd];
            [self.adView loadAd];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    }
    return true;
}

#pragma mark - FBAdViewDelegate

- (void)adViewDidLoad:(FBAdView *)adView {
    NativeAdInfo6016 *info = [[NativeAdInfo6016 alloc] initWithVideoUrl:nil
                                                                  title:@""
                                                            description:@""
                                                           adnetworkKey:@"6016"];
    info.mediaType = ADFNativeAdType_Image;
    info.adapter = self;
    [info setupMediaView:adView];
    self.adInfo = info;
    [self setCallbackStatus:NativeAdCallbackLoadFinish];
}

- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error {
    NSLog(@"FAN Banner load error :%@", error);
    if (error) {
        [self setErrorWithMessage:error.localizedDescription code:error.code];
    }
    [self setCallbackStatus:NativeAdCallbackLoadError];
}

- (void)adViewWillLogImpression:(FBAdView *)adView {
    if (self.impFlag == NO) {
        return;
    }
    self.impFlag = NO;

    [self setCustomMediaview:adView];
    [self startViewabilityCheck];

    [self setCallbackStatus:NativeAdCallbackRendering];
}

- (void)adViewDidClick:(FBAdView *)adView {
    [self setCallbackStatus:NativeAdCallbackClick];
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

@implementation Banner6040

@end

@implementation Banner6041

@end
