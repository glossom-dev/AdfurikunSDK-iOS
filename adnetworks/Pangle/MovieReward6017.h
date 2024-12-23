//
//  MovieReward6017.h
//  MovieRewardTestApp
//
//  Created by Ren Fujii on 2019/08/20.
//  Copyright © 2019 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ADFMovieReward/ADFmyMovieRewardInterface.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^completionHandlerType)(void);

@interface MovieReward6017 : ADFmyMovieRewardInterface

@end

@interface MovieReward6090 : MovieReward6017
@end

@interface MovieReward6091 : MovieReward6017
@end

@interface MovieReward6092 : MovieReward6017
@end

@interface MovieReward6093 : MovieReward6017
@end

@interface MovieReward6094 : MovieReward6017
@end

@interface MovieReward6095 : MovieReward6017
@end

@interface MovieReward6096 : MovieReward6017
@end

@interface MovieReward6097 : MovieReward6017
@end

@interface MovieReward6098 : MovieReward6017
@end

@interface MovieConfigure6017 : NSObject

+ (instancetype)sharedInstance;
- (void)configureWithAppId:(NSString *)appId
                gdprStatus:(NSNumber * _Nullable)gdprStatus
             childDirected:(NSNumber * _Nullable)childDirected
              appLogoImage:(UIImage * _Nullable)logoImage
                completion:(completionHandlerType)completionHandler;

@end

NS_ASSUME_NONNULL_END
