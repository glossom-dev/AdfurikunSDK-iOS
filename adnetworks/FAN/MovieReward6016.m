//
//  MovieReward6016.m
//  MovieRewardSampleDev
//
//  Created by Amin Al on 2018/09/05.
//  Copyright © 2018 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import <ADFMovieReward/ADFMovieOptions.h>
#import "MovieReward6016.h"

@interface MovieReward6016()

@property (nonatomic, strong) NSString *placementId;
@property (nonatomic) FBRewardedVideoAd* rewardedVideoAd;
@property (nonatomic) BOOL test_flg;
@property (nonatomic) BOOL isAnimated;

@end

@implementation MovieReward6016

- (void)setData:(NSDictionary *)data {
    NSString *placementId = [NSString stringWithFormat:@"%@", [data objectForKey:@"placement_id"]];
    if (placementId && ![placementId isEqual:[NSNull null]]) {
        self.placementId = placementId;
        NSInteger animatedValue = [[data valueForKey:@"is_animated"] integerValue];
        self.isAnimated = animatedValue == 1 ? YES : NO;
        if (ADFMovieOptions.getTestMode) {
            self.test_flg = YES;
        } else {
            self.test_flg = [[data objectForKey:@"test_flg"] boolValue];
        }
    }
}

- (void)initAdnetworkIfNeeded {
    static dispatch_once_t adfAdColonyOnceToken;
    dispatch_once(&adfAdColonyOnceToken, ^{
        if (self.test_flg) {
            [FBAdSettings addTestDevice:[FBAdSettings testDeviceHash]];
        } else {
            [FBAdSettings clearTestDevices];
        }
    });
}

- (void)startAd {
    self.rewardedVideoAd = [[FBRewardedVideoAd alloc] initWithPlacementID:self.placementId];
    self.rewardedVideoAd.delegate = self;
    [self.rewardedVideoAd loadAd];
}

-(BOOL)isClassReference {
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_9_0) {
        return NO;
    }

    Class clazz = NSClassFromString(@"FBRewardedVideoAd");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: FBRewardedVideoAd");
        return NO;
    }
    return YES;
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
            [self.rewardedVideoAd showAdFromRootViewController:viewController animated:self.isAnimated];
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
    NSLog(@"MovieReward6016: reward video loading failed \n%@", error);
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

- (void)rewardedVideoAdVideoComplete:(FBRewardedVideoAd *)rewardedVideoAd {
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

