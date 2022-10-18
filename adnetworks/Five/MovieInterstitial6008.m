//
//  MovieInterstitial6008.m(Five)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import "MovieInterstitial6008.h"
#import <ADFMovieReward/ADFMovieOptions.h>

#define kRetryTimeForNoCache 30.0

@interface MovieInterstitial6008()<FADLoadDelegate, FADAdViewEventListener>
@property (nonatomic)FADInterstitial *interstitial;
@property (nonatomic, strong)NSString *fiveAppId;
@property (nonatomic, strong)NSString *fiveSlotId;
@property (nonatomic, strong)NSString* submittedPackageName;
@property (nonatomic)BOOL testFlg;
@property (nonatomic)BOOL isReplay;
@property (nonatomic)BOOL didRetryForNoCache;
@property (nonatomic) BOOL requireToAsyncRequestAd;

@end

@implementation MovieInterstitial6008

//課題：ANDW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion {
    return FADSettings.version;
}

+ (NSString *)getAdapterRevisionVersion {
    return @"8.1";
}

-(id)init {
    self = [super init];
    if (self) {
        self.gdprStatus = kFADNeedGdprNonPersonalizedAdsTreatmentUnspecified;
    }
    return self;
}

- (void)setHasUserConsent:(BOOL)hasUserConsent {
    self.gdprStatus = (hasUserConsent) ? kFADNeedGdprNonPersonalizedAdsTreatmentFalse : kFADNeedGdprNonPersonalizedAdsTreatmentTrue;
}

/**
 *  データの設定
 *
 */
-(void)setData:(NSDictionary *)data {
    [super setData:data];
    
    NSString *fiveAppId = [data objectForKey:@"app_id"];
    if ([self isNotNull:fiveAppId]) {
        self.fiveAppId = [NSString stringWithFormat:@"%@", fiveAppId];
    }
    NSString *fiveSlotId = [data objectForKey:@"slot_id"];
    if ([self isNotNull:fiveSlotId]) {
        self.fiveSlotId = [NSString stringWithFormat:@"%@", fiveSlotId];
    }
    NSString *submittedPackageName = [data objectForKey:@"package_name"];
    if ([self isNotNull:submittedPackageName]) {
        self.submittedPackageName = [NSString stringWithFormat:@"%@", submittedPackageName];
    }

    if (ADFMovieOptions.getTestMode) {
        self.testFlg = YES;
    } else {
        NSNumber *testFlg = [data objectForKey:@"test_flg"];
        if ([self isNotNull:testFlg] && [testFlg isKindOfClass:[NSNumber class]]) {
            self.testFlg = [testFlg boolValue];
        }
    }
}

-(BOOL)isPrepared {
    //申請済のバンドルIDと異なる場合のメッセージ
    //(バンドルIDが申請済のものと異なると、正常に広告が返却されない可能性があります)
    if(![self.submittedPackageName isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
        //表示を消したい場合は、こちらをコメントアウトして下さい。
        NSLog(@"[ADF] [SEVERE] [Five]アプリのバンドルIDが、申請されたもの（%@）と異なります。", self.submittedPackageName);
    }
    
    if (self.interstitial) {
        return self.interstitial.state == kFADStateLoaded;
    }
    return NO;
}

-(void)initAdnetworkIfNeeded {
    if (![self needsToInit]) {
        return;
    }

    if (self.fiveAppId && self.fiveSlotId && [self.fiveAppId length] > 0 && [self.fiveSlotId length] > 0) {
        [self requireToAsyncInit];
        [MovieConfigure6008.sharedInstance configureWithAppId:self.fiveAppId isTest:self.testFlg gdprStatus:self.gdprStatus completion:^{
            [self initCompleteAndRetryStartAdIfNeeded];
        }];
    }
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd {
    NSLog(@"[ADF] Adnetwork 6008 %s", __FUNCTION__);
    
    if (![self canStartAd]) {
        return;
    }

    if (self.requireToAsyncRequestAd) {
        NSLog(@"[ADF] Adnetwork 6008 %s, requireToAsyncRequestAd is true", __FUNCTION__);
        return;
    }

    @try {
        [self requireToAsyncRequestAd];
        self.requireToAsyncRequestAd = true;
        NSLog(@"[ADF] Adnetwork 6008 %s interstitial load", __FUNCTION__);

        if (self.interstitial) {
            self.interstitial = nil;
        }
        self.interstitial = [[FADInterstitial alloc] initWithSlotId:self.fiveSlotId];
        [self.interstitial setLoadDelegate:self];
        [self.interstitial setAdViewEventListener:self];
        //音出力設定
        ADFMovieOptions_Sound soundState = [ADFMovieOptions getSoundState];
        if (ADFMovieOptions_Sound_On == soundState) {
            [self.interstitial enableSound:true];
        } else if (ADFMovieOptions_Sound_Off == soundState) {
            [self.interstitial enableSound:false];
        }
        
        [self.interstitial loadAdAsync];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}


/**
 *  広告の表示を行う
 */
-(void)showAd {
    [super showAd];
    
    if (self.interstitial) {
        @try {
            [self requireToAsyncPlay];
            BOOL res = [self.interstitial show];
            if (!res) {
                [self setCallbackStatus:MovieRewardCallbackPlayFail];
            }
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    }
}

-(void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [self showAd];
}

/**
 * 対象のクラスがあるかどうか？
 *
 */
-(BOOL)isClassReference {
    Class clazz = NSClassFromString(@"FADInterstitial");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: FiveAd");
        return NO;
    }
    return YES;
}

-(void)dealloc {
}

// ------------------------------ -----------------
// ここからはFiveのDelegateを受け取る箇所
#pragma mark -  FiveDelegate
- (void)fiveAdDidLoad:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
    self.requireToAsyncRequestAd = false;
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

- (void)fiveAd:(id<FADAdInterface>)ad didFailedToReceiveAdWithError:(FADErrorCode)errorCode {
    NSLog(@"Five SDK %s Errorcode:%ld, slotId : %@", __func__, (long)errorCode, self.fiveSlotId);
    [self setErrorWithMessage:nil code:errorCode];
    self.requireToAsyncRequestAd = false;
    [self setCallbackStatus:MovieRewardCallbackFetchFail];

    if (errorCode == kFADErrorCodeNoAd && self.didRetryForNoCache == false) {
        self.didRetryForNoCache = true;
        MovieInterstitial6008 __weak *weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kRetryTimeForNoCache * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [weakSelf startAd];
        });
    }
}

- (void)fiveAd:(id<FADAdInterface>)ad didFailedToShowAdWithError:(FADErrorCode)errorCode {
    NSLog(@"Five SDK %s Errorcode:%ld, slotId : %@", __func__, (long)errorCode, self.fiveSlotId);
    [self setErrorWithMessage:nil code:errorCode];
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}

- (void)fiveAdDidClick:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
}

- (void)fiveAdDidClose:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
    [self setCallbackStatus:MovieRewardCallbackClose];
}

- (void)fiveAdDidImpression:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
    self.isReplay = false;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)fiveAdDidPause:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
}

- (void)fiveAdDidReplay:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
    
    self.isReplay = true;
}

- (void)fiveAdDidResume:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
}

- (void)fiveAdDidViewThrough:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
    
    if (!self.isReplay) {
        [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    }
}

- (void)fiveAdDidStall:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
}

- (void)fiveAdDidRecover:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
}

@end

typedef enum : NSUInteger {
    initializeNotYet,
    initializing,
    initializeComplete,
} FADInitializeStatus;

@interface MovieConfigure6008()

@property (nonatomic) FADInitializeStatus initStatus;
@property (nonatomic) NSMutableArray <completionHandlerType> *handlers;

@end

@implementation MovieConfigure6008
+ (instancetype)sharedInstance {
    static MovieConfigure6008 *sharedInstance = nil;
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

- (void)configureWithAppId:(NSString *)fiveAppId
                    isTest:(BOOL)isTest
                gdprStatus:(FADNeedGdprNonPersonalizedAdsTreatment)gdprStatus
                completion:(completionHandlerType)completionHandler {
    if (!fiveAppId || !completionHandler) {
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
                FADConfig *config = [[FADConfig alloc] initWithAppId:fiveAppId];
                if (isTest) {
                    config.isTest =  YES;
                }
                
                config.needGdprNonPersonalizedAdsTreatment = gdprStatus;
                NSLog(@"[ADF] Adnetwork 6008, sdk setting value : %d", (int)gdprStatus);

                [FADSettings registerConfig:config];

                self.initStatus = initializeComplete;

                for (completionHandlerType handler in self.handlers) {
                    handler();
                }
            } @catch (NSException *exception) {
                NSLog(@"adnetwork exception : %@", exception);
            }
        });
    }
}

@end

@implementation MovieInterstitial6070

@end

@implementation MovieInterstitial6071

@end

@implementation MovieInterstitial6072

@end
