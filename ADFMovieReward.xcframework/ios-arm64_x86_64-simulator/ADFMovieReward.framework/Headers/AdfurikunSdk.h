//
//  AdfurikunSdk.h
//  ADFMovieReward
//
//  Created by Sungil Kim on 2025/03/04.
//  Copyright © 2025 Glossom, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 アドフリくん動画リワードSDK 音出力設定
 
 - AdfurikunSdkSoundDefault     : デフォルト
 - AdfurikunSdkSoundOn      : 出力
 - AdfurikunSdkSoundOff    : 無音
 */

typedef NS_ENUM(NSInteger, AdfurikunSdkSound) {
    AdfurikunSdkSoundDefault = 0,
    AdfurikunSdkSoundOn = 1,
    AdfurikunSdkSoundOff = 2,
};

typedef NS_ENUM(NSInteger, AdfurikunSdkRegion) {
    AdfurikunSdkRegionDeviceSetting = 0,
    AdfurikunSdkRegionJapan = 1,
    AdfurikunSdkRegionForeign = 2,
};

@interface AdfurikunSdk : NSObject

// アプリケーションが子供向けの場合、特定のAdnetworkが動作しないようにする
+ (void)applicationIsForChild;

// アプリケーションの起動情報を集計する
+ (void)logApplicationLaunched:(NSArray <NSString *>*)appIdList userId:(nullable NSString *)userId;

/**
*  SDKのバージョンを返却します。
*/
+ (NSString * _Nonnull)version;

+ (void)setSoundState:(AdfurikunSdkSound)sound;
+ (AdfurikunSdkSound)getSoundState;

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
 * COPPA に基づく子供向けコンテンツとして扱うかを設定
 *
 * @param childDirected 子供向けのコンテンツとして扱う場合にはTrueを渡す
 */
+ (void)isChildDirected:(BOOL)childDirected;
+ (NSNumber * _Nullable)getChildDirected;

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

+ (void)setRegion:(AdfurikunSdkRegion)region;
+ (AdfurikunSdkRegion)getRegion;

@end

NS_ASSUME_NONNULL_END
