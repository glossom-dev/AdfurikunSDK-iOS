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
@property (nonatomic, strong)NSString *gameId;
@property (nonatomic, strong)NSString *placement_id;
@property (nonatomic, assign)BOOL isCompleted;
@property (nonatomic) BOOL isCalledFetchCompleted;
@property (nonatomic) BOOL test_flg;

@property (strong) UMONPlacementContent *rewardedVideo;
@end

@implementation MovieReward6001

//課題：ANDW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion {
    return UnityServices.getVersion;
}

/**
 *  データの設定
 */
-(void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.gameId = [NSString stringWithFormat:@"%@",[data objectForKey:@"game_id"]];
    NSString *data_placement_id = [data objectForKey:@"placement_id"];
    if (data_placement_id && ![data_placement_id isEqual:[NSNull null]]) {
        self.placement_id = [NSString stringWithFormat:@"%@",[data objectForKey:@"placement_id"]];
    }
    self.test_flg = [[data objectForKey:@"test_flg"] boolValue];
    _isCompleted = NO;
}

-(void)initAdnetworkIfNeeded {
    MovieDelegate6001 *delegate = [MovieDelegate6001 sharedInstance];
    [delegate setMovieReward:self inZone:self.placement_id];
    [UnityServices setDebugMode:self.test_flg];
    if (![UnityServices isInitialized]) {
        [UnityAds addDelegate:[MovieDelegate6001 sharedInstance]];
        [UnityAds initialize:_gameId];
    }
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd {
}

-(BOOL)isPrepared{
    if (self.delegate != nil) {
        BOOL isReady = [UnityAds isReady:self.placement_id];
        if (self.isCalledFetchCompleted == false && isReady) {
            self.isCalledFetchCompleted = true;
            MovieDelegate6001 *delegate = [MovieDelegate6001 sharedInstance];
            [delegate setCallbackStatus:MovieRewardCallbackFetchComplete zone:self.placement_id];
        }
        return isReady;
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
        [UnityAds show:viewController placementId:self.placement_id];
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

/**
 *  広告の読み込みを中止
 */
-(void)cancel {
// 2.0で廃止  [UnityAds stopAll];
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
        movieReward.isCalledFetchCompleted = true;
        [self setCallbackStatus:MovieRewardCallbackFetchComplete zone:placementId];
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
