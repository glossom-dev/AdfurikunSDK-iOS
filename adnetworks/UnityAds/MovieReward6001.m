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
    return @"12";
}

+ (NSString *)adnetworkClassName {
    return @"UnityAds";
}

+ (NSString *)adnetworkName {
    return @"Unity Ads";
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
    
    [super startAd];
    
    if (UnityAds.isInitialized && self.placementId) {
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
            
            [UnityAds show:viewController placementId:self.placementId showDelegate:self];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    } else {
        AdapterLog(@"Error encountered playing ad : could not fetch topmost viewcontroller");
        [self setErrorWithMessage:@"Error encountered playing ad : could not fetch topmost viewcontroller" code:0];
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

-(void)setHasUserConsent:(BOOL)hasUserConsent {
    [super setHasUserConsent:hasUserConsent];
    UADSMetaData *gdprConsentMetaData = [[UADSMetaData alloc] init];
    [gdprConsentMetaData set:@"gdpr.consent" value:hasUserConsent ? @YES : @NO];
    [gdprConsentMetaData commit];
    AdapterLogP(@"Adnetwork 6001, gdprConsent : %@, sdk setting value : %@", self.hasGdprConsent, hasUserConsent ? @YES : @NO);
}

- (void)isChildDirected:(BOOL)childDirected {
    [super isChildDirected:childDirected];
    UADSMetaData *gdprConsentMetaData = [[UADSMetaData alloc] init];
    [gdprConsentMetaData set:@"user.nonbehavioral" value:childDirected ? @YES : @NO];
    [gdprConsentMetaData commit];
    AdapterLogP(@"Adnetwork %@, childDirected : %@, input parameter : %d", self.adnetworkKey, self.childDirected, (int)childDirected);
}

-(void)sendFetchComplete {
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

-(void)sendFetchFail {
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

#pragma mark: UnityAdsInitializationDelegate
- (void)initializationComplete {
    AdapterTrace;
    [self initCompleteAndRetryStartAdIfNeeded];
}

- (void)initializationFailed: (UnityAdsInitializationError)error withMessage: (NSString *)message {
    AdapterTraceP(@"error message : %@", message);
}

#pragma mark: UnityAdsLoadDelegate
- (void)unityAdsAdLoaded: (NSString *)placementId {
    AdapterTraceP(@"object : %@, placement Id : %@", self, placementId);
    if ([self.placementId isEqualToString:placementId]) {
        [self sendFetchComplete];
    } else {
        AdapterLogP(@"unityAdsAdLoaded(%@), but placemendId(%@) is not equal to %@", self, placementId, self.placementId);
    }
}

- (void)unityAdsAdFailedToLoad: (NSString *)placementId
                     withError: (UnityAdsLoadError)error
                   withMessage: (NSString *)message {
    AdapterTraceP(@"unityAdsAdFailedToLoad : %@, placement Id : %@, message : %@", self, placementId, message);
    [self setErrorWithMessage:message code:0];
    [self sendFetchFail];
}

#pragma mark: UnityAdsShowDelegate
- (void)unityAdsShowComplete:(NSString *)placementId withFinishState:(UnityAdsShowCompletionState)state {
    AdapterTraceP(@"unityAdsShowComplete : UnityAdsShowDelegate unityAdsShowComplete %@ %ld", placementId, state);
    switch (state) {
        case kUnityShowCompletionStateCompleted:
            AdapterLogP(@"kUnityShowCompletionStateCompleted %@", placementId);
            [self setCallbackStatus:MovieRewardCallbackPlayComplete];
            break;
        case kUnityShowCompletionStateSkipped:
            AdapterLogP(@"kUnityShowCompletionStateSkipped %@", placementId);
            break;
        default:
            AdapterLogP(@"other %@", placementId);
            [self setErrorWithMessage:@"unityAdsShowComplete with UnityAdsShowCompletionStateError" code:0];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
            break;
    }

    [self setCallbackStatus:MovieRewardCallbackClose];
}

- (void)unityAdsShowFailed:(NSString *)placementId withError:(UnityAdsShowError)error withMessage:(NSString *)message {
    AdapterTraceP(@"%@ %ld", message, error);
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
        case kUnityShowErrorTimeout:
            reason = @"TimeoutError";
            break;
        default:
            reason = @"Unknown";
    }
    [self setErrorWithMessage:reason code:(int)error];
    [self setCallbackStatus:MovieRewardCallbackPlayFail];

}
 
- (void)unityAdsShowStart:(NSString *)placementId {
    AdapterTraceP(@"%@", placementId);
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}
 
- (void)unityAdsShowClick:(NSString *)placementId {
    AdapterTraceP(@"%@", placementId);
}

@end

@implementation MovieReward6030
@end

@implementation MovieReward6031
@end

@implementation MovieReward6032
@end

@implementation MovieReward6033
@end

@implementation MovieReward6034
@end
