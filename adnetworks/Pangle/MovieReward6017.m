//
//  MovieReward6017.m
//  MovieRewardTestApp
//
//  Created by Ren Fujii on 2019/08/20.
//  Copyright © 2019 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import "MovieReward6017.h"
#import <ADFMovieReward/ADFMovieOptions.h>
#import <BUAdSDK/BUAdSDK.h>

@interface MovieReward6017 ()<BURewardedVideoAdDelegate>
@property (nonatomic, strong) BURewardedVideoAd *rewardedVideoAd;
@property (nonatomic, strong) NSString *tiktokAppID;
@property (nonatomic, strong) NSString *tiktokSlotID;
@end

@implementation MovieReward6017

+ (NSString *)getSDKVersion {
    return BUAdSDKManager.SDKVersion;
}

+ (NSString *)getAdapterRevisionVersion {
    return @"5";
}

- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    NSString *data_appID = [data objectForKey:@"appid"];
    if ([self isNotNull:data_appID]) {
        self.tiktokAppID = [NSString stringWithFormat:@"%@", data_appID];
    }
    NSString *data_slotID = [data objectForKey:@"ad_slot_id"];
    if ([self isNotNull:data_slotID]) {
        self.tiktokSlotID = [NSString stringWithFormat:@"%@", data_slotID];
    }
}

- (BOOL)isPrepared {
    return self.isAdLoaded;
}

- (void)initAdnetworkIfNeeded {
    if (![self needsToInit]) {
        return;
    }

    if (self.tiktokAppID) {
        @try {
            [MovieConfigure6017.sharedInstance configureWithAppId:self.tiktokAppID completion:^{
                [self initCompleteAndRetryStartAdIfNeeded];
            }];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    }
}

- (void)startAd {
    if (![self canStartAd]) {
        return;
    }

    self.isAdLoaded = NO;
    if (self.rewardedVideoAd) {
        self.rewardedVideoAd = nil;
    }
    if (self.tiktokSlotID) {
        @try {
            BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
            self.rewardedVideoAd = [[BURewardedVideoAd alloc] initWithSlotID:self.tiktokSlotID rewardedVideoModel:model];
            self.rewardedVideoAd.delegate = self;
            [self.rewardedVideoAd loadAdData];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    }
}

- (void)showAd {
    [self showAdWithPresentingViewController:[self topMostViewController]];
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    if (self.rewardedVideoAd) {
        [super showAdWithPresentingViewController:viewController];
        
        @try {
            [self.rewardedVideoAd showAdFromRootViewController:viewController];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
        self.isAdLoaded = NO;
    }
}

- (BOOL)isClassReference {
    NSLog(@"MovieReward6017 isClassReference");
    Class clazz = NSClassFromString(@"BURewardedVideoAd");
    if (clazz) {
        NSLog(@"found Class: BURewardedVideoAd");
        return YES;
    } else {
        NSLog(@"Not found Class: BURewardedVideoAd");
        return NO;
    }
}

#pragma mark - BURewardedVideoAdDelegate

- (void)rewardedVideoAdDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"%s", __func__);
}


- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    if (error) {
        NSLog(@"didFailToLoadAdWithError : %@", error);
        [self setErrorWithMessage:error.localizedDescription code:error.code];
    }
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

- (void)rewardedVideoAdVideoDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    self.isAdLoaded = YES;
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

- (void)rewardedVideoAdWillVisible:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"%s", __func__);
}

- (void)rewardedVideoAdDidVisible:(BURewardedVideoAd *)rewardedVideoAd {
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)rewardedVideoAdWillClose:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"%s", __func__);
}

- (void)rewardedVideoAdDidClose:(BURewardedVideoAd *)rewardedVideoAd {
    [self setCallbackStatus:MovieRewardCallbackClose];
}

- (void)rewardedVideoAdDidClick:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"%s", __func__);
}

- (void)rewardedVideoAdDidPlayFinish:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    if (error) {
        NSLog(@"rewardedVideoAdDidPlayFinishWithError : %@", error);
        [self setErrorWithMessage:error.localizedDescription code:error.code];
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    } else {
        [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    }
}

- (void)rewardedVideoAdDidClickSkip:(BURewardedVideoAd *)rewardedVideoAd {
    NSLog(@"%s", __func__);
}

@end

@implementation MovieReward6090

@end

@implementation MovieReward6091

@end

@implementation MovieReward6092

@end

typedef enum : NSUInteger {
    initializeNotYet,
    initializing,
    initializeComplete,
} PangleInitializeStatus;

@interface MovieConfigure6017()

@property (nonatomic) PangleInitializeStatus initStatus;
@property (nonatomic) NSMutableArray <completionHandlerType> *handlers;

@end

@implementation MovieConfigure6017
+ (instancetype)sharedInstance {
    static MovieConfigure6017 *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.initStatus = initializeNotYet;
        self.handlers = [NSMutableArray new];
    }
    return self;
}

- (void)configureWithAppId:(NSString *)appId completion:(completionHandlerType)completionHandler {
    if (!appId || !completionHandler) {
        return;
    }
    
    if (self.initStatus == initializeComplete) {
        completionHandler();
        return;
    }
    
    if (self.initStatus == initializing) {
        [self.handlers addObject:completionHandler];
        return;
    }
    
    if (self.initStatus == initializeNotYet) {
        self.initStatus = initializing;
        [self.handlers addObject:completionHandler];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @try {

                BUAdSDKConfiguration *configuration = [BUAdSDKConfiguration configuration];
                configuration.territory = BUAdSDKTerritory_NO_CN;
                configuration.coppa = @(0);
                configuration.logLevel = BUAdSDKLogLevelNone;
                //configuration.logLevel = BUAdSDKLogLevelDebug;
                configuration.appID = appId;
                [BUAdSDKManager startWithAsyncCompletionHandler:^(BOOL success, NSError *error) {
                    if (success) {
                        self.initStatus = initializeComplete;

                        for (completionHandlerType handler in self.handlers) {
                            handler();
                        }
                    }
                }];
            } @catch (NSException *exception) {
                NSLog(@"adnetwork exception : %@", exception);
            }
        });
    }
}

@end
