//
//  ADFmyAppOpenAd.h
//  ADFMovieReward
//
//  Copyright © 2023 Glossom, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ADFMovieError.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ADFmyAppOpenAdDelegate;

@interface ADFmyAppOpenAd : NSObject
/**
 サポートされているOSのバージョンか確認

 @return サポートされているOSのバージョンか否か
 */
+ (BOOL)isSupportedOSVersion;

/**
 初期化関数

 @param appID アドフリくんの広告枠ID
 */
+ (void)initializeWithAppID:(NSString *)appID;
+ (void)initializeWithAppID:(NSString *)appID option:(NSDictionary*)option;

+ (void)initializeWithAppID:(NSString *)appID appLogoImage:(UIImage * __nullable)image;
+ (void)initializeWithAppID:(NSString *)appID appLogoImage:(UIImage * __nullable)image option:(NSDictionary*)option;

/**
 インスタンスを取得

 @param appID アドフリくんの広告枠ID
 @param delegate デリゲート
 @return アプリ起動時広告のインスタンス
 */
+ (ADFmyAppOpenAd *)getInstance:(NSString *)appID delegate:(id<ADFmyAppOpenAdDelegate>)delegate;

/**
 *  動画ローディングを開始する。
 *  広告表示準備のためには必ず呼び出してください。この関数を呼び出さないと広告準備ができなくて再生ができなくなります。
 
  @param timeout 広告準備完了、失敗Callbackが呼ばれるまでのTimeout。1秒から60秒まで設定可能
 */
- (void)loadWithTimeout:(float)timeout;

/**
 *  広告が取得済みかどうか
 *
 *  @return BOOL 広告が取得済みかどうか
 */
- (BOOL)isPrepared;

/**
 *  広告を表示する
 */
- (void)playWithPresentingViewController:(UIViewController *)viewController window:(UIWindow * __nullable)window;

/**
 *  インスタンスを破棄する
 */
- (void)dispose;

@end

@protocol ADFmyAppOpenAdDelegate<NSObject>
@optional
/**< 広告の取得成功 */
- (void)AdsFetchCompleted:(NSString *)appID;
/**< 広告の取得失敗 */
- (void)AdsFetchFailed:(NSString *)appID error:(NSError *)error __deprecated_msg("Please use 'AdsFetchFailed:error:adnetworkError:' instead");
- (void)AdsFetchFailed:(NSString *)appID error:(NSError *)error adnetworkError:(NSArray<AdnetworkError *> *)adnetworkError;
/**< 広告の表示開始 */
- (void)AdsDidShow:(NSString *)appID adNetworkKey:(NSString *)adNetworkKey;
/**< 広告を閉じた */
- (void)AdsDidHide:(NSString *)appID;
/**< 広告の表示失敗 */
- (void)AdsPlayFailed:(NSString *)appID __deprecated_msg("Please use 'AdsPlayFailed:adnetworkError:' instead");
- (void)AdsPlayFailed:(NSString *)appID adnetworkError:(AdnetworkError *)adnetworkError;

@end

NS_ASSUME_NONNULL_END
