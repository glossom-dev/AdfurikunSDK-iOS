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

@class UIViewController;

@protocol ADFMovieNativeDelegate;
@class ADFMovieNativeAdInfo;

@interface ADFmyMovieNativeInterface : NSObject<NSCopying>

@property (nonatomic, weak) NSObject<ADFMovieNativeDelegate> *delegate;
@property (nonatomic) ADFMovieNativeAdInfo *adInfo;
@property (atomic) BOOL isAdLoaded;
@property (nonatomic, strong) NSError *lastError;
@property (nonatomic, strong) NSNumber *hasGdprConsent;

@property (nonatomic) int viewabilityPixelRate;
@property (nonatomic) int viewabilityDisplayTime;
@property (nonatomic) int viewabilityTimerInterval;

- (BOOL)isClassReference;
- (void)setData:(NSDictionary *)data;
- (void)clearStatusIfNeeded;
- (void)initAdnetworkIfNeeded;
- (BOOL)isPrepared;
- (void)startAd;
- (void)startAdWithOption:(NSDictionary *)option;
- (void)cancel;
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

/** Errorを設定する */
-(void)setErrorWithMessage:(NSString *)description code:(NSInteger)code;
/** 最後のエラーを返す */
-(NSError *)getLastError;
/** EU居住者がEU 一般データ保護規則（GDPR）に同意をしたのかを設定します。 */
-(void)setHasUserConsent:(BOOL)hasUserConsent;
-(UIViewController *)topMostViewController;

//課題：ADNW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion;

- (void)setCustomMediaview:(UIView *)view;

- (void)showDebugInformation;

// MovieRewardInterfaceと同じ関数Formatを使う
- (void)setCallbackStatus:(MovieRewardCallbackStatus)status;

- (void)adnetworkExceptionHandling:(NSException *)exception;
- (BOOL)isNotNull:(id)obj;

@end


@class ADFMovieNativeAdInfo;
@protocol ADFMovieNativeDelegate

@required
- (void)onNativeMovieAdImpression:(ADFmyMovieNativeInterface *)adapter;

@optional
- (void)onNativeMovieAdLoadFinish:(ADFMovieNativeAdInfo *)info;
- (void)onNativeMovieAdLoadError:(ADFmyMovieNativeInterface *)adapter;

- (void)onNativeMovieAdPlaybackStart:(ADFmyMovieNativeInterface *)adapter;
- (void)onNativeMovieAdPlaybackFinish:(ADFmyMovieNativeInterface *)adapter;
- (void)onNativeMovieAdPlayError:(ADFmyMovieNativeInterface *)adapter;
- (void)onNativeMovieAdRendering:(ADFmyMovieNativeInterface *)adapter;
- (void)onNativeMovieAdRenderingFail:(ADFmyMovieNativeInterface *)adapter;
- (void)onNativeMovieAdClick:(ADFmyMovieNativeInterface *)adapter;
- (void)onNativeMovieAdReloaded:(ADFmyMovieNativeInterface *)adapter;

@end
