//
//  ADFmyBaseAdapterInterface.h
//  ADFMovieReward
//
//  Created by Sungil Kim on 2021/01/08.
//  Copyright © 2021 Glossom, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UIViewController;

@interface ADFmyBaseAdapterInterface : NSObject<NSCopying>

@property (nonatomic, weak) NSObject *delegate;

@property (nonatomic) BOOL isAdLoaded;
@property (nonatomic) BOOL isInitialized;
@property (nonatomic) BOOL hasPendedStartAd;

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *adnetworkKey;

@property (nonatomic, strong) NSError *lastError;
@property (nonatomic, strong) NSNumber *hasGdprConsent;

@property (nonatomic) NSDate *lastPlayedTime;

//ADNW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion;
+ (NSString *)getAdapterVersion;
+ (NSString *)getAdapterRevisionVersion;

/**< SDKが読み込まれているかどうか？ */
-(BOOL)isClassReference;

/**< 設定データの送信 */
-(void)setData:(NSDictionary *)data;

/**< Adnetwork SDKを初期化する （Optional） */
-(void)initAdnetworkIfNeeded;
/**< 広告データの初期化 （Optional） */
-(void)clearStatusIfNeeded;
/**< 広告が準備できているか？ */
-(BOOL)isPrepared;
/**< 広告の読み込み開始 */
-(void)startAd;
-(void)startAdWithOption:(nullable NSDictionary *)option;

/** Errorを設定する */
-(void)setErrorWithMessage:(nullable NSString *)description code:(NSInteger)code;
/** 最後のエラーを返す */
-(nullable NSError *)getLastError;

/** EU居住者がEU 一般データ保護規則（GDPR）に同意をしたのかを設定します。 */
-(void)setHasUserConsent:(BOOL)hasUserConsent;

-(UIViewController *)topMostViewController;
-(BOOL)isNotNull:(id)obj;
-(void)adnetworkExceptionHandling:(NSException *)exception;

/** SDK初期化が非同期で行われる場合には下記の関数を使って無視されるStartAdを再開できる*/
-(bool)needsToInit;
-(bool)canStartAd;
-(void)initCompleteAndRetryStartAdIfNeeded;

-(nullable NSString *)getPlayingAdCreativeId;

@end

NS_ASSUME_NONNULL_END
