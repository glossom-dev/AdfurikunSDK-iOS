//
//  AdfurikunAdnetworkExtraBuilder.h
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2025/09/25.
//  Copyright © 2025 GREE X, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AdfurikunAdnetworkExtra.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdfurikunAdnetworkExtraBuilderForFlutter : NSObject

@property (nonatomic) NSMutableDictionary *extras;
- (AdfurikunAdnetworkExtra *)getMediationExtras;

@end

NS_ASSUME_NONNULL_END
