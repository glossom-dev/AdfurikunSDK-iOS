//
//  ADFMovieOptions.h
//  ADFMovieReward
//
//  Created by Junhua Li on 2017/06/15.
//  Copyright © 2017年 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 アドフリくん動画リワードSDK 音出力設定
 
 - ADFMovieOptions_Sound_Default     : デフォルト
 - ADFMovieOptions_Sound_On      : 出力
 - ADFMovieOptions_Sound_Off    : 無音
 */

typedef NS_ENUM(NSInteger, ADFMovieOptions_Sound) {
    ADFMovieOptions_Sound_Default = 0,
    ADFMovieOptions_Sound_On = 1,
    ADFMovieOptions_Sound_Off = 2,
};

typedef NS_ENUM(NSInteger, ADFMovieOptionsRegion) {
    ADFMovieOptionsRegionDeviceSetting = 0,
    ADFMovieOptionsRegionJapan = 1,
    ADFMovieOptionsRegionForeign = 2,
};

@interface ADFMovieOptions : NSObject

/**
*  SDKのバージョンを返却します。
*/
+ (NSString * _Nonnull)version;

+ (void)setSoundState:(ADFMovieOptions_Sound)sound;
+ (ADFMovieOptions_Sound)getSoundState;

/**
*  テスト広告の配信を指定出来ます。
*
*  @param testMode  trueでテストモード、falseで本番モード
*/
+ (void)setTestMode:(BOOL)testMode;
+ (BOOL)getTestMode;

/**
 *  EU居住者がEU 一般データ保護規則（GDPR）に同意をしたのかを設定します。
 *
 *  @param hasUserConsent 同意をした場合にはTRUEを渡す
 */
+ (void)setHasUserConsent:(BOOL)hasUserConsent;

+ (NSNumber * _Nonnull)getHasUserConsentNumber;

/**
 *  広告をClickした時にアプリ内で遷移するか、外部ブラウザで遷移するかを選択する
 *
 *  @param transitInApp (true : アプリ内で遷移、false : 外部ブラウザで遷移)、Defaultはtrue
 */
+ (void)setTransitInApp:(BOOL)transitInApp;
+ (BOOL)getTransitInApp;

/**
 *  配信情報が有効期限以内の場合、アプリ起動時に配信情報のCacheデータを使うようにする
 *
 */
+ (void)enableStartupCache;
+ (BOOL)isEnableStartupCache;

/**
 *  配信情報が有効期限内でもLoadする度に必ず配信情報を取得する
 *  検証目的以外には使わないでください。
 *
 */
+ (void)disableAdnetworkInfoCacheForDebug;
+ (BOOL)isDisableAdnetworkInfoCacheForDebug;

/**
 *  配信情報の有効期限が切れても必ず配信情報のCacheを使うようにする
 *
 *  @param appIdList : 枠IDリスト
 */
+ (void)setAppIdsForStartupCacheRegardlessOfExpiring:( NSArray <NSString *>* _Nonnull)appIdList;
+ (NSArray <NSString *>* _Nullable)getAppIdsForStartupCacheRegardlessOfExpiring;

+ (void)setRegion:(ADFMovieOptionsRegion)region;
+ (ADFMovieOptionsRegion)getRegion;

@end
