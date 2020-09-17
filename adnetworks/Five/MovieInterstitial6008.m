//
//  MovieInterstitial6008.m(Five)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import "MovieInterstitial6008.h"
#import <ADFMovieReward/ADFMovieOptions.h>

#define kRetryTimeForNoCache 30.0

@interface MovieInterstitial6008()<FADDelegate>
@property (nonatomic)FADInterstitial *interstitial;
@property (nonatomic, strong)NSString *fiveAppId;
@property (nonatomic, strong)NSString *fiveSlotId;
@property (nonatomic, strong)NSString* submittedPackageName;
@property (nonatomic)BOOL testFlg;
@property (nonatomic)BOOL isReplay;
@property (nonatomic)BOOL didRetryForNoCache;

@end

@implementation MovieInterstitial6008

//課題：ANDW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion {
    return FADSettings.version;
}

+(NSString *)getAdapterVersion {
    return @"20200909.1";
}

-(id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

/**
 *  データの設定
 *
 */
-(void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.fiveAppId = [NSString stringWithFormat:@"%@", [data objectForKey:@"app_id"]];
    self.fiveSlotId = [NSString stringWithFormat:@"%@", [data objectForKey:@"slot_id"]];
    self.submittedPackageName = [data objectForKey:@"package_name"];
    if (ADFMovieOptions.getTestMode) {
        self.testFlg = YES;
    } else {
        self.testFlg = [[data objectForKey:@"test_flg"] boolValue];
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
    if ([self.fiveAppId length] > 0 && [self.fiveSlotId length] > 0) {
        [MovieConfigure6008 configureWithAppId:self.fiveAppId isTest:self.testFlg];
    }
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd {
    if (self.interstitial) {
        self.interstitial = nil;
    }
    self.interstitial = [[FADInterstitial alloc] initWithSlotId:self.fiveSlotId];
    self.interstitial.delegate = self;
    //音出力設定
    ADFMovieOptions_Sound soundState = [ADFMovieOptions getSoundState];
    if (ADFMovieOptions_Sound_On == soundState) {
        [self.interstitial enableSound:true];
    } else if (ADFMovieOptions_Sound_Off == soundState) {
        [self.interstitial enableSound:false];
    }

    [self.interstitial loadAdAsync];
}


/**
 *  広告の表示を行う
 */
-(void)showAd {
    [super showAd];

    if (self.interstitial) {
        BOOL res = [self.interstitial show];
        if (!res) {
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

/**
 *  広告の読み込みを中止
 *
 */
-(void)cancel {
}

// ------------------------------ -----------------
// ここからはFiveのDelegateを受け取る箇所
#pragma mark -  FiveDelegate
- (void)fiveAdDidLoad:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

- (void)fiveAd:(id<FADAdInterface>)ad didFailedToReceiveAdWithError:(FADErrorCode)errorCode {
    NSLog(@"Five SDK %s Errorcode:%ld, slotId : %@", __func__, (long)errorCode, self.fiveSlotId);
    [self setErrorWithMessage:nil code:errorCode];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];

    if (errorCode == kFADErrorNoCachedAd && self.didRetryForNoCache == false) {
        self.didRetryForNoCache = true;
        MovieInterstitial6008 __weak *weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kRetryTimeForNoCache * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [weakSelf startAd];
        });
    }
}

- (void)fiveAdDidClick:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
}

- (void)fiveAdDidClose:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
    [self setCallbackStatus:MovieRewardCallbackClose];
}

- (void)fiveAdDidStart:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
    
    self.isReplay = NO;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)fiveAdDidPause:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
}

- (void)fiveAdDidReplay:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
    
    self.isReplay = YES;
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


@end

@implementation MovieConfigure6008
+ (void)configureWithAppId:(NSString *)fiveAppId isTest:(BOOL)isTest {
    static dispatch_once_t adfFiveOnceToken;
    dispatch_once_on_main_thread(&adfFiveOnceToken, ^{
        FADConfig *config = [[FADConfig alloc] initWithAppId:fiveAppId];
        config.fiveAdFormat = [NSSet setWithObjects:
                               [NSNumber numberWithInt:kFADFormatVideoReward],
                               [NSNumber numberWithInt:kFADFormatCustomLayout],
                               nil];
        if (isTest) {
            config.isTest =  YES;
        }
        
        int age = ADFMovieOptions.getUserAge;
        if (age >= 18) {
            config.maxAdAgeRating = kFADAdAgeRatingAge18AndOver;
        } else if (age >= 15) {
            config.maxAdAgeRating = kFADAdAgeRatingAge15AndOver;
        } else if (age >= 13) {
            config.maxAdAgeRating = kFADAdAgeRatingAge13AndOver;
        } else {
            config.maxAdAgeRating = kFADAdAgeRatingUnspecified;
        }

        if (![FADSettings isConfigRegistered]) {
            [FADSettings registerConfig:config];
        }
    });
}

void dispatch_once_on_main_thread(dispatch_once_t *predicate,
                                  dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        dispatch_once(predicate, block);
    } else {
        if (DISPATCH_EXPECT(*predicate == 0L, NO)) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                dispatch_once(predicate, block);
            });
        }
    }
}
@end

