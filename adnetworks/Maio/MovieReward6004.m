//
//  MovieReword6004.m
//  SampleViewRecipe
//
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//
#import "MovieReward6004.h"
#import <Foundation/Foundation.h>
#import <ADFMovieReward/ADFMovieOptions.h>

@interface MovieReward6004()

@property (nonatomic, strong) NSString *maioMediaId;
@property (nonatomic, strong) NSString *maioZoneId;
@property (nonatomic, assign) BOOL testFlg;

@end


@implementation MovieReward6004

//課題：ANDW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion {
    return Maio.sdkVersion;
}

-(id)init {
    self = [super init];
    
    if ( self ) {
    }
    
    return self;
}

-(void)setData:(NSDictionary *)data {
    [super setData:data];
    
    if (ADFMovieOptions.getTestMode) {
        self.testFlg = YES;
    } else {
        self.testFlg = [[data objectForKey:@"test_flg"] boolValue];
    }
    self.maioMediaId = [NSString stringWithFormat:@"%@", [data objectForKey:@"media_id"]];
    if ([data objectForKey:@"spot_id"]) {
        NSString *spotId = [NSString stringWithFormat:@"%@", [data objectForKey:@"spot_id"]];
        if ([spotId length] > 0) {
            self.maioZoneId = spotId;
        }
    }
    //広告の読み込みがmediaID単位で行われることにより
    //startAdより前にisPrepared=trueになって広告が再生されるケースがあるため
    [[MovieDelegate6004 sharedInstance] setMovieReward:self inZone:self.maioZoneId];
}

-(BOOL)isPrepared {
    if (!self.delegate) {
        NSAssert(NO, @"self.delegate must not be nil");
        return NO;
    }
    if (self.maioZoneId) {
        return [Maio canShowAtZoneId:self.maioZoneId];
    } else {
        return [Maio canShow];
    }
}

-(void)startAd {
    // 動画の読み込みを開始します。
    static dispatch_once_t adfMaioOnceToken;
    dispatch_once(&adfMaioOnceToken, ^{
        // テストモードに変更（リリース前必ず本番モードに戻してください）
        // [Maio setAdTestMode:YES];
        if(self.testFlg) {
            [Maio setAdTestMode:self.testFlg];
        }
        [Maio startWithMediaId:self.maioMediaId delegate:[MovieDelegate6004 sharedInstance]];
    });
}

-(void)showAd {
    [self showAdWithPresentingViewController:[self topMostViewController]];
}

-(void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAd];

    if (self.maioZoneId) {
        if ([Maio canShowAtZoneId:self.maioZoneId]) {
            @try {
                [Maio showAtZoneId:self.maioZoneId vc:viewController];
            }
            @catch (NSException *exception) {
                NSLog(@"Maio zone id %@ has exception name[%@] description[%@]", self.maioZoneId, exception.name, exception.description);
            }
        }
    } else {
        if ([Maio canShow]) {
            @try {
                [Maio showWithViewController:viewController];
            }
            @catch (NSException *exception) {
                NSLog(@"Maio has exception name[%@] description[%@]", exception.name, exception.description);
            }
        }
    }
}

-(BOOL)isClassReference {
    Class clazz = NSClassFromString(@"Maio");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: Maio");
        return NO;
    }
    return YES;
}

-(void)cancel {
    // Maio には対象の処理がないので、何もしない。
}

-(void)dealloc {
    if(_maioMediaId != nil){
        _maioMediaId = nil;
    }
}
@end

@implementation MovieDelegate6004

+ (instancetype)sharedInstance {
    static MovieDelegate6004 *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super new];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _closeFlg = NO;
    }
    return self;
}

#pragma mark - MaioDelegate

/**
 *  全てのゾーンの広告表示準備が完了したら呼ばれます。
 */
- (void)maioDidInitialize {
    NSLog(@"%s", __func__);
}

/**
 *  広告の配信可能状態が変更されたら呼ばれます。
 *
 *  @param zoneId   広告の配信可能状態が変更されたゾーンの識別子
 *  @param newValue 変更後のゾーンの状態。YES なら配信可能
 */
- (void)maioDidChangeCanShow:(NSString *)zoneId newValue:(BOOL)newValue {
    NSLog(@"%s", __func__);
    if (newValue) {
        [self setCallbackStatus:MovieRewardCallbackFetchComplete zone:zoneId];
    }
}

/**
 *  広告が再生される直前に呼ばれます。
 *  最初の再生開始の直前にのみ呼ばれ、リプレイ再生の直前には呼ばれません。
 *
 *  @param zoneId  広告が表示されるゾーンの識別子
 */
- (void)maioWillStartAd:(NSString *)zoneId {
    NSLog(@"%s", __func__);
    self.closeFlg = NO;
    // WillShow はないので、DidShow で
    [self setCallbackStatus:MovieRewardCallbackPlayStart zone:zoneId];
}

/**
 *  広告の再生が終了したら呼ばれます。
 *  最初の再生終了時にのみ呼ばれ、リプレイ再生の終了時には呼ばれません。
 *
 *  @param zoneId  広告を表示したゾーンの識別子
 *  @param playtime 動画の再生時間（秒）
 *  @param skipped  動画がスキップされていたら YES、それ以外なら NO
 *  @param rewardParam  ゾーンがリワード型に設定されている場合、予め管理画面にて設定してある任意の文字列パラメータが渡されます。それ以外の場合は nil
 */
- (void)maioDidFinishAd:(NSString *)zoneId playtime:(NSInteger)playtime skipped:(BOOL)skipped rewardParam:(NSString *)rewardParam {
    NSLog(@"%s", __func__);
    if (!skipped) {
        [self setCallbackStatus:MovieRewardCallbackPlayComplete zone:zoneId];
    }
}

/**
 *  広告がクリックされ、ストアや外部リンクへ遷移した時に呼ばれます。
 *
 *  @param zoneId  広告を表示したゾーンの識別子
 */
- (void)maioDidClickAd:(NSString *)zoneId {
    NSLog(@"%s", __func__);
}

/**
 *  広告が閉じられた際に呼ばれます。
 *
 *  @param zoneId  広告を表示したゾーンの識別子
 */
- (void)maioDidCloseAd:(NSString *)zoneId {
    if (self.closeFlg) {
        return;
    }
    self.closeFlg = YES;
    NSLog(@"%s", __func__);
    [self setCallbackStatus:MovieRewardCallbackClose zone:zoneId];
}

/**
 *  SDK でエラーが生じた際に呼ばれます。
 *
 *  @param zoneId  エラーに関連するゾーンの識別子
 *  @param reason   エラーの理由を示す列挙値
 */
- (void)maioDidFail:(NSString *)zoneId reason:(MaioFailReason)reason {
    // ログ表示
    NSLog(@"%s", __func__);
    NSString *faileMessage;
    
    switch ((int)reason) {
        case MaioFailReasonUnknown:
            faileMessage =  @"Unknown";
            break;
        case MaioFailReasonNetworkConnection:
            faileMessage =  @"NetworkConnection";
            break;
        case MaioFailReasonNetworkServer:
            faileMessage =  @"NetworkServer";
            break;
        case MaioFailReasonNetworkClient:
            faileMessage =  @"NetworkClient";
            break;
        case MaioFailReasonSdk:
            faileMessage =  @"Sdk";
            break;
        case MaioFailReasonDownloadCancelled:
            faileMessage =  @"DownloadCancelled";
            break;
        case MaioFailReasonAdStockOut:
            faileMessage =  @"AdStockOut";
            break;
    }
    if (faileMessage) {
        ADFmyMovieRewardInterface *movieReward = [self getMovieRewardWithZone:zoneId];
        [movieReward setErrorWithMessage:faileMessage code:0];
        [self setCallbackStatus:MovieRewardCallbackFetchFail zone:zoneId];
    }

    if (reason == MaioFailReasonVideoPlayback) {
        faileMessage = @"VideoPlayback";
        [self setCallbackStatus:MovieRewardCallbackPlayFail zone:zoneId];
    }
    
    NSLog(@"Maio SDK Error:%@", faileMessage);
}

@end
