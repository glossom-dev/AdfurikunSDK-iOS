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
    return @"6";
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
        [self requireToAsyncInit];
        [[MovieConfigure6000 sharedInstance] configureWithCompletion:^{
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
        //音出力設定
        ADFMovieOptions_Sound soundState = [ADFMovieOptions getSoundState];
        if (ADFMovieOptions_Sound_Default != soundState) {
            [ALSdk shared].settings.muted = (ADFMovieOptions_Sound_Off == soundState);
        }
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
        [super startAd];
        @try {
            [self requireToAsyncRequestAd];
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
        AdapterLogP(@"[SEVERE] [Applovin]アプリのバンドルIDが、申請されたもの（%@）と異なります。", self.submittedPackageName);
    }
    return self.isAdLoaded && self.incentivizedInterstitial && self.incentivizedInterstitial.isReadyForDisplay;
}

-(void)showAd
{
    [super showAd];

    if (self.incentivizedInterstitial && self.incentivizedInterstitial.isReadyForDisplay) {
        @try {
            [self requireToAsyncPlay];
            [self.incentivizedInterstitial show];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    } else{
        AdapterLog(@"could not load ad");
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
        AdapterLog(@"Not found Class: ALSdk");
        return NO;
    }
    return YES;
}

-(void)setHasUserConsent:(BOOL)hasUserConsent {
    [super setHasUserConsent:hasUserConsent];
    [ALPrivacySettings setHasUserConsent:hasUserConsent];
    AdapterLogP(@"Adnetwork 6000, gdprConsent : %@, sdk setting value : %d", self.hasGdprConsent, (int)hasUserConsent);
}

- (void)isChildDirected:(BOOL)childDirected {
    [super isChildDirected:childDirected];
    [ALPrivacySettings setIsAgeRestrictedUser:childDirected];
    AdapterLogP(@"Adnetwork %@, childDirected : %@, input parameter : %d", self.adnetworkKey, self.childDirected, (int)childDirected);
}

// ------------------------------ -----------------
// ここからはApplovinのDelegateを受け取る箇所

/**
 *  広告の読み込み準備が終わった
 */
-(void) adService: (ALAdService *) adService didLoadAd: (ALAd *) ad
{
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

/**
 *  広告の読み込みに失敗
 */
-(void) adService: (ALAdService *) adService didFailToLoadAdWithError: (int) code
{
    AdapterTraceP(@"code : %d", code);
    [self setErrorWithMessage:nil code:code];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

/**
 *  広告の表示が開始された場合
 */
-(void) ad: (ALAd *) ad wasDisplayedIn: (UIView *) view
{
    AdapterTrace;
}

/**
 *  アプリが落とされたりした場合などのバックグラウンドに回った場合の動作
 */
-(void) ad: (ALAd *) ad wasHiddenIn: (UIView *) view
{
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackClose];
}

/**
 *  広告をクリックされた場合の動作
 */
-(void) ad: (ALAd *) ad wasClickedIn: (UIView *) view
{
    AdapterTrace;
}

/**
 *  広告（ビデオ)の表示を開始されたか
 */
-(void) videoPlaybackBeganInAd: (ALAd*) ad
{
    AdapterTrace;
    // 広告の読み
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

/**
 *  広告の終了・停止時に呼ばれる
 *  パーセント、読み込み終わりの設定を表示
 */
-(void) videoPlaybackEndedInAd: (ALAd*) ad atPlaybackPercent: (NSNumber*) percentPlayed fullyWatched: (BOOL) wasFullyWatched
{
    AdapterTraceP(@"atPlaybackPercent : %@, fullyWatched : %d", percentPlayed, wasFullyWatched);
    if ( wasFullyWatched ) {
        [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    }
}

@end

typedef enum : NSUInteger {
    initializeNotYet,
    initializing,
    initializeComplete,
} ALSDKInitializeStatus;

@interface MovieConfigure6000()

@property (nonatomic) ALSDKInitializeStatus initStatus;
@property (nonatomic) NSMutableArray <completionHandlerType> *handlers;

@end

@implementation MovieConfigure6000

+ (instancetype)sharedInstance {
    static MovieConfigure6000 *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.initStatus = initializeNotYet;
        self.handlers = [NSMutableArray new];
    }
    return self;
}

- (void)configureWithCompletion:(void (^)(void))completionHandler {
    if (!completionHandler) {
        return;
    }
    
    if (self.initStatus == initializeComplete) {
        completionHandler();
        return;
    }
    
    if (self.initStatus == initializing) {
        [self.handlers addObject:completionHandler];
        return;
    }
    
    if (self.initStatus == initializeNotYet) {
        self.initStatus = initializing;
        [self.handlers addObject:completionHandler];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @try {
                [ALSdk initializeSdkWithCompletionHandler:^(ALSdkConfiguration * _Nonnull configuration) {
                    self.initStatus = initializeComplete;
                    
                    for (completionHandlerType handler in self.handlers) {
                        handler();
                    }
                }];
            } @catch (NSException *exception) {
                NSLog(@"[ADF] adnetwork exception : %@", exception);
            }
        });
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
