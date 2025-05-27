//
//  MovieReward6016.m
//  MovieRewardSampleDev
//
//  Created by Amin Al on 2018/09/05.
//  Copyright © 2018 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import <ADFMovieReward/AdfurikunSdk.h>
#import "MovieReward6016.h"

@interface MovieReward6016()

@property (nonatomic, strong) NSString *placementId;
@property (nonatomic) FBRewardedVideoAd* rewardedVideoAd;
@property (nonatomic) BOOL test_flg;
@property (nonatomic) BOOL isAnimated;

@end

@implementation MovieReward6016

+ (NSString *)getAdapterRevisionVersion {
    return @"10";
}

+ (NSString *)adnetworkClassName {
    return @"FBRewardedVideoAd";
}

+ (NSString *)adnetworkName {
    return @"Facebook Audience Network";
}

- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    NSString *placementId = [data objectForKey:@"placement_id"];
    if ([self isNotNull:placementId]) {
        self.placementId = [NSString stringWithFormat:@"%@", placementId];
    }
    
    NSNumber *isAnimated = [data objectForKey:@"is_animated"];
    if ([self isNotNull:isAnimated] && [isAnimated isKindOfClass:[NSNumber class]]) {
        NSInteger animatedValue = isAnimated.integerValue;
        self.isAnimated = animatedValue == 1 ? YES : NO;
    }
    
    if (AdfurikunSdk.getTestMode) {
        self.test_flg = YES;
    } else {
        NSNumber *testFlg = [data objectForKey:@"test_flg"];
        if ([self isNotNull:testFlg] && [testFlg isKindOfClass:[NSNumber class]]) {
            self.test_flg = [testFlg boolValue];
        }
    }
}

- (bool)initAdnetworkIfNeeded {
    static dispatch_once_t adfFANOnceToken;
    dispatch_once(&adfFANOnceToken, ^{
        @try {
            if (self.test_flg) {
                [FBAdSettings addTestDevice:[FBAdSettings testDeviceHash]];
            } else {
                [FBAdSettings clearTestDevices];
            }
            [self initCompleteAndRetryStartAdIfNeeded];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    });
    return true;
}

- (bool)startAd {
    if (![self canStartAd]) {
        return true;
    }

    if (self.placementId) {
        [super startAd];
        @try {
            self.rewardedVideoAd = [[FBRewardedVideoAd alloc] initWithPlacementID:self.placementId];
            self.rewardedVideoAd.delegate = self;
            [self requireToAsyncRequestAd];
            [self.rewardedVideoAd loadAd];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    }
    return true;
}

- (BOOL)isPrepared {
    return self.delegate && self.rewardedVideoAd && self.rewardedVideoAd.isAdValid;
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
                [self requireToAsyncPlay];
                [self.rewardedVideoAd showAdFromRootViewController:viewController animated:self.isAnimated];
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

#pragma mark - FBRewardedVideoAd delegates
- (void)rewardedVideoAdDidLoad:(FBRewardedVideoAd *)rewardedVideoAd {
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

- (void)rewardedVideoAd:(FBRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    NSLog(@"MovieReward6016: reward video loading failed. error : %@", error);
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

- (void)rewardedVideoAdVideoComplete:(FBRewardedVideoAd *)rewardedVideoAd {
    self.isRewarded = true;
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
}

- (void)rewardedVideoAdDidClose:(FBRewardedVideoAd *)rewardedVideoAd {
    self.rewardedVideoAd = nil;
    [self setCallbackStatus:MovieRewardCallbackClose];
}

- (void)rewardedVideoAdWillLogImpression:(FBRewardedVideoAd *)rewardedVideoAd {
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

@end

@implementation MovieReward6040

@end

@implementation MovieReward6041

@end
