//
//  ADFMovieRewardInterface.h
//
//
//  (c) 2015 ADFULLY Inc.
//
//

#import <Foundation/Foundation.h>

#import "ADFmyBaseAdapterInterface.h"

typedef enum : NSInteger {
    MovieRewardCallbackInit,
    MovieRewardCallbackFetchComplete,
    MovieRewardCallbackPlayStart,
    MovieRewardCallbackPlayComplete,
    MovieRewardCallbackClose,
    MovieRewardCallbackFetchFail,
    MovieRewardCallbackPlayFail,
} MovieRewardCallbackStatus;

@class UIViewController;

@protocol ADFMovieRewardDelegate;

@interface ADFmyMovieRewardInterface : ADFmyBaseAdapterInterface

@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, weak) NSObject<ADFMovieRewardDelegate> *delegate;

/**< 広告の表示 */
-(void)showAd;
-(void)showAdWithPresentingViewController:(UIViewController *)viewController;

- (void)setCallbackStatus:(MovieRewardCallbackStatus)status;

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

/** アドネットワーク接続後のイベント(特定のアドネットワーク用) */
- (void)AdsDidConnect:(ADFmyMovieRewardInterface*)movieReward;

@end
