//
//  ADFmyInterstitial.h
//  ADFMovieReward
//
//  Created by Sungil Kim on 2019/07/02.
//  Copyright © 2019 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import "ADFmyMovieReward.h"

NS_ASSUME_NONNULL_BEGIN

@interface ADFmyInterstitial : NSObject<ADFMovieRewardDelegate>

@property (nonatomic, weak) NSObject<ADFmyMovieRewardDelegate> *delegate;

+ (BOOL)isSupportedOSVersion;
/**
 初期化関数。initWithAppIDからRenameされました。
 */
+ (void)initializeWithAppID:(NSString *)appID;
+ (void)initializeWithAppID:(NSString *)appID option:(NSDictionary*)option;
+ (instancetype)getInstance:(NSString *)appID delegate:(id<ADFmyMovieRewardDelegate>)delegate;
+ (void)disposeAll;

-(BOOL)isPrepared;

/**
 *  動画ローディングを開始する。
 *  広告表示準備のためには必ず呼び出してください。load関数を呼び出さないと広告準備ができなくて再生ができなくなります。
 *
 */
-(void)load;

/**
 *  動画ローディングを開始する。
 *  広告表示準備のためには必ず呼び出してください。load関数を呼び出さないと広告準備ができなくて再生ができなくなります。
 
  @param timeout 広告準備完了、失敗Callbackが呼ばれるまでのTimeout。1秒から60秒まで設定可能
 */
-(void)loadWithTimeout:(int)timeout;

-(void)play;
-(void)playWithCustomParam:(NSDictionary*)param;
-(void)playWithPresentingViewController:(UIViewController * _Nullable)viewController;
-(void)playWithPresentingViewController:(UIViewController * _Nullable)viewController customParam:(NSDictionary* _Nullable)param;
-(void)setTrackingId:(NSDictionary*)trackingId;
-(void)dispose;

@end

NS_ASSUME_NONNULL_END
