//
//  ADFMovieRewardInterface.h
//
//
//  (c) 2015 ADFULLY Inc.
//
//

#import <Foundation/Foundation.h>

#import "ADFmyBaseAdapterInterface.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSInteger {
    MovieRewardCallbackInit,
    MovieRewardCallbackFetchComplete,
    MovieRewardCallbackPlayStart,
    MovieRewardCallbackPlayComplete,
    MovieRewardCallbackClose,
    MovieRewardCallbackFetchFail,
    MovieRewardCallbackPlayFail,
    MovieRewardCallbackClick, // 9998のみ対応
} MovieRewardCallbackStatus;

typedef enum : NSInteger {
    PlayFailCallbackReasonIsPreparedFalse,
    PlayFailCallbackReasonTopVCGetFailed,
    PlayFailCallbackReasonAdInstanceNil,
    PlayFailCallbackReasonException,
} PlayFailCallbackReason;

@class UIViewController;

@protocol ADFMovieRewardDelegate;

@interface ADFmyMovieRewardInterface : ADFmyBaseAdapterInterface

@property (nonatomic) NSString *objectId;
@property (nonatomic, weak) NSObject<ADFMovieRewardDelegate> *delegate;
@property (nonatomic) bool isRewarded;

/**< 広告の表示 */
-(void)showAd;
-(void)showAdWithPresentingViewController:(UIViewController *)viewController;

- (void)setCallbackStatus:(MovieRewardCallbackStatus)status;

- (void)setPlayFailCallback:(PlayFailCallbackReason)reason exception:(nullable NSException *)exception;

-(void)invalidViewControllerTimer;

-(NSString *)debugDescriptionForCallback;

@end

@protocol ADFMovieRewardDelegate
@optional

/**< 広告の表示準備が終わったか？ */
- (void)AdsFetchCompleted:(ADFmyMovieRewardInterface*)movieReward;
/**< 広告の表示準備が失敗 */
- (void)AdsFetchError:(ADFmyMovieRewardInterface*)movieReward;
/**< 広告の表示が開始したか */
- (void)AdsDidShow:(ADFmyMovieRewardInterface*)movieReward;
/**< 広告の表示を最後まで終わったか */
- (void)AdsDidCompleteShow:(ADFmyMovieRewardInterface*)movieReward;
/**< 広告がバックグラウンドに回ったか */
- (void)AdsDidHide:(ADFmyMovieRewardInterface*)movieReward;
/**< 動画広告再生エラー時のイベント */
- (void)AdsPlayFailed:(ADFmyMovieRewardInterface*)movieReward;
/** 広告がクリックされた(9998のみ対応) */
- (void)AdsDidClick:(ADFmyMovieRewardInterface*)movieReward;
/** VCをチェックして広告が閉じられたと判断 */
- (void)AdsMaybeClosed:(ADFmyMovieRewardInterface*)movieReward;

@end

NS_ASSUME_NONNULL_END
