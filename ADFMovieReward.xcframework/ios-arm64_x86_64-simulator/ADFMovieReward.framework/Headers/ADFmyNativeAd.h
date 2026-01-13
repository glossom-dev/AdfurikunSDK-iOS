//
//  ADFmyNativeAd.h
//  ADFMovieReward
//
//  Created by Sungil Kim on 2019/06/19.
//  Copyright © 2019 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADFNativeAdInfo.h"
#import "ADFError.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ADFmyNativeAdDelegate;
/**
 動画ネイティブ広告API
 */
@interface ADFmyNativeAd : NSObject

//- (instancetype)init;

/**
 広告枠の情報をアドフリくんサーバから取得して動画ネイティブ広告の初期化
 configureWithAppIDからRenameされました。

 @param appID 広告枠ID
 */
+ (void)initializeWithAppID:(NSString *)appID;

/**
 広告枠の情報をアドフリくんサーバから取得して動画ネイティブ広告の初期化
 configureWithAppIDからRenameされました。

 @param appID 広告枠ID
 @param option アドフリくんの設定オプション
 */
+ (void)initializeWithAppID:(NSString *)appID option:(NSDictionary *)option;

/**
 動画ネイティブ広告のインスタンスの取得

 @param appID 広告枠ID
 @return 動画ネイティブ広告のインスタンス
 */
+ (instancetype)getInstance:(NSString *)appID;

/**
 動画ネイティブ広告のインスタンスの生成する
 呼び出すたびにInstancesが生成される

 @param appID 広告枠ID
 @return 動画ネイティブ広告のインスタンス
 */
+ (instancetype)createInstance:(NSString *)appID;
+ (instancetype)createInstance:(NSString *)appID option:(NSDictionary *)option;

/**
 iOS 9.0+
 WKWebViewのデータを全て削除する。
 WKWebViewのキャッシュを削除することでアプリの容量を減らすことが出来ます。
 */
+ (void)removeAllWebViewData;


/**
 広告の取得リクエスト
 @param delegate ADFmyMovieNativeDelegateに準拠したデリゲート
 */
- (void)loadAndNotifyTo:(id<ADFmyNativeAdDelegate> _Nullable)delegate;
- (void)loadAndNotifyTo:(id<ADFmyNativeAdDelegate> _Nullable)delegate customParam:(NSDictionary * _Nullable)param;
- (void)loadAndNotifyTo:(id<ADFmyNativeAdDelegate>)delegate customParam:(NSDictionary *)param optiton:(NSDictionary *)option;

- (void)setLoadingTimeout:(float)timeout;

-(void)setTrackingId:(NSDictionary*)trackingId;

- (void)dispose;

@end


@protocol ADFmyNativeAdDelegate <NSObject>
@required

/**
 広告の取得成功

 @param info 動画ネイティブ広告の情報を格納したオブジェクト
 @param appID 対象の広告枠ID
 */
- (void)onNativeAdLoadFinish:(ADFNativeAdInfo *)info appID:(NSString *)appID;

@optional

/**
 広告の取得失敗

 @param error エラーの情報を格納したオブジェクト
 @param appID 対象の広告枠ID
 */
- (void)onNativeAdLoadError:(NSString *)appID adfError:(ADFError *)adfError adnetworkError:(NSArray<AdnetworkError *> *)adnetworkError;
- (void)onNativeAdLoadError:(ADFMovieError *)error appID:(NSString *)appID adnetworkError:(NSArray<AdnetworkError *> *)adnetworkError; __deprecated_msg("Please use 'onNativeAdLoadError:adnetworkError:appID:' instead");
@end

NS_ASSUME_NONNULL_END
