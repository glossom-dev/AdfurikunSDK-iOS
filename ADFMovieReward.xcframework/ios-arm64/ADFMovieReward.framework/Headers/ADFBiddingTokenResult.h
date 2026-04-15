//
//  ADFBiddingTokenResult.h
//  ADFMovieReward
//
//  Created by Ren Fujii on 2026/02/26.
//  Copyright © 2026 GREE X, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADFBiddingTokenResult : NSObject

@property (nonatomic, copy, nullable) NSString *token;
@property (nonatomic, nullable) NSNumber *errorCode;
@property (nonatomic, copy, nullable) NSString *errorMessage;

+ (instancetype)successWithToken:(NSString *)token;
+ (instancetype)failureWithError:(NSError * _Nullable)error;
+ (instancetype)failureWithErrorCode:(NSNumber * _Nullable)errorCode errorMessage:(NSString * _Nullable)errorMessage;

@end

NS_ASSUME_NONNULL_END
