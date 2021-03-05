//
//  MovieInterstitial6016.m
//  MovieRewardSampleDev
//
//  Created by Amin Al on 2018/09/14.
//  Copyright © 2018 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MovieInterstitial6016.h"

@interface MovieInterstitial6016()

@property (nonatomic, strong) NSString *placementId;
@property (nonatomic) BOOL test_flg;
@property (nonatomic) FBInterstitialAd* interstitialVideoAd;

@end

@implementation MovieInterstitial6016

+ (NSString *)getAdapterRevisionVersion {
    return @"3";
}

-(id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    NSString *placementId = [data objectForKey:@"placement_id"];
    if ([self isNotNull:placementId]) {
        self.placementId = [NSString stringWithFormat:@"%@", placementId];
    }
    NSNumber *testFlg = [data objectForKey:@"test_flg"];
    if ([self isNotNull:testFlg] && [testFlg isKindOfClass:[NSNumber class]]) {
        self.test_flg = [testFlg boolValue];
    }
}

- (void)initAdnetworkIfNeeded {
    static dispatch_once_t adfFANOnceToken;
    dispatch_once(&adfFANOnceToken, ^{
        @try {
            if (self.test_flg) {
                [FBAdSettings addTestDevice:[FBAdSettings testDeviceHash]];
            } else {
                [FBAdSettings clearTestDevices];
            }
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    });
}

- (void)startAd {
    if (self.placementId) {
        @try {
            self.interstitialVideoAd = [[FBInterstitialAd alloc] initWithPlacementID:self.placementId];
            self.interstitialVideoAd.delegate = self;
            [self.interstitialVideoAd loadAd];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    }
}

-(BOOL)isClassReference {
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_9_0) {
        return NO;
    }

    Class clazz = NSClassFromString(@"FBInterstitialAd");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: FBInterstitialAd");
        return NO;
    }
    return YES;
}

- (BOOL)isPrepared {
    if (self.delegate && self.interstitialVideoAd && self.interstitialVideoAd.isAdValid) {
        return YES;
    } else {
        return NO;
    }
}


-(void)showAd {
    UIViewController *topMostViewController = [self topMostViewController];
    if (topMostViewController) {
        [self showAdWithPresentingViewController: topMostViewController];
    } else {
        NSLog(@"Error encountered playing ad : could not fetch topmost viewcontroller");
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

-(void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAdWithPresentingViewController:viewController];

    if ([self isPrepared]) {
        if (viewController) {
            @try {
                [self.interstitialVideoAd showAdFromRootViewController:viewController];
            } @catch (NSException *exception) {
                [self adnetworkExceptionHandling:exception];
                [self setCallbackStatus:MovieRewardCallbackPlayFail];
            }
        } else {
            NSLog(@"Error encountered playing ad : viewController cannot be nil");
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    }
}

#pragma mark - FBInterstitialAd delegates
- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd {
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    NSLog(@"MovieInterstitial6016: interstitial video loading failed \n%@", error);
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd {
    self.interstitialVideoAd = nil;
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    [self setCallbackStatus:MovieRewardCallbackClose];
}

- (void)interstitialAdWillLogImpression:(FBInterstitialAd *)interstitialAd {
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

@end

@implementation MovieInterstitial6040

@end

@implementation MovieInterstitial6041

@end
