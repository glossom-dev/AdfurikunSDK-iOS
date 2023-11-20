//
//  AppOpenAd6017.m
//  MovieRewardTestApp
//
//  Copyright © 2023 Glossom, Inc. All rights reserved.
//

#import "AppOpenAd6017.h"
#import <PAGAdSDK/PAGAdSDK.h>
#import "MovieReward6017.h"
#import "AdnetworkParam6017.h"

#define kLoadTimeoutDefault 3

@interface AppOpenAd6017 ()<PAGLAppOpenAdDelegate>

@property (nonatomic, strong) PAGLAppOpenAd *openAd;
@property (nonatomic) AdnetworkParam6017 *adParam;

// ロードタイムアウト秒数
@property (nonatomic) NSTimeInterval timeout;

// close済みか判定フラグ（2重実行防止の為）
@property (nonatomic) BOOL didClose;
@end

@implementation AppOpenAd6017

+ (NSString *)getSDKVersion {
    return PAGSdk.SDKVersion;
}

+ (NSString *)getAdapterRevisionVersion {
    return @"8";
}

+ (NSString *)adnetworkClassName {
    return @"PAGLAppOpenAd";
}

+ (NSString *)adnetworkName {
    return @"Pangle";
}

- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6017 alloc] initWithParam:data];
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
                                                 appLogoImage:self.logoImage
                                                   completion:^{
            [self initCompleteAndRetryStartAdIfNeeded];
        }];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (void)startAd {
    [self startAdWithOption:nil];
}

- (void)startAdWithOption:(NSDictionary *)option {
    AdapterTrace;
    if (![self canStartAd]) {
        return;
    }
    if (!self.adParam || ![self.adParam isValid]) {
        return;
    }
    
    if (self.isAdLoaded) {
        AdapterLog(@"Ad is already loaded");
        return;
    }

    self.isAdLoaded = NO;
    if (self.openAd) {
        self.openAd = nil;
    }
    @try {
        [self requireToAsyncRequestAd];
        
        if (option) {
            NSLog(@"custom event option : %@", option);
            NSNumber *timeout = option[@"timeout"];
            if ([self isNotNull:timeout] && [timeout isKindOfClass:[NSNumber class]]) {
                self.timeout = [timeout doubleValue];
            }
        }
        if (self.timeout <= 0) {
            self.timeout = kLoadTimeoutDefault;
        }
        
        PAGAppOpenRequest *request = [PAGAppOpenRequest request];
        [PAGLAppOpenAd loadAdWithSlotID:self.adParam.slotID
                                request:request
                      completionHandler:^(PAGLAppOpenAd * _Nullable appOpenAd, NSError * _Nullable error) {
            AdapterLogP(@"Ad load is completed : %@", appOpenAd);
            if (self.isAdLoaded) {
                AdapterLog(@"Ad is already loaded");
                return;
            }
            if (error) {
                AdapterTraceP(@"error : %@", error);
                [self setErrorWithMessage:error.localizedDescription code:error.code];
                [self setCallbackStatus:MovieRewardCallbackFetchFail];
                return;
            } else if (appOpenAd == nil) {
                NSString *errorMsg = @"appOpenAd is nil";
                AdapterTraceP(@"error : %@", errorMsg);
                [self setErrorWithMessage:errorMsg code:0];
                [self setCallbackStatus:MovieRewardCallbackFetchFail];
                return;
            }
            self.isAdLoaded = YES;
            self.openAd = appOpenAd;
            self.openAd.delegate = self;
            [self setCallbackStatus:MovieRewardCallbackFetchComplete];
        }];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (void)showAd {
    [self showAdWithPresentingViewController:[self topMostViewController]];
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    if (self.openAd) {
        [super showAdWithPresentingViewController:viewController];
        self.didClose = NO;
        
        @try {
            [self requireToAsyncPlay];
            
            [self.openAd presentFromRootViewController:viewController];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
            self.isAdLoaded = NO;
        }
    }
}

- (void)sendAdClose {
    if (self.didClose == NO) {
        self.isAdLoaded = NO;
        self.didClose = YES;
        [self setCallbackStatus:MovieRewardCallbackClose];
    }
}

#pragma mark PAGLAppOpenAdDelegate

- (void)adDidShow:(PAGLAppOpenAd *)ad {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)adDidClick:(PAGLAppOpenAd *)ad {
    AdapterTrace;
}

- (void)adDidDismiss:(PAGLAppOpenAd *)ad {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    [self sendAdClose];
}

@end

@implementation AppOpenAd6090
@end

@implementation AppOpenAd6091
@end

@implementation AppOpenAd6092
@end

@implementation AppOpenAd6093
@end

@implementation AppOpenAd6094
@end
