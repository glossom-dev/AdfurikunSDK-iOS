//
//  MovieReward6001.m(UnityAds)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//
#import <UIKit/UIKit.h>
#import "MovieReward6001.h"
#import <ADFMovieReward/ADFMovieOptions.h>

#define kUnityAdsStartAdToCallbackInterval 3.0

@interface MovieReward6001()
@property (nonatomic, strong)NSString *gameId;
@property (nonatomic, strong)NSString *placement_id;
@property (nonatomic, assign)BOOL isCompleted;
@property (nonatomic) BOOL hasSentCallback;
@property (nonatomic) BOOL test_flg;

@property (strong) UMONPlacementContent *rewardedVideo;
@end

@implementation MovieReward6001

//課題：ANDW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion {
    return UnityServices.getVersion;
}

+ (NSString *)getAdapterRevisionVersion {
    return @"4";
}

/**
 *  データの設定
 */
-(void)setData:(NSDictionary *)data {
    [super setData:data];
    
    if (ADFMovieOptions.getTestMode) {
        self.test_flg = YES;
    } else {
        NSNumber *testFlg = [data objectForKey:@"test_flg"];
        if ([self isNotNull:testFlg] && [testFlg isKindOfClass:[NSNumber class]]) {
            self.test_flg = [testFlg boolValue];
        }
    }

    NSString *dataGameId = [data objectForKey:@"game_id"];
    if ([self isNotNull:dataGameId]) {
        self.gameId = [NSString stringWithFormat:@"%@", dataGameId];
    }
    NSString *dataPlacementId = [data objectForKey:@"placement_id"];
    if ([self isNotNull:dataPlacementId]) {
        self.placement_id = [NSString stringWithFormat:@"%@",dataPlacementId];
    }
    
    _isCompleted = NO;
}

-(void)initAdnetworkIfNeeded {
    if (self.gameId && self.placement_id) {
        MovieDelegate6001 *delegate = [MovieDelegate6001 sharedInstance];
        [delegate setMovieReward:self inZone:self.placement_id];
        [UnityServices setDebugMode:self.test_flg];
        if (![UnityServices isInitialized]) {
            __weak MovieReward6001 *weakSelf = self;
            dispatch_queue_t queue = dispatch_get_main_queue();
            dispatch_async(queue, ^{
                @try {
                    [UnityAds addDelegate:[MovieDelegate6001 sharedInstance]];
                    [UnityAds initialize:weakSelf.gameId];
                } @catch (NSException *exception) {
                    [weakSelf adnetworkExceptionHandling:exception];
                }
            });
        }
    }
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd {
    self.hasSentCallback = false;
    if ([self isPrepared]) {
        [self sendFetchComplete];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kUnityAdsStartAdToCallbackInterval * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if (self.hasSentCallback == false) {
                if ([self isPrepared]) {
                    [self sendFetchComplete];
                } else {
                    [self sendFetchFail];
                }
            }
        });
    }
}

-(BOOL)isPrepared{
    if (self.delegate != nil) {
        return [UnityAds isReady:self.placement_id];
    }
    return NO;
}

/**
 *  広告の表示を行う
 */
-(void)showAd {
    [self showAdWithPresentingViewController:[self topMostViewController]];
}

-(void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAdWithPresentingViewController:viewController];
    
    MovieDelegate6001 *delegate = [MovieDelegate6001 sharedInstance];
    if (viewController != nil && self.isPrepared) {
        @try {
            [UnityAds show:viewController placementId:self.placement_id showDelegate:delegate];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [delegate setCallbackStatus:MovieRewardCallbackPlayFail zone:self.placement_id];
        }
    } else {
        NSLog(@"Error encountered playing ad : could not fetch topmost viewcontroller");
        [self setErrorWithMessage:@"Error encountered playing ad : could not fetch topmost viewcontroller" code:0];
        MovieDelegate6001 *delegate = [MovieDelegate6001 sharedInstance];
        [delegate setCallbackStatus:MovieRewardCallbackPlayFail zone:self.placement_id];
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

-(void)dealloc {
    _gameId = nil;
}

-(void)sendFetchComplete {
    if (self.hasSentCallback == false) {
        self.hasSentCallback = true;
        [self setCallbackStatus:MovieRewardCallbackFetchComplete];
    }
}

-(void)sendFetchFail {
    if (self.hasSentCallback == false) {
        self.hasSentCallback = true;
        [self setCallbackStatus:MovieRewardCallbackFetchFail];
    }
}

@end

@implementation MovieDelegate6001
+ (instancetype)sharedInstance {
    static MovieDelegate6001 *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super new];
    });
    return sharedInstance;
}

// -----------------------------------------------
// ここからはUnityAdsのDelegateを受け取る箇所

#pragma mark - UnityAdsDelegate

//動画の準備完了
- (void)unityAdsReady:(nonnull NSString *)placementId {
    MovieReward6001 *movieReward = (MovieReward6001 *)[self getMovieRewardWithZone:placementId];
    if ([placementId isEqualToString:movieReward.placement_id]) {
        NSLog(@"UnityAdsDelegate %s %@", __func__, placementId);
        [movieReward sendFetchComplete];
    }
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(nonnull NSString *)message {
    NSLog(@"UnityAdsDelegate %s %@", __func__, message);
}

- (void)unityAdsDidStart:(NSString *)placementId {
    NSLog(@"UnityAdsDelegate %s", __func__);
}

- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state {
    NSLog(@"UnityAdsDelegate %s", __func__);
}

-(void) unityServicesDidError: (UnityServicesError) error withMessage: (NSString *) message {
    NSLog (@"UnityAdsDelegate %s: %ld - %@", __func__, (long) error, message);
//    id delegate = [self getDelegateWithZone:];
//    if (delegate) {
//        if ([delegate respondsToSelector:@selector(AdsFetchFail:)]) {
//            [delegate AdsFetchFail:movieReward];
//        }
//    }
}

#pragma mark - UnityAdsShowDelegate

- (void)unityAdsShowStart:(NSString *)placementId {
    NSLog(@"UnityAdsShowDelegate %s", __func__);
    [self setCallbackStatus:MovieRewardCallbackPlayStart zone:placementId];
}

- (void)unityAdsShowComplete:(NSString *)placementId withFinishState:(UnityAdsShowCompletionState)state {
    switch (state) {
        case kUnityShowCompletionStateCompleted:
            NSLog(@"unityAdsShowComplete %s kUnityShowCompletionStateCompleted %@", __func__, placementId);
            [self setCallbackStatus:MovieRewardCallbackPlayComplete zone:placementId];
            break;
        case kUnityShowCompletionStateSkipped:
            NSLog(@"unityAdsShowComplete %s kUnityShowCompletionStateSkipped %@", __func__, placementId);
            break;
        default:
            NSLog(@"unityAdsShowComplete %s other %@", __func__, placementId);
            MovieReward6001 *movieReward = (MovieReward6001 *)[self getMovieRewardWithZone:placementId];
            [movieReward setErrorWithMessage:@"unityAdsShowComplete with UnityAdsShowCompletionStateError" code:0];
            [self setCallbackStatus:MovieRewardCallbackPlayFail zone:placementId];
            break;
    }

    [self setCallbackStatus:MovieRewardCallbackClose zone:placementId];
}

- (void)unityAdsShowFailed:(NSString *)placementId withError:(UnityAdsShowError)error withMessage:(NSString *)message {
    MovieReward6001 *movieReward = (MovieReward6001 *)[self getMovieRewardWithZone:placementId];
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
    NSLog(@"UnityAdsShowDelegate %s: %@", __func__, reason);
    [movieReward setErrorWithMessage:reason code:0];
    [self setCallbackStatus:MovieRewardCallbackPlayFail zone:placementId];
}

- (void)unityAdsShowClick:(NSString *)placementId {
    NSLog(@"UnityAdsShowDelegate %s", __func__);
}

@end

@implementation MovieReward6030

@end

@implementation MovieReward6031

@end
