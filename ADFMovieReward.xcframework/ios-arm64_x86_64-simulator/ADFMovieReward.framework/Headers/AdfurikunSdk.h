//
//  AdfurikunSdk.h
//  ADFMovieReward
//
//  Created by Sungil Kim on 2025/03/04.
//  Copyright © 2025 Glossom, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdfurikunSdk : NSObject

// アプリケーションが子供向けの場合、特定のAdnetworkが動作しないようにする
+ (void)applicationIsForChild;

@end

NS_ASSUME_NONNULL_END
