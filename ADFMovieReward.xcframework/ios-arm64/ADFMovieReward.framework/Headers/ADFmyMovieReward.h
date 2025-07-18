//
//  ADFmyMovieReward.h
//  ADFMovieReword
//
//  (4.0.2)
//  Created by tsukui on 2016/05/28.
//  (c) 2015 ADFULLY Inc.
//  (ご利用になられる前に、必ずマニュアルにて実装方法をご参照ください。
// マニュアルに記述されている実装のみ利用可能です)

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ADFmyMovieRewardInterface.h"
#import "ADFMovieError.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ADFmyMovieRewardDelegate;

@interface ADFmyMovieReward : NSObject<ADFMovieRewardDelegate>

/** 常に存在するViewController */
//@property (nonatomic, weak) UIViewController *displayViewController;
/** デリゲート */
@property (nonatomic, weak) NSObject<ADFmyMovieRewardDelegate> *delegate;

/**
 サポートされているOSのバージョンか？
 @return BOOL サポートされているOSのバージョンか否か
 */
+ (BOOL)isSupportedOSVersion;
/**
 初期化関数。initWithAppIDからRenameされました。

 @param appID アドフリくんの広告枠ID
 */
+ (void)initializeWithAppID:(NSString *)appID;
/**
 初期化関数。initWithAppIDからRenameされました。

 @param appID アドフリくんの広告枠ID
 @param option アドフリくんの設定オプション
 */
+ (void)initializeWithAppID:(NSString *)appID option:(NSDictionary*)option;

/**
 動画リワードのインスタンスを取得

 @param appID アドフリくんの広告枠ID
 @param delegate デリゲート
 @return 動画リワードのインスタンス
 */
+ (nullable instancetype)getInstance:(NSString *)appID delegate:(id<ADFmyMovieRewardDelegate>)delegate;

/**
 インスタンスの処理
 */
+ (void)disposeAll;

/**
 *  動画ローディングを開始する。
 *  広告表示準備のためには必ず呼び出してください。load関数を呼び出さないと広告準備ができなくて再生ができなくなります。
 *
 */
-(void)load;

/**
 *  動画ローディングを開始する。
 *  広告表示準備のためには必ず呼び出してください。load関数を呼び出さないと広告準備ができなくて再生ができなくなります。
 
  @param timeout 広告準備完了、失敗Callbackが呼ばれるまでのTimeout。0.1秒から60秒まで設定可能
 */
-(void)loadWithTimeout:(float)timeout;

/**
 *  動画が準備完了しているか？
 *
 *  @return BOOL 動画が準備完了しているか否か
 */
-(BOOL)isPrepared;

/**
 *  動画を再生する
 */
-(void)play;
-(void)playWithCustomParam:(nullable NSDictionary*)param;
-(void)playWithPresentingViewController:(nullable UIViewController *)viewController;
-(void)playWithPresentingViewController:(nullable UIViewController *)viewController customParam:(nullable NSDictionary*)param;

-(void)setTrackingId:(NSDictionary*)trackingId;

/**
アプリケーションで広告再生ボタンが表示されたとき、記録を残す
*/
-(void)showAdPlayButton;

/**
アプリケーションでユーザが広告再生ボタンがクリックしたとき、記録を残す
*/
-(void)clickAdPlayButton;

/**
アプリケーションでReward処理を行った後、記録を残す

@param result Rewardが正常に行われたか
@return SDK内部で記録が正常に残されたか
*/
-(BOOL)rewardCompleted:(BOOL)result;

/**
アプリケーションで在庫がなく広告再生ができない状態の記録を残す

@return SDK内部で記録が正常に残されたか
*/
-(BOOL)notReadyAlert;

-(void)dispose;

@end

#define ADF_FETCH_ERROR_CODE_OUTOFSTOCK 203
#define ADF_FETCH_ERROR_CODE_NOADNETWORK 400
#define ADF_FETCH_ERROR_CODE_API_REQUEST_FAILURE 500
#define ADF_FETCH_ERROR_CODE_ALREADY_LOADING 999
#define ADF_FETCH_ERROR_CODE_EXCEED_FREQUENCY 1000 // 以前のエラーコードはHTTP Return Codeとある程度一致したが、当てはまらないケースが出るのでこれからは1000番からナンバーリングをする

@protocol ADFmyMovieRewardDelegate<NSObject>
@optional
/**< 広告の表示準備が終わった時のイベント */
- (void)AdsFetchCompleted:(NSString *)appID isTestMode:(BOOL)isTestMode_inApp;
- (void)AdsFetchCompleted:(NSString *)appID isTestMode:(BOOL)isTestMode_inApp isManualMode:(BOOL)isManualMode;

/**< 広告の表示準備が失敗した時のイベント */
- (void)AdsFetchFailed:(NSString *)appID error:(NSError *)error adnetworkError:(NSArray<AdnetworkError *> *)adnetworkError;

/**< 広告の表示が開始した時のイベント */
- (void)AdsDidShow:(NSString *)appID adnetworkKey:(NSString *)adnetworkKey;

/**< 広告の表示が最後まで終わった時のイベント */
- (void)AdsDidCompleteShow:(NSString *)appID;

/**< 動画広告再生エラー時のイベント */
- (void)AdsPlayFailed:(NSString *)appID adnetworkError:(AdnetworkError *)adnetworkError;

/**< 広告を閉じた時のイベント */
- (void)AdsDidHide:(NSString *)appID isRewarded:(bool)rewarded;

@end

NS_ASSUME_NONNULL_END
