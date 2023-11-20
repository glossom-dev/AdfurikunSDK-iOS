//
//  MovieInterstitial6000.m
//  SampleViewRecipe
//
//  Created by Junhua Li on 2016/11/03.
//
//

#import <AppLovinSDK/AppLovinSDK.h>
#import "MovieInterstitial6000.h"
#import "MovieReward6000.h"
#import <ADFMovieReward/ADFMovieOptions.h>

@interface MovieInterstitial6000()<ALAdLoadDelegate, ALAdDisplayDelegate, ALAdVideoPlaybackDelegate>
@property (nonatomic, strong)NSString* appLovinSdkKey;
@property (nonatomic, strong)NSString* submittedPackageName;
@property (nonatomic, strong)NSString* zoneIdentifier;
@property (nonatomic, strong) ALAd *ad;
@property (nonatomic, strong) ALInterstitialAd *interstitialAd;
@end

@implementation MovieInterstitial6000

//課題：ANDW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion {
    return ALSdk.version;
}

+ (NSString *)getAdapterRevisionVersion {
    return @"9";
}

+ (NSString *)adnetworkClassName {
    return @"ALSdk";
}

+ (NSString *)adnetworkName {
    return @"AppLovin";
}

-(id)init {
    self = [super init];
    if (self) {
    }
    return self;
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
            if (!self.interstitialAd) {
                @try {
                    self.interstitialAd = [[ALInterstitialAd alloc] initWithSdk: [ALSdk sharedWithKey:self.appLovinSdkKey]];
                    self.interstitialAd.adDisplayDelegate = self;
                    self.interstitialAd.adLoadDelegate = self;
                    self.interstitialAd.adVideoPlaybackDelegate = self;
                    [self initCompleteAndRetryStartAdIfNeeded];
                } @catch (NSException *exception) {
                    [self adnetworkExceptionHandling:exception];
                }
            }
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
-(void)startAd {
    if (![self canStartAd]) {
        return;
    }
    
    [super startAd];

    @try {
        [self requireToAsyncRequestAd];
        if ([self isNotNull:_appLovinSdkKey] && [self isNotNull:self.zoneIdentifier] && [self.zoneIdentifier length] != 0) {
            [[ALSdk sharedWithKey:self.appLovinSdkKey].adService loadNextAdForZoneIdentifier:self.zoneIdentifier andNotify:self];
        } else {
            [[ALSdk sharedWithKey:self.appLovinSdkKey].adService loadNextAd:ALAdSize.interstitial andNotify:self];
        }
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
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
    return self.isAdLoaded && self.interstitialAd;
}

-(void)showAd
{
    [super showAd];
    
    if(self.interstitialAd && self.ad && self.isAdLoaded){
        @try {
            [self requireToAsyncPlay];
            [self.interstitialAd showAd:self.ad];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    }
    else{
        // No interstitial ad is currently available.  Perform failover logic...
        AdapterLog(@"no ads could be shown!");
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

-(void)showAdWithPresentingViewController:(UIViewController *)viewController
{
    [self showAd];
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
-(void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad {
    AdapterTrace;
    self.ad = ad;
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

/**
 *  広告の読み込みに失敗
 */
-(void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code {
    AdapterTraceP(@"code:%d", code);
    [self setErrorWithMessage:nil code:(NSInteger)code];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

/**
 *  広告の表示が開始された場合
 */
-(void) ad:(ALAd *) ad wasDisplayedIn: (UIView *)view {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

/**
 *  アプリが落とされたりした場合などのバックグラウンドに回った場合の動作
 */
-(void) ad:(ALAd *) ad wasHiddenIn: (UIView *)view {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackClose];
}

/**
 *  広告をクリックされた場合の動作
 */
-(void) ad:(ALAd *) ad wasClickedIn: (UIView *)view {
    AdapterTrace;
}

/**
 *  広告（ビデオ)の表示を開始されたか
 */
-(void) videoPlaybackBeganInAd: (ALAd*) ad {
    AdapterTrace;
    // 広告の読み
}

/**
 *  広告の終了・停止時に呼ばれる
 * パーセント、読み込み終わりの設定を表示
 */
-(void) videoPlaybackEndedInAd: (ALAd*) ad atPlaybackPercent:(NSNumber*) percentPlayed fullyWatched: (BOOL) wasFullyWatched {
    AdapterTraceP(@"atPlaybackPercent : %@, fullyWatched : %d", percentPlayed, wasFullyWatched);
    
    if (wasFullyWatched) {
        [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    } else {
        AdapterLogP(@"%s Delegate is not setting or wasFullyWatched(%@) is false", __FUNCTION__, (wasFullyWatched ? @"true" : @"false"));
    }
}

@end

@implementation MovieInterstitial6011

@end

@implementation MovieInterstitial6012

@end

@implementation MovieInterstitial6013

@end

@implementation MovieInterstitial6014

@end

@implementation MovieInterstitial6015

@end

