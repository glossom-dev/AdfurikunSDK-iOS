//
//  ADFDebugUtility.h
//  ADFMovieReward
//
//  Created by Ren Fujii on 2022/12/28.
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADFDebugUtility : NSObject

/**
*  イベント送信を、管理画面の設定によらず強制送信します。
* ※ 本番リリース時は削除して下さい。
*/
+ (void)setForceSendEvent;
+ (BOOL)getForceSendEvent;

/**
* アドネットワークの配信比率を、管理画面の設定によらず上書きします。指定したアドネットワークは配信比率が上書きされ、他のアドネットワークの配信比率は0になります。
* ※ 本番リリース時は削除して下さい。
* 例 : AppLovin(6000)の配信比率を10、UnityAds(6001)の配信比率を20に設置する場合
* [ADFDebugUtility setAdnetworkInformation:@"appId" info:@{@"6000": @10, @"6001": @20}];
*
*  @param appId  枠ID
*  @param info  アドネットワークキーと配信比率。
*/
+ (void)setAdnetworkInformation:(NSString *)appId info:(NSDictionary<NSString *, NSNumber *> *)info;
+ (NSDictionary<NSString *, NSNumber *> * _Nullable)getAdnetworkInformation:(NSString *)appId;

+ (void)forceStop;
+ (BOOL)didForceStop;

@end

NS_ASSUME_NONNULL_END
