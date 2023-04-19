//
//  MovieReward6009.m(NendAd)
//
//  Copyright © 2017年 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import "MovieReward6009.h"
#import <NendAd/NendAd.h>
#import <ADFMovieReward/ADFMovieOptions.h>

@interface MovieReward6009()<NADRewardedVideoDelegate>

@property (nonatomic, strong) NSString *nendKey;
@property (nonatomic) NSInteger nendAdspotId;
@property (nonatomic) BOOL didInit;

@property (nonatomic) NADRewardedVideo *rewardedVideo;

@end

@implementation MovieReward6009

+ (NSString *)getAdapterRevisionVersion {
    return @"8";
}

#pragma mark - ADFmyMovieRewardInterface
/**< 設定データの送信 */
-(void)setData:(NSDictionary *)data {
    [super setData:data];
    
    NSString *nendKey = [data objectForKey:@"api_key"];
    if ([self isNotNull:nendKey]) {
        self.nendKey = [NSString stringWithFormat:@"%@", nendKey];
    }
    NSString *spotId = [data objectForKey:@"adspot_id"];
    if ([self isNotNull:spotId] && ([spotId isKindOfClass:[NSString class]] || [spotId isKindOfClass:[NSNumber class]])) {
        self.nendAdspotId = [spotId integerValue];
    }
}

/**< 広告が準備できているか？ */
-(BOOL)isPrepared {
    return self.isAdLoaded && self.rewardedVideo.isReady;
}

-(void)initAdnetworkIfNeeded {
    if (!self.didInit && self.nendAdspotId && self.nendKey) {
        @try {
            self.rewardedVideo = [[NADRewardedVideo alloc] initWithSpotID:self.nendAdspotId apiKey:self.nendKey];
            self.rewardedVideo.mediationName = @"adfurikun";
            [NADLogger setLogLevel:NADLogLevelError];
            self.rewardedVideo.delegate = self;
            self.didInit = YES;
            
            [self initCompleteAndRetryStartAdIfNeeded];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    }
}

/**< 広告の読み込み開始 */
-(void)startAd {
    if (![self canStartAd]) {
        return;
    }

    if (self.rewardedVideo) {
        [super startAd];
        @try {
            [self requireToAsyncRequestAd];
            
            [self.rewardedVideo loadAd];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    }
}

/**< 広告の表示 */
-(void)showAd {
    [super showAd];

    if (self.isPrepared) {
        UIViewController *topMostViewController = [self topMostViewController];
        if (topMostViewController) {
            @try {
                [self requireToAsyncPlay];
                
                [self.rewardedVideo showAdFromViewController:topMostViewController];
            } @catch (NSException *exception) {
                [self adnetworkExceptionHandling:exception];
                [self setCallbackStatus:MovieRewardCallbackPlayFail];
            }
        }
        if (topMostViewController == nil) {
            AdapterLog(@"Error encountered playing ad : could not fetch topmost viewcontroller");
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    }
}

-(void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAdWithPresentingViewController:viewController];

    if (self.rewardedVideo.isReady) {
        @try {
            [self requireToAsyncPlay];

            [self.rewardedVideo showAdFromViewController:viewController];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    }
}

/**< SDKが読み込まれているかどうか？ */
-(BOOL)isClassReference {
    // Nend:iOS 8.1以上が動作保障対象となります。それ以外のOSおよび端末では正常に動作しない場合があります。
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_1) {
        return NO;
    }
    
    Class clazz = NSClassFromString(@"NADRewardedVideo");
    if (clazz) {
    } else {
        AdapterLog(@"Not found Class: NendAd");
        return NO;
    }
    return YES;
}

-(void)dealloc {
    [self.rewardedVideo releaseVideoAd];
    self.didInit = NO;
}

#pragma mark - NADRewardedVideoDelegate
- (void)nadRewardVideoAd:(NADRewardedVideo *)nadRewardedVideoAd didReward:(NADReward *)reward {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
}

- (void)nadRewardVideoAdDidReceiveAd:(NADRewardedVideo *)nadRewardedVideoAd {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

- (void)nadRewardVideoAd:(NADRewardedVideo *)nadRewardedVideoAd didFailToLoadWithError:(NSError *)error {
    AdapterTraceP(@"error: %@", error);
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

- (void)nadRewardVideoAdDidFailedToPlay:(NADRewardedVideo *)nadRewardedVideoAd {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}

- (void)nadRewardVideoAdDidOpen:(NADRewardedVideo *)nadRewardedVideoAd {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)nadRewardVideoAdDidClose:(NADRewardedVideo *)nadRewardedVideoAd {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackClose];
}

- (void)nadRewardVideoAdDidClickAd:(NADRewardedVideo *)nadRewardedVideoAd {
    AdapterTrace;
}

- (void)nadRewardVideoAdDidClickInformation:(NADRewardedVideo *)nadRewardedVideoAd {
    AdapterTrace;
}
//only adType NADVideoAdTypeNormal
- (void)nadRewardVideoAdDidStartPlaying:(NADRewardedVideo *)nadRewardedVideoAd {
    AdapterTrace;
}
//only adType NADVideoAdTypeNormal
- (void)nadRewardVideoAdDidCompletePlaying:(NADRewardedVideo *)nadRewardedVideoAd {
    AdapterTrace;
}
//only adType NADVideoAdTypeNormal
- (void)nadRewardVideoAdDidStopPlaying:(NADRewardedVideo *)nadRewardedVideoAd {
    AdapterTrace;
}


@end

@implementation MovieReward6080
@end

@implementation MovieReward6081
@end

@implementation MovieReward6082
@end

@implementation MovieReward6083
@end

@implementation MovieReward6084
@end
