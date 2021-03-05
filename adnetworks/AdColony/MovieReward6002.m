//
//  MovieReward6002.m(AdColony)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import <ADFMovieReward/ADFMovieOptions.h>
#import "MovieReward6002.h"

@interface MovieReward6002()<AdColonyInterstitialDelegate>

@property (nonatomic, strong) NSString *adColonyAppId;
@property (nonatomic, strong) NSArray *adColonyAllZones;
@property (nonatomic, strong) NSString *adShowZoneId;
@property (nonatomic, weak) UIViewController* appViewController;
@property (nonatomic) BOOL test_flg;
@property (nonatomic) AdColonyInterstitial *ad;
@property (nonatomic) BOOL hasPendingStartAd;

@end

@implementation MovieReward6002

//課題：ANDW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion {
    return AdColony.getSDKVersion;
}

+ (NSString *)getAdapterRevisionVersion {
    return @"4";
}

-(id)init {
    self = [super init];
    if (self) {
        _appViewController = nil;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MovieReward6002 *newSelf = [super copyWithZone:zone];
    if (newSelf) {
        newSelf.appViewController = self.appViewController;
    }
    return newSelf;
}

/**
 *  データの設定
 */
-(void)setData:(NSDictionary *)data {
    [super setData:data];

    NSString *adColonyAppId = [data objectForKey:@"app_id"];
    if ([self isNotNull:adColonyAppId]) {
        _adColonyAppId = [NSString stringWithFormat:@"%@", adColonyAppId];
    }
    NSString *adShowZoneId = [data objectForKey:@"zone_id"];
    if ([self isNotNull:adShowZoneId]) {
        _adShowZoneId = [NSString stringWithFormat:@"%@", adShowZoneId];
    }
    
    NSArray *colonyAllZones = [data objectForKey:@"all_zones"];
    if ([self isNotNull:colonyAllZones] && [colonyAllZones isKindOfClass:[NSArray class]]) {
        _adColonyAllZones = colonyAllZones;
    }
    
    if (_adColonyAllZones == nil && _adShowZoneId != nil) {
        _adColonyAllZones = @[_adShowZoneId];
    }
    if (ADFMovieOptions.getTestMode) {
        self.test_flg = YES;
    } else {
        NSNumber *testFlg = [data objectForKey:@"test_flg"];
        if ([self isNotNull:testFlg] && [testFlg isKindOfClass:[NSNumber class]]) {
            self.test_flg = [testFlg boolValue];
        }
    }
}

-(BOOL)isPrepared {
    return self.delegate && self.ad && !self.ad.expired;
}

-(void)initAdnetworkIfNeeded {
    if (![self needsToInit]) {
        return;
    }
    // AdColonyの初期化は一度だけしか行わない
    // 初期化が失敗した場合はAdColonyが自分でリトライする
    static dispatch_once_t adfAdColonyOnceToken;
    dispatch_once(&adfAdColonyOnceToken, ^{
        @try {
            AdColonyAppOptions *options = nil;
            if (self.hasGdprConsent != nil) {
                options = [AdColonyAppOptions new];
                options.testMode = self.test_flg;
            }
            [AdColony configureWithAppID:self.adColonyAppId zoneIDs:self.adColonyAllZones options:options completion:^(NSArray<AdColonyZone *> * _Nonnull zones) {
                [self initCompleteAndRetryStartAdIfNeeded];
            }];
        } @catch (NSException *exception) {
            NSLog(@"adcolony configuration exception %@", exception);
        }
    });
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd {
    if (![self canStartAd]) {
        return;
    }
    @try {
        if (self.adShowZoneId) {
            [AdColony requestInterstitialInZone:_adShowZoneId options:nil andDelegate:self];
        }
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

/**
 *  広告の表示を行う
 */
-(void)showAd {
    [super showAd];

    UIViewController *topMostViewController = [self topMostViewController];
    if (topMostViewController) {
        @try {
            [_ad showWithPresentingViewController:topMostViewController];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    }

    if (topMostViewController == nil) {
        NSLog(@"Error encountered playing ad : could not fetch topmost viewcontroller");
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

/**
 *  広告の表示を行う
 */
-(void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAdWithPresentingViewController:viewController];

    // 表示を呼び出す
    if ([self isPrepared]) {
        @try {
            [_ad showWithPresentingViewController:viewController];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    }
}

/**
 * 対象のクラスがあるかどうか？
 */
-(BOOL)isClassReference {
    Class clazz = NSClassFromString(@"AdColony");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: AdColony");
        return NO;
    }
    return YES;
}

-(void)dealloc {
    if (_adColonyAppId != nil){
        _adColonyAppId = nil;
    }
    if (_adColonyAllZones != nil){
        _adColonyAllZones = nil;
    }
    if (_adShowZoneId != nil){
        _adShowZoneId = nil;
    }
    if (_appViewController != nil){
        _appViewController = nil;
    }
}

- (void)adColonyInterstitialDidLoad:(AdColonyInterstitial * _Nonnull)interstitial {
    NSLog(@"onAdColonyAdAvailabilityChange");
    
    self.ad = interstitial;
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

- (void)adColonyInterstitialDidFailToLoad:(AdColonyAdRequestError * _Nonnull)error {
    NSLog(@"Request failed with error: %@ and suggestion: %@", [error localizedDescription], [error localizedRecoverySuggestion]);
    [self setErrorWithMessage:error.localizedDescription code:error.code];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

- (void)adColonyInterstitialWillOpen:(AdColonyInterstitial *)interstitial {
    NSLog(@"onAdColonyAdStarted");
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)adColonyInterstitialDidClose:(AdColonyInterstitial *)interstitial {
    NSLog(@"onAdColonyAdFinished");
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    [self setCallbackStatus:MovieRewardCallbackClose];
}

- (void)adColonyInterstitialDidReceiveClick:(AdColonyInterstitial *)interstitial {
    NSLog(@"%s", __FUNCTION__);
}

- (void)adColonyInterstitialExpired:(AdColonyInterstitial *)interstitial {
    self.ad = nil;
}

@end
