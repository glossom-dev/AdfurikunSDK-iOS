//
//  ADFEventSender.h
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ApplicationLog) {
    ApplicationLogShowCMPopup = 0,
    ApplicationLogClickCMPopup = 1,
    ApplicationLogNotReadyAlert = 2,
    ApplicationLogRewardCompleted = 3,
    ApplicationLogRewardError = 4,
    ApplicationLogBeforeShowCMPage = 5,
    ApplicationLogOnShowCMPage = 6
};

@interface ADFEventSender : NSObject
+ (NSString *)getLastSentLog;
+ (void)sendApplicationLog:(NSString *)log;
+ (void)sendApplicationLog:(NSString *)log appId:(NSString * _Nullable)appId;
+ (void)sendApplicationLogWithDefinition:(ApplicationLog)log;
+ (void)sendApplicationLogWithDefinition:(ApplicationLog)log appId:(NSString * _Nullable)appId;
@end

NS_ASSUME_NONNULL_END
