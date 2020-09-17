//
//  ADFEventSender.h
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADFEventSender : NSObject
+ (void)sendApplicationLog:(NSString *)log;
+ (void)sendApplicationLog:(NSString *)log appId:(NSString * _Nullable)appId;
@end

NS_ASSUME_NONNULL_END
