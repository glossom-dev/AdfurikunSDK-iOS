//
//  ADFmyAdnetworkConfigure.h
//  ADFMovieReward
//
//  Created by Sungil Kim on 2024/04/10.
//  Copyright © 2024 Glossom, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^completionHandler)(bool result);

@class ADFAdnetworkParam;

@interface ADFmyAdnetworkConfigure : NSObject

@property (nonatomic) ADFAdnetworkParam *param;

+ (instancetype)sharedInstance;

- (void)initAdnetworkSDKWithCompletionHander:(completionHandler)completionHandler;

// Adnetwork SDKに合わせて実装が必要な関数
+ (NSString *)getSDKVersion;
+ (NSString *)adnetworkName;
+ (bool)isSupportForChild;

- (void)setHasUserConsent:(BOOL)hasUserConsent;
- (void)isChildDirected:(BOOL)childDirected;
- (void)soundControl;

- (void)initAdnetworkSDK;

- (void)initFail;
- (void)initSuccess;

-(void)printLogWithParam:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END
