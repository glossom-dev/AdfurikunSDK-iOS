//
//  MovieInterstitial6017.m
//  MovieRewardTestApp
//
//  Created by Ren Fujii on 2019/08/20.
//  Copyright © 2019 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import "MovieInterstitial6017.h"
#import "MovieReward6017.h"
#import <ADFMovieReward/ADFMovieOptions.h>
#import <PAGAdSDK/PAGAdSDK.h>
#import "AdnetworkParam6017.h"

@interface MovieInterstitial6017 ()<PAGLInterstitialAdDelegate>

@property (nonatomic, strong) PAGLInterstitialAd *fullscreenVideoAd;
@property (nonatomic) AdnetworkParam6017 *adParam;

@end

@implementation MovieInterstitial6017

+ (NSString *)getSDKVersion {
    return PAGSdk.SDKVersion;
}

+ (NSString *)getAdapterRevisionVersion {
    return @"13";
}

+ (NSString *)adnetworkClassName {
    return @"PAGLInterstitialAd";
}

-(id)init {
    self = [super init];
    if (self) {
    }
    return self;
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
    if (self.fullscreenVideoAd) {
        self.fullscreenVideoAd = nil;
    }
    @try {
        [self requireToAsyncRequestAd];
        
        PAGInterstitialRequest *request = [PAGInterstitialRequest request];
        [PAGLInterstitialAd loadAdWithSlotID:self.adParam.slotID
                                     request:request
                           completionHandler:^(PAGLInterstitialAd * _Nullable interstitialAd, NSError * _Nullable error) {
            // Load Fail
            if (error) {
                AdapterTraceP(@"error : %@", error);
                [self setErrorWithMessage:error.localizedDescription code:error.code];
                [self setCallbackStatus:MovieRewardCallbackFetchFail];
                return;
            } else if (interstitialAd == nil) {
                NSString *errorMsg = @"interstitialAd is nil";
                AdapterTraceP(@"error : %@", errorMsg);
                [self setErrorWithMessage:errorMsg code:0];
                [self setCallbackStatus:MovieRewardCallbackFetchFail];
                return;
            }
            // Load Success
            AdapterTrace;
            self.fullscreenVideoAd = interstitialAd;
            self.fullscreenVideoAd.delegate = self;
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
    [super showAdWithPresentingViewController:viewController];

    @try {
        [self requireToAsyncPlay];
        
        [self.fullscreenVideoAd presentFromRootViewController:viewController];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

#pragma PAGLInterstitialAdDelegate

- (void)adDidShow:(PAGLInterstitialAd *)ad{
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)adDidClick:(PAGLInterstitialAd *)ad{
    AdapterTrace;
}

- (void)adDidDismiss:(PAGLInterstitialAd *)ad{
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    [self setCallbackStatus:MovieRewardCallbackClose];
}

@end

@implementation MovieInterstitial6090
@end

@implementation MovieInterstitial6091
@end

@implementation MovieInterstitial6092
@end

@implementation MovieInterstitial6093
@end

@implementation MovieInterstitial6094
@end
