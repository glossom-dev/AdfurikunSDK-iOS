//
//  MovieReward6017.m
//  MovieRewardTestApp
//
//  Created by Ren Fujii on 2019/08/20.
//  Copyright © 2019 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import "MovieReward6017.h"
#import <ADFMovieReward/ADFMovieOptions.h>
#import <PAGAdSDK/PAGAdSDK.h>
#import "AdnetworkParam6017.h"

@interface MovieReward6017 ()<PAGRewardedAdDelegate>
@property (nonatomic, strong) PAGRewardedAd *rewardedVideoAd;
@property (nonatomic) AdnetworkParam6017 *adParam;
@end

@implementation MovieReward6017

+ (NSString *)getSDKVersion {
    return PAGSdk.SDKVersion;
}

+ (NSString *)getAdapterRevisionVersion {
    return @"15";
}

+ (NSString *)adnetworkClassName {
    return @"PAGRewardedAd";
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
        
        [MovieConfigure6017.sharedInstance configureWithAppId:self.adParam.appID
                                                   gdprStatus:self.hasGdprConsent
                                                childDirected:self.childDirected
                                                 appLogoImage:nil
                                                   completion:^{
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
            PAGRewardedRequest *request = [PAGRewardedRequest request];
            [PAGRewardedAd loadAdWithSlotID:self.adParam.slotID
                                    request:request
                          completionHandler:^(PAGRewardedAd * _Nullable rewardedAd, NSError * _Nullable error) {
                // Load Fail
                if (error) {
                    AdapterTraceP(@"error : %@", error);
                    [self setErrorWithMessage:error.localizedDescription code:error.code];
                    [self setCallbackStatus:MovieRewardCallbackFetchFail];
                    return;
                } else if (rewardedAd == nil) {
                    NSString *errorMsg = @"rewardedAd is nil";
                    AdapterTraceP(@"error : %@", errorMsg);
                    [self setErrorWithMessage:errorMsg code:0];
                    [self setCallbackStatus:MovieRewardCallbackFetchFail];
                    return;
                }

                // Load Success
                AdapterTrace;
                self.rewardedVideoAd = rewardedAd;
                self.rewardedVideoAd.delegate = self;
                [self setCallbackStatus:MovieRewardCallbackFetchComplete];
            }];
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
                [self.rewardedVideoAd presentFromRootViewController:viewController];
            });
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    }
}

#pragma mark - PAGRewardedAdDelegate

- (void)adDidShow:(PAGRewardedAd *)ad {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)adDidClick:(PAGRewardedAd *)ad {
    AdapterTrace;
}

- (void)adDidDismiss:(PAGRewardedAd *)ad {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackClose];
}

- (void)rewardedAd:(PAGRewardedAd *)rewardedAd userDidEarnReward:(PAGRewardModel *)rewardModel {
    AdapterTraceP(@"reward earned! rewardName:%@ rewardMount:%ld",rewardModel.rewardName,(long)rewardModel.rewardAmount);
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
}

- (void)rewardedAd:(PAGRewardedAd *)rewardedAd userEarnRewardFailWithError:(NSError *)error {
    AdapterTraceP(@"reward earned failed. Error:%@",error);
    if (error) {
        AdapterTraceP(@"error : %@", error);
        [self setErrorWithMessage:error.localizedDescription code:error.code];
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
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

- (void)configureWithAppId:(NSString *)appId
                gdprStatus:(NSNumber *)gdprStatus
             childDirected:(NSNumber * _Nullable)childDirected
              appLogoImage:(UIImage * _Nullable)logoImage
                completion:(completionHandlerType)completionHandler {
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
                PAGConfig *configuration = [PAGConfig shareConfig];
                if (gdprStatus) {
                    configuration.GDPRConsent = gdprStatus.boolValue ? PAGGDPRConsentTypeConsent : PAGGDPRConsentTypeNoConsent;
                    NSLog(@"[ADF] Adnetwork 6017, gdprConsent : %@, sdk setting value : %d", gdprStatus, (int)configuration.GDPRConsent);
                }
                if (childDirected) {
                    configuration.childDirected = childDirected.boolValue ? PAGChildDirectedTypeChild : PAGChildDirectedTypeNonChild;
                    NSLog(@"[ADF] Adnetwork 6017, childDirected : %@, sdk setting value : %d", childDirected, (int)configuration.childDirected);
                }
                configuration.debugLog = false;
                configuration.appID = appId;
                if (logoImage) {
                    configuration.appLogoImage = logoImage;
                }
                [PAGSdk startWithConfig:configuration completionHandler:^(BOOL success, NSError * _Nonnull error) {
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
