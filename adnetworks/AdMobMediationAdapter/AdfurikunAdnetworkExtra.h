//
//  AdfurikunAdnetworkExtra.h
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2025/08/12.
//  Copyright © 2025 GREE X, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <GoogleMobileAds/GoogleMobileAds.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdfurikunAdnetworkExtra : NSObject <GADAdNetworkExtras>

/*
 広告読み込みのタイムアウトを設定する
 単位：秒
 */
@property (nonatomic) float loadTimeout;

/*
 Debug Log出力有無の設定値
 */
@property (nonatomic) bool enagleDebugLog;

/*
 GDPR関連設定値。
 EU圏内のユーザの場合のみ設定して、その他の地域の場合にはnilにする
 @0 : EU圏内のユーザが個人情報使用について同意してない
 @1 : EU圏内のユーザが個人情報使用について同意している
 */
@property (nonatomic, nullable) NSNumber *hasUserConsent;

/*
 COPPA関連設定値。
 COPPA対応が必要な場合のみ設定する
 @0 : COPPAの対象外になるため、個人情報を使っての広告再生ができる
 @1 : COPPAに準じて個人情報を使わず広告を流すように設定
 */
@property (nonatomic, nullable) NSNumber *childDirected;

/*
 子供向けのアプリ設定
 true : アプリケーションが子供向けの場合、特定のAdnetworkが動作しないようにする
 */
@property (nonatomic) bool applicationIsForChild;

/*
 再生時に送信する分析用のデータを設定する
 */
@property (nonatomic, nullable) NSDictionary *customParameter;

/*
 動画を再生する時、広告の音を出力設定
 @0 : 再生時にMute状態にする
 @1 : 音が出るようにする
 端末の設定に合わせる場合には何も設定しないでください。
 */
@property (nonatomic, nullable) NSNumber *soundState;

// 内部関数
- (void)adfurikunSDKInitProcessWithTestMode:(bool)testMode;

@end

NS_ASSUME_NONNULL_END
