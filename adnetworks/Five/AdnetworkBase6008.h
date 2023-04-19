//
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FiveAd/FiveAd.h>
#import <ADFMovieReward/ADFmyMovieRewardInterface.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^completionHandlerType)(void);

@interface AdnetworkBase6008 : ADFmyMovieRewardInterface<FADLoadDelegate, FADAdViewEventListener>

@property (nonatomic)NSString *fiveAppId;
@property (nonatomic)NSString *fiveSlotId;
@property (nonatomic)NSString* submittedPackageName;
@property (nonatomic)BOOL testFlg;
@property (nonatomic)BOOL didRetryForNoCache;

@end

@interface MovieConfigure6008 : NSObject

+ (instancetype)sharedInstance;
- (void)configureWithAppId:(NSString *)fiveAppId isTest:(BOOL)isTest completion:(completionHandlerType)completionHandler;

@end

NS_ASSUME_NONNULL_END
