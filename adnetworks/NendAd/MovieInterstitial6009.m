//
//  MovieInterstitial6009.m(NendAd)
//
//  Copyright © 2017年 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import "MovieInterstitial6009.h"
#import <NendAd/NendAd.h>
#import <ADFMovieReward/ADFMovieOptions.h>

@interface MovieInterstitial6009()<NADInterstitialVideoDelegate>

@property (nonatomic, strong) NSString *nendKey;
@property (nonatomic) NSInteger nendAdspotId;
@property (nonatomic) BOOL didInit;
@property (nonatomic) BOOL didPlayComplete;
@property (nonatomic) BOOL isNADVideoAdTypeNormal;

@property (nonatomic) NADInterstitialVideo *interstitialVideo;

@end

@implementation MovieInterstitial6009

#pragma mark - ADFmyMovieRewardInterface

+ (NSString *)getAdapterRevisionVersion {
    return @"7";
}

-(id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

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
    return self.interstitialVideo.isReady;
}

-(void)initAdnetworkIfNeeded {
    if (!self.didInit && self.nendAdspotId && self.nendKey) {
        @try {
            self.interstitialVideo = [[NADInterstitialVideo alloc] initWithSpotID:self.nendAdspotId apiKey:self.nendKey];
            self.interstitialVideo.mediationName = @"adfurikun";
            [NADLogger setLogLevel:NADLogLevelError];
            self.interstitialVideo.delegate = self;
            self.didInit = YES;
            //音出力設定
            ADFMovieOptions_Sound soundState = [ADFMovieOptions getSoundState];
            if (ADFMovieOptions_Sound_On == soundState) {
                self.interstitialVideo.isMuteStartPlaying = false;
            } else if (ADFMovieOptions_Sound_Off == soundState) {
                self.interstitialVideo.isMuteStartPlaying = true;
            }
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

    if (self.interstitialVideo) {
        @try {
            [self requireToAsyncRequestAd];
            
            [self.interstitialVideo loadAd];
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
                
                [self.interstitialVideo showAdFromViewController:topMostViewController];
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

-(void)showAdWithPresentingViewController:(UIViewController *)viewController
{
    [super showAdWithPresentingViewController:viewController];

    if (self.interstitialVideo.isReady) {
        @try {
            [self requireToAsyncPlay];

            [self.interstitialVideo showAdFromViewController:viewController];
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
    
    Class clazz = NSClassFromString(@"NADInterstitialVideo");
    if (clazz) {
    } else {
        AdapterLog(@"Not found Class: NendAd");
        return NO;
    }
    return YES;
}

-(void)dealloc{
    [self.interstitialVideo releaseVideoAd];
    self.didInit = NO;
}

#pragma mark - NADInterstitialVideoDelegate
- (void)nadInterstitialVideoAdDidReceiveAd:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    AdapterTrace;
    self.isNADVideoAdTypeNormal = NO;
    self.didPlayComplete = NO;
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

- (void)nadInterstitialVideoAd:(NADInterstitialVideo *)nadInterstitialVideoAd didFailToLoadWithError:(NSError *)error
{
    AdapterTraceP(@"error: %@", error);
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

- (void)nadInterstitialVideoAdDidFailedToPlay:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}

- (void)nadInterstitialVideoAdDidOpen:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)nadInterstitialVideoAdDidClose:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    AdapterTrace;
    if (!self.isNADVideoAdTypeNormal && !self.didPlayComplete) {
        [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    }
    [self setCallbackStatus:MovieRewardCallbackClose];
}

- (void)nadInterstitialVideoAdDidClickAd:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    AdapterTrace;
}

- (void)nadInterstitialVideoAdDidClickInformation:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    AdapterTrace;
}
// only adType NADVideoAdTypeNormal
- (void)nadInterstitialVideoAdDidStartPlaying:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    AdapterTrace;
    self.isNADVideoAdTypeNormal = YES;
}
// only adType NADVideoAdTypeNormal
- (void)nadInterstitialVideoAdDidCompletePlaying:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    AdapterTrace;
    if (!self.didPlayComplete) {
        [self setCallbackStatus:MovieRewardCallbackPlayComplete];
        self.didPlayComplete = YES;
    }
}
//only adType NADVideoAdTypeNormal
- (void)nadInterstitialVideoAdDidStopPlaying:(NADInterstitialVideo *)nadInterstitialVideoAd
{
    AdapterTrace;
}

@end

@implementation MovieInterstitial6080
@end

@implementation MovieInterstitial6081
@end

@implementation MovieInterstitial6082
@end

@implementation MovieInterstitial6083
@end

@implementation MovieInterstitial6084
@end
