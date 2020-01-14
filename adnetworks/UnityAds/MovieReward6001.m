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
    self.gameId = [NSString stringWithFormat:@"%@",[data objectForKey:@"game_id"]];
    NSString *data_placement_id = [data objectForKey:@"placement_id"];
    if (data_placement_id && ![data_placement_id isEqual:[NSNull null]]) {
        self.placement_id = [NSString stringWithFormat:@"%@",[data objectForKey:@"placement_id"]];
    }
    if (ADFMovieOptions.getTestMode) {
        self.test_flg = YES;
    } else {
        self.test_flg = [[data objectForKey:@"test_flg"] boolValue];
    }
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
    [[MovieDelegate6001 sharedInstance] setDelegate:self.delegate inZone:self.placement_id];
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
    if (viewController != nil && self.isPrepared) {
        [UnityAds show:viewController placementId:self.placement_id];
    } else {
        NSLog(@"Error encountered playing ad : could not fetch topmost viewcontroller");
        if ([self.delegate respondsToSelector:@selector(AdsPlayFailed:)]) {
            [self.delegate AdsPlayFailed:self];
        }
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
        NSLog(@"didLoadAd");
        NSLog(@"%s %@", __func__, placementId);
        id delegate = [self getDelegateWithZone:placementId];
        if (delegate) {
            if ([delegate respondsToSelector:@selector(AdsFetchCompleted:)]) {
                [delegate AdsFetchCompleted:movieReward];
            } else {
                NSLog(@"%s AdsFetchCompleted selector is not responding", __FUNCTION__);
            }
        } else {
            NSLog(@"%s Delegate is not setting", __FUNCTION__);
        }
    }
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(nonnull NSString *)message {
}

- (void)unityAdsDidStart:(NSString *)placementId {
    NSLog(@"《 UnityAds Callback 》unityAdsDidStart");
    id delegate = [self getDelegateWithZone:placementId];
    MovieReward6001 *movieReward = (MovieReward6001 *)[self getMovieRewardWithZone:placementId];
    
    if (delegate) {
        if ([delegate respondsToSelector:@selector(AdsDidShow:)]) {
            [delegate AdsDidShow:movieReward];
        }
    }
}

- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state {
    id delegate = [self getDelegateWithZone:placementId];
    MovieReward6001 *movieReward = (MovieReward6001 *)[self getMovieRewardWithZone:placementId];
    
    switch (state) {
        case kUnityAdsFinishStateCompleted:
            NSLog(@"%s kUnityAdsFinishStateCompleted %@", __func__, placementId);
            if ([delegate respondsToSelector:@selector(AdsDidCompleteShow:)]) {
                [delegate AdsDidCompleteShow:movieReward];
            }
            break;
        case kUnityAdsFinishStateSkipped:
            NSLog(@"%s kUnityAdsFinishStateSkipped %@", __func__, placementId);
            break;
        default:
            NSLog(@"%s other %@", __func__, placementId);
            if ([delegate respondsToSelector:@selector(AdsPlayFailed:)]) {
                [delegate AdsPlayFailed:movieReward];
            }
            break;
    }
    
    if ([delegate respondsToSelector:@selector(AdsDidHide:)]) {
        [delegate AdsDidHide:movieReward];
    }
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
