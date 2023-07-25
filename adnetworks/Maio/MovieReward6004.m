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

@property (nonatomic) MaioInstance *maioInstance;
@property (nonatomic, strong) NSString *maioMediaId;
@property (nonatomic, strong) NSString *maioZoneId;
@property (nonatomic, assign) BOOL testFlg;

@end


@implementation MovieReward6004

//課題：ANDW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion {
    return Maio.sdkVersion;
}

+ (NSString *)getAdapterRevisionVersion {
    return @"10";
}

+ (NSString *)adnetworkClassName {
    return @"Maio";
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
        NSNumber *testFlg = [data objectForKey:@"test_flg"];
        if ([self isNotNull:testFlg] && [testFlg isKindOfClass:[NSNumber class]]) {
            self.testFlg = [testFlg boolValue];
        }
    }
    
    NSString *maioMediaId = [data objectForKey:@"media_id"];
    if ([self isNotNull:maioMediaId]) {
        self.maioMediaId = [NSString stringWithFormat:@"%@", maioMediaId];
    }

    NSString *maioZoneId = [data objectForKey:@"spot_id"];
    if ([self isNotNull:maioZoneId]) {
        self.maioZoneId = [NSString stringWithFormat:@"%@", maioZoneId];
    }

    AdapterLogP(@"%s maio media id %@, zone id %@", __func__, self.maioMediaId, self.maioZoneId);
}

-(BOOL)isPrepared {
    if (!self.delegate) {
        return NO;
    }
    
    BOOL result = false;
    if (self.maioZoneId && self.maioInstance) {
        AdapterLogP(@"maio zone id (%@) has instance %@", self.maioZoneId, self.maioInstance);
        result = [self.maioInstance canShowAtZoneId:self.maioZoneId];
    }
    AdapterLogP(@"maio zone id (%@) canShow : %d", self.maioZoneId, result);
    return result;
}

-(void)initAdnetworkIfNeeded {
    [[MovieDelegate6004 sharedInstance] setMovieReward:self inZone:self.maioZoneId];
    [self initCompleteAndRetryStartAdIfNeeded];
}

-(void)startAd {
    if (self.maioMediaId == nil) {
        return;
    }
    
    [super startAd];
    
    @try {
        [self requireToAsyncRequestAd];
        // テストモードに変更（リリース前必ず本番モードに戻してください）
        // [Maio setAdTestMode:YES];
        if(self.testFlg) {
            [Maio setAdTestMode:self.testFlg];
        }
        self.maioInstance = [[MovieDelegate6004 sharedInstance] startWithMediaId:self.maioMediaId];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

-(void)showAd {
    [self showAdWithPresentingViewController:[self topMostViewController]];
}

-(void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAd];

    if (self.maioZoneId && self.maioInstance) {
        if ([self.maioInstance canShowAtZoneId:self.maioZoneId]) {
            @try {
                [self requireToAsyncPlay];
                [self.maioInstance showAtZoneId:self.maioZoneId vc:viewController];
            }
            @catch (NSException *exception) {
                [self adnetworkExceptionHandling:exception];
            }
        }
    } else {
        if ([Maio canShow]) {
            @try {
                [self requireToAsyncPlay];
                [Maio showWithViewController:viewController];
            }
            @catch (NSException *exception) {
                [self adnetworkExceptionHandling:exception];
            }
        }
    }
}

-(void)dealloc {
    if(_maioMediaId != nil){
        _maioMediaId = nil;
    }
}
@end

@interface MovieDelegate6004 ()

@property (nonatomic) NSMutableDictionary *instances;

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
        _instances = [NSMutableDictionary new];
    }
    return self;
}

- (MaioInstance *)startWithMediaId:(NSString *)mediaId {
    MaioInstance *instance = [self.instances objectForKey:mediaId];
    if (instance) {
        NSLog(@"[ADF] Adnetwork Adapter Log %s maio %@ has instance", __func__, mediaId);
        return instance;
    }
    instance = [Maio startWithNonDefaultMediaId:mediaId delegate:self];
    [self.instances setObject:instance forKey:mediaId];
    NSLog(@"[ADF] Adnetwork Adapter Log %s maio %@ create instance", __func__, mediaId);
    return instance;
}

#pragma mark - MaioDelegate

/**
 *  全てのゾーンの広告表示準備が完了したら呼ばれます。
 */
- (void)maioDidInitialize {
    NSLog(@"[ADF] Adnetwork Adapter Log %s", __func__);
}

/**
 *  広告の配信可能状態が変更されたら呼ばれます。
 *
 *  @param zoneId   広告の配信可能状態が変更されたゾーンの識別子
 *  @param newValue 変更後のゾーンの状態。YES なら配信可能
 */
- (void)maioDidChangeCanShow:(NSString *)zoneId newValue:(BOOL)newValue {
    NSLog(@"[ADF] Adnetwork Adapter Log %s, zone id : %@, %d", __func__, zoneId, newValue);
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
    NSLog(@"[ADF] Adnetwork Adapter Log %s, zone id : %@", __func__, zoneId);
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
    NSLog(@"[ADF] Adnetwork Adapter Log %s, zone id : %@", __func__, zoneId);
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
    NSLog(@"[ADF] Adnetwork Adapter Log %s, zone id : %@", __func__, zoneId);
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
    NSLog(@"[ADF] Adnetwork Adapter Log %s, zone id : %@", __func__, zoneId);
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
    NSLog(@"[ADF] Adnetwork Adapter Log %s : zone id : %@, fail reason : %d", __func__, zoneId, (int)reason);
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
        case MaioFailReasonIncorrectMediaId:
            faileMessage =  @"IncorrectMediaId";
            break;
        case MaioFailReasonIncorrectZoneId:
            faileMessage =  @"IncorrectZoneId";
            break;
        case MaioFailReasonNotFoundViewContext:
            faileMessage =  @"NotFoundViewContext";
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
    
    NSLog(@"[ADF] Adnetwork Adapter Log Maio SDK Error:%@", faileMessage);
}

@end

@implementation MovieReward6100
@end

@implementation MovieReward6101
@end

@implementation MovieReward6102
@end

@implementation MovieReward6103
@end

@implementation MovieReward6104
@end
