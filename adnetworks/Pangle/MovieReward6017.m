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
#import "AdnetworkParam6017.h"

@interface MovieReward6017 ()<BURewardedVideoAdDelegate>
@property (nonatomic, strong) BURewardedVideoAd *rewardedVideoAd;
@property (nonatomic) AdnetworkParam6017 *adParam;
@end

@implementation MovieReward6017

+ (NSString *)getSDKVersion {
    return BUAdSDKManager.SDKVersion;
}

+ (NSString *)getAdapterRevisionVersion {
    return @"11";
}

- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6017 alloc] initWithParam:data];
}

- (BOOL)isPrepared {
    return self.isAdLoaded;
}

- (void)initAdnetworkIfNeeded {
    if (![self needsToInit]) {
        return;
    }
    if (!self.adParam || ![self.adParam isValid]) {
        return;
    }
    
    @try {
        [self requireToAsyncInit];
        
        [MovieConfigure6017.sharedInstance configureWithAppId:self.adParam.appID gdprStatus:self.hasGdprConsent completion:^{
            [self initCompleteAndRetryStartAdIfNeeded];
        }];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (void)startAd {
    if (![self canStartAd]) {
        return;
    }

    if (!self.adParam || ![self.adParam isValid]) {
        return;
    }
    
    self.isAdLoaded = NO;
    if (self.rewardedVideoAd) {
        self.rewardedVideoAd = nil;
    }
    @try {
        [self requireToAsyncRequestAd];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
            self.rewardedVideoAd = [[BURewardedVideoAd alloc] initWithSlotID:self.adParam.slotID rewardedVideoModel:model];
            self.rewardedVideoAd.delegate = self;
            [self.rewardedVideoAd loadAdData];
        });
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (void)showAd {
    [self showAdWithPresentingViewController:[self topMostViewController]];
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    if (self.rewardedVideoAd) {
        [super showAdWithPresentingViewController:viewController];
        
        @try {
            [self requireToAsyncPlay];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.rewardedVideoAd showAdFromRootViewController:viewController];
            });
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    }
}

- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"BURewardedVideoAd");
    if (clazz) {
        AdapterLog(@"found Class: BURewardedVideoAd");
        return YES;
    } else {
        AdapterLog(@"Not found Class: BURewardedVideoAd");
        return NO;
    }
}

#pragma mark - BURewardedVideoAdDelegate

- (void)rewardedVideoAdDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    AdapterTrace;
}


- (void)rewardedVideoAd:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    AdapterTrace;
    if (error) {
        AdapterTraceP(@"error : %@", error);
        [self setErrorWithMessage:error.localizedDescription code:error.code];
    }
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

- (void)rewardedVideoAdVideoDidLoad:(BURewardedVideoAd *)rewardedVideoAd {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

- (void)rewardedVideoAdWillVisible:(BURewardedVideoAd *)rewardedVideoAd {
    AdapterTrace;
}

- (void)rewardedVideoAdDidVisible:(BURewardedVideoAd *)rewardedVideoAd {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)rewardedVideoAdWillClose:(BURewardedVideoAd *)rewardedVideoAd {
    AdapterTrace;
}

- (void)rewardedVideoAdDidClose:(BURewardedVideoAd *)rewardedVideoAd {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackClose];
}

- (void)rewardedVideoAdDidClick:(BURewardedVideoAd *)rewardedVideoAd {
    AdapterTrace;
}

- (void)rewardedVideoAdDidPlayFinish:(BURewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    AdapterTrace;
    if (error) {
        AdapterTraceP(@"error : %@", error);
        [self setErrorWithMessage:error.localizedDescription code:error.code];
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    } else {
        [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    }
}

- (void)rewardedVideoAdDidClickSkip:(BURewardedVideoAd *)rewardedVideoAd {
    AdapterTrace;
}

@end

@implementation MovieReward6090
@end

@implementation MovieReward6091
@end

@implementation MovieReward6092
@end

@implementation MovieReward6093
@end

@implementation MovieReward6094
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

- (void)configureWithAppId:(NSString *)appId gdprStatus:(NSNumber *)gdprStatus completion:(completionHandlerType)completionHandler {
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
                if (gdprStatus) {
                    configuration.GDPR = gdprStatus;
                    NSLog(@"[ADF] Adnetwork 6017, gdprConsent : %@, sdk setting value : %@", gdprStatus, configuration.GDPR);
                }
                configuration.territory = BUAdSDKTerritory_NO_CN;
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
                NSLog(@"[ADF] adnetwork exception : %@", exception);
            }
        });
    }
}

@end
