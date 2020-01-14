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

@end

@implementation MovieReward6002

static BOOL hasConfigured = NO;

//課題：ANDW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion {
    return AdColony.getSDKVersion;
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
    _adColonyAppId = [data objectForKey:@"app_id"];
    _adShowZoneId = [data objectForKey:@"zone_id"];
    
    NSArray *colonyAllZones = [data objectForKey:@"all_zones"];
    _adColonyAllZones = colonyAllZones;
    
    if (_adColonyAllZones == nil) {
        _adColonyAllZones = @[_adShowZoneId];
    }
    if (ADFMovieOptions.getTestMode) {
        self.test_flg = YES;
    } else {
        self.test_flg = [[data objectForKey:@"test_flg"] boolValue];
    }
}

-(BOOL)isPrepared {
    return self.delegate && self.ad && !self.ad.expired;
}

-(void)initAdnetworkIfNeeded {
    // AdColonyの初期化は一度だけしか行わない
    // 初期化が失敗した場合はAdColonyが自分でリトライする
    static dispatch_once_t adfAdColonyOnceToken;
    dispatch_once(&adfAdColonyOnceToken, ^{
        AdColonyAppOptions *options = nil;
        if (self.hasGdprConsent != nil) {
            options = [AdColonyAppOptions new];
            options.gdprRequired = self.hasGdprConsent.boolValue;
            options.gdprConsentString = @"gdpr";
            options.testMode = self.test_flg;
        }
        [AdColony configureWithAppID:_adColonyAppId zoneIDs:_adColonyAllZones options:options completion:^(NSArray<AdColonyZone *> * _Nonnull zones) {
            hasConfigured = YES;
        }];
    });
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd {
    // 初期化に成功したら以降はインタースティシャルのリクエストのみ行う
    if (hasConfigured) {
        [AdColony requestInterstitialInZone:_adShowZoneId options:nil andDelegate:self];
    }
}

/**
 *  広告の表示を行う
 */
-(void)showAd {
    UIViewController *topMostViewController = [self topMostViewController];
    if (topMostViewController) {
        [_ad showWithPresentingViewController:topMostViewController];
    }

    if (topMostViewController == nil) {
        NSLog(@"Error encountered playing ad : could not fetch topmost viewcontroller");
        if (self.delegate) {
            if ([self.delegate respondsToSelector:@selector(AdsPlayFailed:)]) {
                [self.delegate AdsPlayFailed:self];
            } else {
                NSLog(@"%s AdsPlayFailed selector is not responding", __FUNCTION__);
            }
        } else {
            NSLog(@"%s Delegate is not setting", __FUNCTION__);
        }
    }
}

/**
 *  広告の表示を行う
 */
-(void)showAdWithPresentingViewController:(UIViewController *)viewController {
    // 表示を呼び出す
    if ([self isPrepared]) {
        [_ad showWithPresentingViewController:viewController];
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
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsFetchCompleted:)]) {
            [self.delegate AdsFetchCompleted:self];
        } else {
            NSLog(@"%s AdsFetchCompleted selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

- (void)adColonyInterstitialDidFailToLoad:(AdColonyAdRequestError * _Nonnull)error {
    NSLog(@"Request failed with error: %@ and suggestion: %@", [error localizedDescription], [error localizedRecoverySuggestion]);
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsFetchError:)]) {
            [self setErrorWithMessage:error.localizedDescription code:error.code];
            [self.delegate AdsFetchError:self];
        } else {
            NSLog(@"%s AdsFetchError selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

- (void)adColonyInterstitialWillOpen:(AdColonyInterstitial *)interstitial {
    NSLog(@"onAdColonyAdStarted");
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidShow:)]) {
            [self.delegate AdsDidShow:self];
        } else {
            NSLog(@"%s AdsDidShow selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

- (void)adColonyInterstitialDidClose:(AdColonyInterstitial *)interstitial {
    NSLog(@"onAdColonyAdFinished");
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(AdsDidCompleteShow:)]) {
            [self.delegate AdsDidCompleteShow:self];
        } else {
            NSLog(@"%s AdsDidCompleteShow selector is not responding", __FUNCTION__);
        }
        if ([self.delegate respondsToSelector:@selector(AdsDidHide:)]) {
            [self.delegate AdsDidHide:self];
        } else {
            NSLog(@"%s AdsDidHide selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

- (void)adColonyInterstitialDidReceiveClick:(AdColonyInterstitial *)interstitial {
    NSLog(@"%s", __FUNCTION__);
}

- (void)adColonyInterstitialExpired:(AdColonyInterstitial *)interstitial {
    self.ad = nil;
}

@end
