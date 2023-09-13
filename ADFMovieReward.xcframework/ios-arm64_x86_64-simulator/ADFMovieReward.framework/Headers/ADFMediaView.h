//
//  ADFMediaView.h
//  ADFMovieReward
//
//  Created by Junhua Li on 2018/06/22.
//  Copyright © 2018年 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class WKWebView;

@protocol ADFMediaViewDelegate <NSObject>
@optional
/**
 広告の再生開始
 */
- (void)onADFMediaViewPlayStart;

/**
 広告の再生完了
 */
- (void)onADFMediaViewPlayFinish;

/**
 広告の再生失敗
 */
- (void)onADFMediaViewPlayFail;

/**
 広告のClick
 */
- (void)onADFMediaViewClick;

- (void)onADFMediaViewLoadFinish;
- (void)onADFMediaViewLoadFail;
- (void)onADFMediaViewRendering;
- (void)onADFMediaViewRenderingFail;
- (void)onADFMediaViewReloaded;

@end

@interface ADFMediaView : UIView
@property (nonatomic, nullable, weak) id <ADFMediaViewDelegate> mediaViewDelegate;
@property (nonatomic, nullable, weak) id <ADFMediaViewDelegate> adapterInnerDelegate;

- (void)setupWithView:(UIView * _Nonnull)view;
- (void)setupWithHtml:(NSDictionary * _Nonnull)htmlData
              bgColor:(NSString * _Nullable)bgColor
            pixelRate:(int)pixelRate
          displayTime:(int)displayTime
        timerInterval:(int)timerInterval
    availabilityCheck:(BOOL)availabilityCheck
      checkPixelCount:(int)checkPixelCount
       checkThreshold:(int)checkThreshold;

- (void)play;


@end
