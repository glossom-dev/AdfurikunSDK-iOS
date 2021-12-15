//
//  ADFmyMovieNativeInterface.h
//  ADFMovieReword
//
//  Created by Toru Furuya on 2017/02/21.
//  (c) 2017 ADFULLY Inc.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ADFMovieError.h"
#import "ADFmyMovieRewardInterface.h"
#import "ADFmyBaseAdapterInterface.h"
#import "ADFNativeAdInfo.h"

typedef enum : NSInteger {
    NativeAdCallbackLoadFinish,
    NativeAdCallbackLoadError,
    NativeAdCallbackRendering,
    NativeAdCallbackPlayStart,
    NativeAdCallbackPlayFinish,
    NativeAdCallbackPlayFail,
    NativeAdCallbackClick,
} NativeAdCallbackStatus;

@class UIViewController;

@protocol ADFMovieNativeDelegate;

@interface ADFmyMovieNativeInterface : ADFmyBaseAdapterInterface

@property (nonatomic, weak) NSObject<ADFMovieNativeDelegate> *delegate;
@property (nonatomic) ADFNativeAdInfo *adInfo;

@property (nonatomic) int viewabilityPixelRate;
@property (nonatomic) int viewabilityDisplayTime;
@property (nonatomic) int viewabilityTimerInterval;

- (void)startViewabilityCheck;

- (void)onImpression;
- (void)onMovieStart;
- (void)onMovieFinish;
- (void)onClick;
- (void)onRendering;
- (void)onRenderingFail;
- (void)onPlayError;
- (void)onReloaded;

- (void)dispose;

- (void)setCustomMediaview:(UIView *)view;

- (void)setCallbackStatus:(NativeAdCallbackStatus)status;

- (void)showDebugInformation;

@end


@class ADFNativeAdInfo;
@protocol ADFMovieNativeDelegate

@required
- (void)onNativeMovieAdImpression:(ADFmyMovieNativeInterface *)adapter;

@optional
- (void)onNativeMovieAdLoadFinish:(ADFNativeAdInfo *)info;
- (void)onNativeMovieAdLoadError:(ADFmyMovieNativeInterface *)adapter;

- (void)onNativeMovieAdPlaybackStart:(ADFmyMovieNativeInterface *)adapter;
- (void)onNativeMovieAdPlaybackFinish:(ADFmyMovieNativeInterface *)adapter;
- (void)onNativeMovieAdPlayError:(ADFmyMovieNativeInterface *)adapter;
- (void)onNativeMovieAdRendering:(ADFmyMovieNativeInterface *)adapter;
- (void)onNativeMovieAdRenderingFail:(ADFmyMovieNativeInterface *)adapter;
- (void)onNativeMovieAdClick:(ADFmyMovieNativeInterface *)adapter;
- (void)onNativeMovieAdReloaded:(ADFmyMovieNativeInterface *)adapter;

@end
