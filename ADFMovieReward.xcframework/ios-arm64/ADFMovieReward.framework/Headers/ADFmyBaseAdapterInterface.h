//
//  ADFmyBaseAdapterInterface.h
//  ADFMovieReward
//
//  Created by Sungil Kim on 2021/01/08.
//  Copyright © 2021 Glossom, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define AdapterTrace [self printLogWithParam:@"Adnetwork Adapter SDK callback [%s L:%d]", __func__, __LINE__];
#define AdapterTraceP(fmt, ...) [self printLogWithParam:@"Adnetwork Adapter SDK callback [%s L:%d] %@", __func__, __LINE__, [NSString stringWithFormat:fmt, __VA_ARGS__]];
#define AdapterLog(str) [self printLogWithParam:@"Adnetwork Adapter Log [%s L:%d] %@", __func__, __LINE__, str];
#define AdapterLogP(fmt, ...) [self printLogWithParam:@"Adnetwork Adapter Log [%s L:%d] %@", __func__, __LINE__, [NSString stringWithFormat:fmt, __VA_ARGS__]];

typedef enum : NSInteger {
    PreloadingStatusInit,                   // 優先読み込みしない
    PreloadingStatusPreloading,             // 優先読み込み開始
    PreloadingStatusPreloadedFetchSuccess,  // 優先読み込みで在庫確保
    PreloadingStatusPreloadedFetchFailed,   // 優先読み込みでLoad Fail
    PreloadingStatusStartAd,                // 通常読み込み開始
} PreloadingStatus;

typedef enum : NSUInteger {
    initAdnetworkNotYet,      // initAdnetworkIfNeeded呼び出し前
    initAdnetworkProcessing,  // initAdnetworkIfNeeded実行中
    initAdnetworkComplete,    // initAdnetworkIfNeeded実行完了
} InitAdnetworkStatus;

@class UIViewController;
@class UIWindow;
@class ADFmyAdnetworkConfigure;

@protocol ADFMovieRewardDelegate;

@interface ADFmyAdapterLogger : NSObject

-(void)printLogWithParam:(NSString *)format, ...;

@end

@interface ADFAdnetworkParam : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithParam:(NSDictionary *)param;
- (bool)isValid;

-(bool)isString:(NSObject *)object;
-(bool)isNumber:(NSObject *)object;
-(bool)isArray:(NSObject *)object;
-(bool)isDictionary:(NSObject *)object;

@end

@interface ADFmyBaseAdapterInterface : ADFmyAdapterLogger<NSCopying>

@property (nonatomic, weak) NSObject *delegate;

@property (nonatomic) InitAdnetworkStatus initAdnetworkStatus;
@property (nonatomic) BOOL isAdLoaded;
@property (nonatomic) BOOL hasPendedStartAd;

@property (nonatomic) int playErrorCheckInterval;
@property (nonatomic) int playErrorCheckCount;
@property (nonatomic) int playErrorSuspendTime;

@property (nonatomic) int playedPointInterval;

@property (nonatomic) NSString *appId;
@property (nonatomic) NSString *adnetworkKey;

@property (nonatomic, strong) NSError *lastError;
@property (nonatomic, strong, nullable) NSNumber *hasGdprConsent;
@property (nonatomic, strong, nullable) NSNumber *childDirected;

@property (nonatomic) NSDate *lastPlayedTime;

@property (nonatomic) BOOL isTopPriorityLoadingAdnetwork;
@property (nonatomic) BOOL isOfflineSupportAdnetwork;

@property (nonatomic) PreloadingStatus preloadingStatus; // 優先読み込みのStatus

@property (nonatomic) ADFmyAdnetworkConfigure *configure;
@property (nonatomic) ADFAdnetworkParam *adParam;

@property (nonatomic, nullable) NSString *creativeId;

//ADNW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion;
+ (NSString *)getAdapterVersion;
+ (NSString *)getAdapterRevisionVersion;

// Adnetworkを実装する際に使うClass名、Adnetwork SDKが入ってるかをチェックする目的
+ (NSString *)adnetworkClassName;

// Adnetwork名を返す
+ (NSString *)adnetworkName;

/** Adnetworkが子供向けのアプリケーションをサポートするかをチェック */
+ (bool)isSupportForChild;

/**< SDKが読み込まれているかどうか？ */
-(BOOL)isClassReference;

/**< 設定データの送信 */
-(void)setData:(NSDictionary *)data;

/**< Adnetwork SDKを初期化する （Optional） */
-(bool)initAdnetworkIfNeeded;
/**< 広告データの初期化 （Optional） */
-(void)clearStatusIfNeeded;
/**< 広告が準備できているか？ */
-(BOOL)isPrepared;
/**< 広告の読み込み開始 */
-(bool)startAd;
-(bool)startAdWithOption:(nullable NSDictionary *)option;

/** Waterfallの順番でStartAdが呼ばれる前にAdnetworkへのRequestを発生させる。下位Adnetworkで先に読み込みだけ実施する場合使う */
-(void)preloadForPriority;

/** Errorを設定する */
-(void)setError:(nullable NSError *)error;
-(void)setErrorWithMessage:(nullable NSString *)description code:(NSInteger)code;
/** 最後のエラーを返す */
-(nullable NSError *)getLastError;

/** EU居住者がEU 一般データ保護規則（GDPR）に同意をしたのかを設定します。 */
-(void)setHasUserConsent:(BOOL)hasUserConsent;

/** COPPA関連の設定を行う。*/
- (void)isChildDirected:(BOOL)childDirected;

-(nullable UIWindow *)getKeyWindow;
-(UIViewController *)topMostViewController;
-(BOOL)isNotNull:(id)obj;
-(void)adnetworkExceptionHandling:(NSException *)exception;

/** SDK初期化が非同期で行われる場合には下記の関数を使って無視されるStartAdを再開できる*/
-(bool)needsToInit;
-(bool)canStartAd;
-(void)initCompleteAndRetryStartAdIfNeeded;

-(nullable NSString *)getPlayingAdCreativeId;

-(void)handlePlayError;
-(void)resetPlayErrorCountIfNeeded;
-(bool)isRequestAdSuspending;
-(void)performLoadFail;
-(BOOL)isPlayErrorCheckMode;

-(void)requireToAsyncInit;
-(void)asyncInitComplete;
-(void)requireToAsyncParameterSet;
-(void)asyncParameterSetComplete;
-(void)requireToAsyncRequestAd;
-(void)asyncRequestAdComplete;
-(void)requireToAsyncPlay;
-(void)asyncPlayComplete;

-(bool)isString:(NSObject *)object;
-(bool)isNumber:(NSObject *)object;
-(bool)isArray:(NSObject *)object;
-(bool)isDictionary:(NSObject *)object;

@end

NS_ASSUME_NONNULL_END
