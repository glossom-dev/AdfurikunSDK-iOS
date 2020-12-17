//
//  MovieReward6001.m(UnityAds)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//
#import <UIKit/UIKit.h>
#import "MovieReward6020.h"
#import <ADFMovieReward/ADFMovieOptions.h>

@interface MovieReward6020()

@property (nonatomic, strong) NSString *adUnitId;
@property (nonatomic) MPRewardedVideo *rewardVideoAd;
@property (nonatomic) BOOL hasPendingStartAd;

@end
@implementation MovieReward6020

+(NSString *)getAdapterVersion {
    return @"5.14.1.2";
}

/**
 *  データの設定
 */
-(void)setData:(NSDictionary *)data {
    NSLog(@"mopub: setData");
    [super setData:data];
    
    NSString *adUnitId = [data objectForKey:@"ad_unit_id"];
    if ([self isNotNull:adUnitId]) {
        self.adUnitId = [NSString stringWithFormat:@"%@", adUnitId];
    }
}

-(void)initAdnetworkIfNeeded {
    NSLog(@"mopub: initAdnetworkIfNeeded");
    if (self.adUnitId) {
        @try {
            MPMoPubConfiguration *sdkConfig = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:self.adUnitId];
            [[MoPub sharedInstance] initializeSdkWithConfiguration:sdkConfig completion:^{
                NSLog(@"mopub: SDK has been initted!!!!!");
                if (self.hasPendingStartAd) {
                    self.hasPendingStartAd = false;
                    [self startAd];
                }
            }];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    }
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd {
    if (self.adUnitId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"mopub: startAd");
            if (![MoPub sharedInstance].isSdkInitialized) {
                NSLog(@"mopub: mopub is not initialized");
                self.hasPendingStartAd = YES;
                return;
            }
            @try {
                [MPRewardedVideo setDelegate:self forAdUnitId:self.adUnitId];
                [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:self.adUnitId withMediationSettings:[[NSMutableArray alloc] init]];
            } @catch (NSException *exception) {
                [self adnetworkExceptionHandling:exception];
            }
        });
    }
}

-(BOOL)isPrepared{
    NSLog(@"mopub: isPrepared");
    BOOL isReady =[MPRewardedVideo hasAdAvailableForAdUnitID:self.adUnitId];
    if (isReady){
        return YES;
    }
    return NO;
}

/**
 *  広告の表示を行う
 */
-(void)showAd {
    NSLog(@"mopub: showAd");
    UIViewController *topMostViewController = [self topMostViewController];
    if (topMostViewController) {
        [self showAdWithPresentingViewController: topMostViewController];
    } else {
        NSLog(@"Error encountered playing ad : could not fetch topmost viewcontroller");
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

-(void)showAdWithPresentingViewController:(UIViewController *)viewController {
    NSLog(@"mopub: showAdWithPresentingViewController");
    [super showAdWithPresentingViewController:viewController];
    
    if ([self isPrepared]) {
        if (viewController) {
            @try {
                NSArray *ads = [MPRewardedVideo availableRewardsForAdUnitID:self.adUnitId];
                NSLog(@"mopub: ad count %lu", (unsigned long)ads.count);
                [MPRewardedVideo presentRewardedVideoAdForAdUnitID:self.adUnitId fromViewController:viewController withReward:ads[0]];
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

/**
 * 対象のクラスがあるかどうか？
 */
-(BOOL)isClassReference {
    NSLog(@"MovieReward6020 isClassReference");
    Class clazz = NSClassFromString(@"MoPub");
    if (clazz) {
        NSLog(@"found Class: MoPub");
        return YES;
    }
    else {
        NSLog(@"Not found Class: MoPub");
        return NO;
    }
    return YES;
}

/**
 *  広告の読み込みを中止
 */
-(void)cancel {
// 2.0で廃止  [UnityAds stopAll];
    NSLog(@"mopub: cancel");
}

-(void)dealloc {
//    _gameId = nil;
    NSLog(@"mopub: dealloc");
}

#pragma mark -  MPRewardedVideoDelegate callbacks
// Called when the video for the given adUnitId has loaded. At this point you should be able to call presentRewardedVideoAdForAdUnitID to show the video.
- (void)rewardedVideoAdDidLoadForAdUnitID:(NSString *)adUnitID {
    NSLog(@"mopub: rewardedVideoAdDidLoadForAdUnitID");
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

// Called when a video fails to load for the given adUnitId. The provided error code will provide more insight into the reason for the failure to load.
- (void)rewardedVideoAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error {
    NSLog(@"mopub: rewardedVideoAdDidFailToLoadForAdUnitID");
    NSLog(@"mopub: reward video loading failed \n%@", error);
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

//  Called when there is an error during video playback.
- (void)rewardedVideoAdDidFailToPlayForAdUnitID:(NSString *)adUnitID error:(NSError *)error{
    NSLog(@"mopub: rewardedVideoAdDidFailToPlayForAdUnitID");
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}

// Called when a rewarded video starts playing.
- (void)rewardedVideoAdWillAppearForAdUnitID:(NSString *)adUnitID {
    NSLog(@"mopub: rewardedVideoAdWillAppearForAdUnitID");
}


- (void)rewardedVideoAdDidAppearForAdUnitID:(NSString *)adUnitID {
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
    NSLog(@"mopub: rewardedVideoAdDidAppearForAdUnitID");
} // アルコメント: called when playback started

- (void)rewardedVideoAdWillDisappearForAdUnitID:(NSString *)adUnitID {
    NSLog(@"mopub: rewardedVideoAdWillDisappearForAdUnitID");
}

- (void)rewardedVideoAdDidDisappearForAdUnitID:(NSString *)adUnitID {
    NSLog(@"mopub: rewardedVideoAdDidDisappearForAdUnitID");
    //self.rewardedVideoAd = nil; //アルコメント：set global reward instance to nil for this class
    [self setCallbackStatus:MovieRewardCallbackClose];
} // Called when a rewarded video is closed. At this point your application should resume.

- (void)rewardedVideoAdShouldRewardForAdUnitID:(NSString *)adUnitID reward:(MPRewardedVideoReward *)reward {
    NSLog(@"mopub: rewardedVideoAdShouldRewardForAdUnitID");
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
} // Called when a rewarded video is completed and the user should be rewarded.

- (void)rewardedVideoAdDidExpireForAdUnitID:(NSString *)adUnitID {
    NSLog(@"mopub: rewardedVideoAdDidExpireForAdUnitID");
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
} // Called when a rewarded video is expired.

- (void)rewardedVideoAdDidReceiveTapEventForAdUnitID:(NSString *)adUnitID {
    NSLog(@"mopub: rewardedVideoAdDidReceiveTapEventForAdUnitID");
}

- (void)rewardedVideoAdWillLeaveApplicationForAdUnitID:(NSString *)adUnitID {
    NSLog(@"mopub: rewardedVideoAdWillLeaveApplicationForAdUnitID");
}

@end

