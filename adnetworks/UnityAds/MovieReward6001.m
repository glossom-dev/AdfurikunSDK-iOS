//
//  MovieReward6001.m(UnityAds)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//
#import <UIKit/UIKit.h>
#import "MovieReward6001.h"
#import <ADFMovieReward/ADFMovieOptions.h>

@interface MovieReward6001()
@property (nonatomic, strong) NSString *gameId;
@property (nonatomic, strong) NSString *placementId;
@property (nonatomic) BOOL testFlg;
@end

@implementation MovieReward6001

//課題：ANDW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion {
    return UnityAds.getVersion;
}

+ (NSString *)getAdapterRevisionVersion {
    return @"7";
}

-(void)dealloc {
    _gameId = nil;
    _placementId = nil;
}

/**
 *  データの設定
 */
-(void)setData:(NSDictionary *)data {
    [super setData:data];
    
    if (ADFMovieOptions.getTestMode) {
        self.testFlg = YES;
    } else {
        NSNumber *testFlg = [data objectForKey:@"test_flg"];
        if ([self isNotNull:testFlg] && [testFlg isKindOfClass:[NSNumber class]]) {
            self.testFlg = [testFlg boolValue];
        }
    }

    NSString *dataGameId = [data objectForKey:@"game_id"];
    if ([self isNotNull:dataGameId]) {
        self.gameId = [NSString stringWithFormat:@"%@", dataGameId];
    }
    NSString *dataPlacementId = [data objectForKey:@"placement_id"];
    if ([self isNotNull:dataPlacementId]) {
        self.placementId = [NSString stringWithFormat:@"%@",dataPlacementId];
    }
}

-(void)initAdnetworkIfNeeded {
    if (self.gameId && self.placementId) {
        if (!UnityAds.isInitialized) {
            @try {
                [UnityAds initialize:self.gameId testMode:self.testFlg initializationDelegate:self];
            } @catch (NSException *exception) {
                [self adnetworkExceptionHandling:exception];
            }
        } else {
            [self initCompleteAndRetryStartAdIfNeeded];
        }
    }
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd {
    if (![self canStartAd]) {
        return;
    }
    
    if (UnityAds.isInitialized && self.placementId) {
        self.isAdLoaded = false;
        
        [UnityAds load:self.placementId loadDelegate:self];
    }
}

/**
 *  広告の表示を行う
 */
-(void)showAd {
    [self showAdWithPresentingViewController:[self topMostViewController]];
}

-(void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAdWithPresentingViewController:viewController];
    
    if (viewController != nil && self.isPrepared) {
        @try {
            [self requireToAsyncPlay];
            
            self.isAdLoaded = false;
            [UnityAds show:viewController placementId:self.placementId showDelegate:self];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    } else {
        NSLog(@"Error encountered playing ad : could not fetch topmost viewcontroller");
        [self setErrorWithMessage:@"Error encountered playing ad : could not fetch topmost viewcontroller" code:0];
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}


/**
 * 対象のクラスがあるかどうか？
 */
-(BOOL)isClassReference {
    NSLog(@"MovieReward6001 isClassReference");
    Class clazz = NSClassFromString(@"UnityAds");
    if (clazz) {
        NSLog(@"found Class: UnityAds");
        return YES;
    }
    else {
        NSLog(@"Not found Class: UnityAds");
        return NO;
    }
}

-(void)setHasUserConsent:(BOOL)hasUserConsent {
    [super setHasUserConsent:hasUserConsent];
    UADSMediationMetaData *gdprConsentMetaData = [[UADSMediationMetaData alloc] init];
    [gdprConsentMetaData set:@"gdpr.consent" value:hasUserConsent ? @YES : @NO];
    [gdprConsentMetaData commit];
}

-(void)sendFetchComplete {
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

-(void)sendFetchFail {
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

#pragma mark: UnityAdsInitializationDelegate
- (void)initializationComplete {
    [self initCompleteAndRetryStartAdIfNeeded];
}

- (void)initializationFailed: (UnityAdsInitializationError)error withMessage: (NSString *)message {
    NSLog(@"%s called", __func__);
}

#pragma mark: UnityAdsLoadDelegate
- (void)unityAdsAdLoaded: (NSString *)placementId {
    NSLog(@"unityAdsAdLoaded : %@, placement Id : %@", self, placementId);
    if ([self.placementId isEqualToString:placementId]) {
        self.isAdLoaded = true;
        [self sendFetchComplete];
    } else {
        NSLog(@"unityAdsAdLoaded(%@), but placemendId(%@) is not equal to %@", self, placementId, self.placementId);
    }
}

- (void)unityAdsAdFailedToLoad: (NSString *)placementId
                     withError: (UnityAdsLoadError)error
                   withMessage: (NSString *)message {
    NSLog(@"unityAdsAdFailedToLoad : %@, placement Id : %@, message : %@", self, placementId, message);
    [self setErrorWithMessage:message code:0];
    [self sendFetchFail];
}

#pragma mark: UnityAdsShowDelegate
- (void)unityAdsShowComplete:(NSString *)placementId withFinishState:(UnityAdsShowCompletionState)state {
    NSLog(@"unityAdsShowComplete : UnityAdsShowDelegate unityAdsShowComplete %@ %ld", placementId, state);
    switch (state) {
        case kUnityShowCompletionStateCompleted:
            NSLog(@"unityAdsShowComplete %s kUnityShowCompletionStateCompleted %@", __func__, placementId);
            [self setCallbackStatus:MovieRewardCallbackPlayComplete];
            break;
        case kUnityShowCompletionStateSkipped:
            NSLog(@"unityAdsShowComplete %s kUnityShowCompletionStateSkipped %@", __func__, placementId);
            break;
        default:
            NSLog(@"unityAdsShowComplete %s other %@", __func__, placementId);
            [self setErrorWithMessage:@"unityAdsShowComplete with UnityAdsShowCompletionStateError" code:0];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
            break;
    }

    [self setCallbackStatus:MovieRewardCallbackClose];
}

- (void)unityAdsShowFailed:(NSString *)placementId withError:(UnityAdsShowError)error withMessage:(NSString *)message {
    NSLog(@"unityAdsShowFailed : UnityAdsShowDelegate unityAdsShowFailed %@ %ld", message, error);
    NSString *reason;
    switch (error) {
        case kUnityShowErrorNotInitialized:
            reason = @"NotInitialized";
            break;
        case kUnityShowErrorNotReady:
            reason = @"NotReady";
            break;
        case kUnityShowErrorVideoPlayerError:
            reason = @"VideoPlayerError";
            break;
        case kUnityShowErrorInvalidArgument:
            reason = @"InvalidArgument";
            break;
        case kUnityShowErrorNoConnection:
            reason = @"NoConnection";
            break;
        case kUnityShowErrorAlreadyShowing:
            reason = @"AlreadyShowing";
            break;
        case kUnityShowErrorInternalError:
            reason = @"InternalError";
            break;
    }
    [self setErrorWithMessage:reason code:(int)error];
    [self setCallbackStatus:MovieRewardCallbackPlayFail];

}
 
- (void)unityAdsShowStart:(NSString *)placementId {
    NSLog(@"- UnityAdsShowDelegate unityAdsShowStart %@", placementId);
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}
 
- (void)unityAdsShowClick:(NSString *)placementId {
    NSLog(@"- UnityAdsShowDelegate unityAdsShowClick %@", placementId);
}

@end

@implementation MovieReward6030

@end

@implementation MovieReward6031

@end
