//
//  ADFMovieOptions.h
//  ADFMovieReward
//
//  Created by Junhua Li on 2017/06/15.
//  Copyright © 2017年 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 アドフリくん動画リワードSDK アプリユーザの性別
 
 - ADFMovieOptions_Gender_Other     : 不明/その他
 - ADFMovieOptions_Gender_Male      : 男性
 - ADFMovieOptions_Gender_Female    : 女性
 */

typedef NS_ENUM(NSInteger, ADFMovieOptions_Gender) {
    ADFMovieOptions_Gender_Other = 0,
    ADFMovieOptions_Gender_Male = 1,
    ADFMovieOptions_Gender_Female = 2,
};

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

@interface ADFMovieOptions : NSObject

/**
*  SDKのバージョンを返却します。
*/
+ (NSString * _Nonnull)version;

/**
 *  アプリユーザの性別を指定します。
 *
 *  @param gender アプリユーザの性別
 */
+ (void)setUserGender:(ADFMovieOptions_Gender)gender;

/**
 *  アプリユーザの性別を返却します。
 *
 *  @return setUserGender:で一番直近指定されたアプリユーザの性別
 */
+ (ADFMovieOptions_Gender)getUserGender;

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
 *  アプリユーザの年齢を指定します。
 *
 *  @param age アプリユーザの年齢
 */
+ (void)setUserAge:(int)age;

/**
 *  アプリユーザの年齢を返却します。
 *
 *  @return setUserAge:で一番直近指定されたアプリユーザの年齢
 */
+ (int)getUserAge;

/**
 *  EU居住者がEU 一般データ保護規則（GDPR）に同意をしたのかを設定します。
 *
 *  @param hasUserConsent 同意をした場合にはTRUEを渡す
 */
+ (void)setHasUserConsent:(BOOL)hasUserConsent;

+ (NSNumber *)getHasUserConsentNumber;

/**
 *  広告をClickした時にアプリ内で遷移するか、外部ブラウザで遷移するかを選択する
 *
 *  @param transitInApp (true : アプリ内で遷移、false : 外部ブラウザで遷移)、Defaultはtrue
 */
+ (void)setTransitInApp:(BOOL)transitInApp;
+ (BOOL)getTransitInApp;

+ (void)enableStartupCache;
+ (BOOL)isEnableStartupCache;

+ (void)disableAdnetworkInfoCacheForDebug;
+ (BOOL)isDisableAdnetworkInfoCacheForDebug;

@end
