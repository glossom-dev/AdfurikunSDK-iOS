//
//  ADFNativeAdInfo.h
//  ADFMovieReward
//
//  Created by Sungil Kim on 2019/06/26.
//  Copyright © 2019 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADFMediaView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ADFNativeAdType) {
    ADFNativeAdType_Unknown,
    ADFNativeAdType_Movie,
    ADFNativeAdType_Image,
};

/**
 動画ネイティブ広告の情報を格納したオブジェクト
 */
@class ADFmyMovieNativeInterface;
@interface ADFNativeAdInfo : NSObject
@property (nonatomic, weak) ADFmyMovieNativeInterface *adapter;
@property (nonatomic) BOOL isCustomComponentSupported;

/**
 Adnetwork Key
 */
@property (nonatomic, readonly, copy) NSString *adnetworkKey;

/**
  Media Type
 */
@property (nonatomic) ADFNativeAdType mediaType;

/**
 動画ネイティブ広告のタイトル
 */
@property (nonatomic, readonly, copy) NSString *title;

/**
 動画ネイティブ広告の説明文
 */
@property (nonatomic, readonly, copy) NSString *desc;

/**
 インプレッションのトラッキング済みかどうか
 */
@property (atomic, readonly) BOOL hasTrackedImpression;

/**
 動画再生のトラッキング済みかどうか
 */
@property (atomic, readonly) BOOL hasTrackedMovieStart;

/**
 動画終了のトラッキング済みかどうか
 */
@property (atomic, readonly) BOOL hasTrackedMovieFinish;

@property (nonatomic) NSDate *createdTime;

/**
 ネイティブ広告のmediaview
 */
@property (nonatomic, nullable) ADFMediaView* mediaView;
 

- (instancetype)initWithVideoUrl:(NSURL * _Nullable)aVideoUrl
                           title:(NSString *)aTitle
                     description:(NSString *)aDescription
                    adnetworkKey:(NSString *)adnetworkKey;
- (instancetype)init __unavailable;

/**
 インプレッションを計測
 広告（動画・静止画）を表示したら実行してください
 */
- (void)trackImpression;

/**
 動画広告の再生開始を計測
 */
- (void)trackMovieStart;

/**
 動画広告の再生終了を計測
 */
- (void)trackMovieFinish;

/**
 広告のクリックを計測
 ユーザが広告をクリックしたら実行してください
 SafariやAppStoreを起動します
 */
- (void)launchClickTarget;

- (void)setupMediaView:(UIView *)view;
- (void)setupMediaViewWithHtml:(NSDictionary *)htmlData
                 containerView:(UIView *_Nullable)containerView
                     pixelRate:(int)pixelRate
                   displayTime:(int)displayTime
                 timerInterval:(int)timerInterval
             availabilityCheck:(BOOL)availabilityCheck
               checkPixelCount:(int)checkPixelCount
                checkThreshold:(int)checkThreshold
             mediaViewDelegate:(id<ADFMediaViewDelegate>)delegate;
- (void)playMediaView;

// init individual native ad components
-(void)initNativeAdComponents:(UILabel *_Nullable)adTitleLabel
                  adBodyLabel:(UILabel *_Nullable)adBodyLabel
         adSocialContextLabel:(UILabel *_Nullable)adSocialContextLabel
         adCallToActionButton:(UIButton *_Nullable)adCallToActionButton
                adChoicesView:(UIView *_Nullable)adChoicesView
             adMediaView:(UIView *_Nullable)adMediaView
                   adIconView:(UIView *_Nullable)adIconView;

- (void)registerInteractionViews:(nonnull NSArray<__kindof UIView *> *)views;

- (void)unregisterInteractionViews;

// register native ad view for interaction
- (void)registerViewForInteraction:(UIView *)view
                    viewController:(nullable UIViewController *)viewController
                    clickableViews:(nullable NSArray<UIView *> *)clickableViews;


// get native ad components
- (NSDictionary*)getCustomNativeAdComponents;

- (void)setCustomMediaView:(UIView *)view;

- (void)showDebugInformation;

@end
NS_ASSUME_NONNULL_END
