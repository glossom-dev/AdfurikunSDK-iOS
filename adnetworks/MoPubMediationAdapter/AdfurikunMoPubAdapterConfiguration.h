//
//  AdfurikunMoPubAdapterConfiguration.h
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MoPubSDK/MoPub.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdfurikunMoPubAdapterConfiguration : MPBaseAdapterConfiguration
@property (nonatomic, copy, readonly) NSString * adapterVersion;
@property (nonatomic, copy, readonly) NSString * biddingToken;
@property (nonatomic, copy, readonly) NSString * moPubNetworkName;
@property (nonatomic, copy, readonly) NSString * networkSdkVersion;

+ (void)updateInitializationParameters:(NSDictionary *)parameters;
- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> * _Nullable)configuration complete:(void(^ _Nullable)(NSError * _Nullable))complete;
@end

NS_ASSUME_NONNULL_END
