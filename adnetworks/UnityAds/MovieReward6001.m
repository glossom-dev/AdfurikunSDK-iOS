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
    return @"3";
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

    if (viewController != nil && self.isPrepared) {
        @try {
            [UnityAds show:viewController placementId:self.placement_id];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            MovieDelegate6001 *delegate = [MovieDelegate6001 sharedInstance];
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

// ------------------------------ -----------------
// ここからはUnityAdsのDelegateを受け取る箇所

#pragma mark - UnityAdsDelegate

//動画の準備完了
- (void)unityAdsReady:(nonnull NSString *)placementId {
    MovieReward6001 *movieReward = (MovieReward6001 *)[self getMovieRewardWithZone:placementId];
    if ([placementId isEqualToString:movieReward.placement_id]) {
        NSLog(@"%s %@", __func__, placementId);
        [movieReward sendFetchComplete];
    }
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(nonnull NSString *)message {
    NSLog(@"%s %@", __func__, message);
}

- (void)unityAdsDidStart:(NSString *)placementId {
    NSLog(@"《 UnityAds Callback 》unityAdsDidStart");
    [self setCallbackStatus:MovieRewardCallbackPlayStart zone:placementId];
}

- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state {
    switch (state) {
        case kUnityAdsFinishStateCompleted:
            NSLog(@"%s kUnityAdsFinishStateCompleted %@", __func__, placementId);
            [self setCallbackStatus:MovieRewardCallbackPlayComplete zone:placementId];
            break;
        case kUnityAdsFinishStateSkipped:
            NSLog(@"%s kUnityAdsFinishStateSkipped %@", __func__, placementId);
            break;
        default:
            NSLog(@"%s other %@", __func__, placementId);
            MovieReward6001 *movieReward = (MovieReward6001 *)[self getMovieRewardWithZone:placementId];
            [movieReward setErrorWithMessage:@"unityAdsDidFinish with kUnityAdsFinishStateError" code:0];
            [self setCallbackStatus:MovieRewardCallbackPlayFail zone:placementId];
            break;
    }

    [self setCallbackStatus:MovieRewardCallbackClose zone:placementId];
}

-(void) unityServicesDidError: (UnityServicesError) error withMessage: (NSString *) message {
    NSLog (@"UnityMonetization ERROR: %ld - %@", (long) error, message);
//    id delegate = [self getDelegateWithZone:];
//    if (delegate) {
//        if ([delegate respondsToSelector:@selector(AdsFetchFail:)]) {
//            [delegate AdsFetchFail:movieReward];
//        }
//    }
}

@end

@implementation MovieReward6030

@end

@implementation MovieReward6031

@end
