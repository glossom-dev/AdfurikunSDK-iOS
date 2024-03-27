//
//  ADFLogger.h
//  ADFMovieReward
//
//  Created by Amin Al on 2018/06/26.
//  Copyright © 2018 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ADFLogLevel) {
    ADFLogLevelVerbose = 0,
    ADFLogLevelTrace = 1,
    ADFLogLevelDebug = 2,
    ADFLogLevelInfo = 3,
    ADFLogLevelWarning = 4,
    ADFLogLevelError = 5,
    ADFLogLevelInterface = 6,
    ADFLogLevelSevere = 7,
    ADFLogLevelNone = 8
};

@interface ADFLogger : NSObject

@property (class, atomic) ADFLogLevel logLevel;

+ (void)setLogLevel: (ADFLogLevel)level;
+ (NSString *)getLogLevelName:(ADFLogLevel)level;

@end
