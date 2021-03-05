//
//  MovieReward6000.m(AppLovin)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import <ADFMovieReward/ADFMovieOptions.h>
#import "MovieReward6000.h"


@interface MovieReward6000()<ALAdLoadDelegate, ALAdDisplayDelegate, ALAdVideoPlaybackDelegate>
@property (nonatomic, strong)NSString* appLovinSdkKey;
@property (nonatomic, strong)NSString* submittedPackageName;
@property (nonatomic, strong)NSString* zoneIdentifier;
@property (nonatomic, strong)ALIncentivizedInterstitialAd *incentivizedInterstitial;
@end


@implementation MovieReward6000

//課題：ANDW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion {
    return ALSdk.version;
}

+ (NSString *)getAdapterRevisionVersion {
    return @"3";
}

/**
 *  データの設定
 */
-(void)setData:(NSDictionary *)data
{
    [super setData:data];
    
    NSString *appLovinSdkKey = [data objectForKey:@"sdk_key"];
    if ([self isNotNull:appLovinSdkKey]) {
        self.appLovinSdkKey = [NSString stringWithFormat:@"%@", appLovinSdkKey];
    }
    
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    if ( ![infoDict objectForKey:@"AppLovinSdkKey"] ) {
        [infoDict setValue:self.appLovinSdkKey forKey:@"AppLovinSdkKey"];
    }
    //申請されたパッケージ名を受け取り
    NSString *submittedPackageName = [data objectForKey:@"package_name"];
    if ([self isNotNull:submittedPackageName]) {
        self.submittedPackageName = [NSString stringWithFormat:@"%@", submittedPackageName];
    }
    
    NSString *zoneIdentifier = [data objectForKey:@"zone_id"];
    if ([self isNotNull:zoneIdentifier]) {
        self.zoneIdentifier = [NSString stringWithFormat:@"%@", zoneIdentifier];
    }
}

-(void)initAdnetworkIfNeeded {
    if (![self needsToInit]) {
        return;
    }

    if (self.appLovinSdkKey) {
        [MovieConfigure6000 configureWithCompletion:^{
            if (!self.incentivizedInterstitial) {
                @try {
                    if (self.zoneIdentifier && ![self.zoneIdentifier isEqual: [NSNull null]] && [self.zoneIdentifier length] != 0) {
                        self.incentivizedInterstitial = [[ALIncentivizedInterstitialAd alloc] initWithZoneIdentifier:self.zoneIdentifier sdk:[ALSdk sharedWithKey:self.appLovinSdkKey]];
                    } else {
                        self.incentivizedInterstitial = [[ALIncentivizedInterstitialAd alloc] initWithSdk:[ALSdk sharedWithKey:self.appLovinSdkKey]];
                    }
                } @catch (NSException *exception) {
                    [self adnetworkExceptionHandling:exception];
                }
                self.incentivizedInterstitial.adDisplayDelegate = self;
                self.incentivizedInterstitial.adVideoPlaybackDelegate = self;
            }
            [self initCompleteAndRetryStartAdIfNeeded];
        }];
    }
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd
{
    if (![self canStartAd]) {
        return;
    }

    if (self.incentivizedInterstitial) {
        @try {
            [self.incentivizedInterstitial preloadAndNotify: self];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    }
}

-(BOOL)isPrepared{
    //申請済のバンドルIDと異なる場合のメッセージ
    //(バンドルIDが申請済のものと異なると、正常に広告が返却されない可能性があります)
    if(self.submittedPackageName != nil
       && ![
            [self.submittedPackageName lowercaseString]
            isEqualToString:[[[NSBundle mainBundle] bundleIdentifier] lowercaseString]
            ])
    {
        //表示を消したい場合は、こちらをコメントアウトして下さい。
        NSLog(@"[ADF] [SEVERE] [Applovin]アプリのバンドルIDが、申請されたもの（%@）と異なります。", self.submittedPackageName);
    }
    return self.incentivizedInterstitial && self.incentivizedInterstitial.isReadyForDisplay;
}

-(void)showAd
{
    [super showAd];

    if (self.incentivizedInterstitial && self.incentivizedInterstitial.isReadyForDisplay) {
        @try {
            [self.incentivizedInterstitial show];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    } else{
        NSLog(@"could not load ad");
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

-(void)showAdWithPresentingViewController:(UIViewController *)viewController
{
    [self showAd];
}

/**
 * 対象のクラスがあるかどうか？
 */
-(BOOL)isClassReference
{
    Class clazz = NSClassFromString(@"ALSdk");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: ALSdk");
        return NO;
    }
    return YES;
}

-(void)setHasUserConsent:(BOOL)hasUserConsent {
    [super setHasUserConsent:hasUserConsent];
    [ALPrivacySettings setHasUserConsent:hasUserConsent];
}

// ------------------------------ -----------------
// ここからはApplovinのDelegateを受け取る箇所

/**
 *  広告の読み込み準備が終わった
 */
-(void) adService: (ALAdService *) adService didLoadAd: (ALAd *) ad
{
    NSLog(@"didLoadAd");
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

/**
 *  広告の読み込みに失敗
 */
-(void) adService: (ALAdService *) adService didFailToLoadAdWithError: (int) code
{
    NSLog(@"didFailToLoadAdWithError : %d", code);
    [self setErrorWithMessage:nil code:code];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

/**
 *  広告の表示が開始された場合
 */
-(void) ad: (ALAd *) ad wasDisplayedIn: (UIView *) view
{
    NSLog(@"wasDisplayedIn");
}

/**
 *  アプリが落とされたりした場合などのバックグラウンドに回った場合の動作
 */
-(void) ad: (ALAd *) ad wasHiddenIn: (UIView *) view
{
    NSLog(@"wasHiddenIn");
    [self setCallbackStatus:MovieRewardCallbackClose];
}

/**
 *  広告をクリックされた場合の動作
 */
-(void) ad: (ALAd *) ad wasClickedIn: (UIView *) view
{
    NSLog(@"wasClickedIn");
}

/**
 *  広告（ビデオ)の表示を開始されたか
 */
-(void) videoPlaybackBeganInAd: (ALAd*) ad
{
    NSLog(@"videoPlaybackBeganInAd");
    // 広告の読み
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

/**
 *  広告の終了・停止時に呼ばれる
 *  パーセント、読み込み終わりの設定を表示
 */
-(void) videoPlaybackEndedInAd: (ALAd*) ad atPlaybackPercent: (NSNumber*) percentPlayed fullyWatched: (BOOL) wasFullyWatched
{
    NSLog(@"videoPlaybackEndedInAd, atPlaybackPercent : %@, fullyWatched : %d", percentPlayed, wasFullyWatched);
    if ( wasFullyWatched ) {
        [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    } else {
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

@end

@implementation MovieConfigure6000
+ (void)configure {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @try {
            [ALSdk initializeSdk];
        } @catch (NSException *exception) {
            NSLog(@"adnetwork exception : %@", exception);
        }
    });
}

+ (void)configureWithCompletion:(void (^)(void))completionHandler {
    static bool isInitialized = false;
    if (!isInitialized) {
        @try {
            [ALSdk initializeSdkWithCompletionHandler:^(ALSdkConfiguration * _Nonnull configuration) {
                completionHandler();
            }];
        } @catch (NSException *exception) {
            NSLog(@"adnetwork exception : %@", exception);
        }
    } else {
        completionHandler();
    }
}

@end

@implementation MovieReward6011

@end

@implementation MovieReward6012

@end

@implementation MovieReward6013

@end

@implementation MovieReward6014

@end

@implementation MovieReward6015

@end
