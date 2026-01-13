//
//  MovieInterstitial6004.m
//  SampleViewRecipe
//
//  Created by Junhua Li on 2016/11/03.
//
//

#import "MovieInterstitial6004.h"
#import "Adnetworkconfigure6004.h"
#import "AdnetworkParam6004.h"

#import <Foundation/Foundation.h>
#import <ADFMovieReward/AdfurikunSdk.h>

@interface MovieInterstitial6004()

@property (nonatomic) MaioInterstitial *maioInstance;

@end

@implementation MovieInterstitial6004

// adapterファイルのRevision番号を返す。実装が変わる度Incrementする
+ (NSString *)getAdapterRevisionVersion {
    return @"3";
}

// Adnetwork実装時に使うClass名。SDKが導入されているかで使う
+ (NSString *)adnetworkClassName {
    return @"Maio.MaioInterstitial";
}

// ADFで定義しているAdnetwork名。
+ (NSString *)adnetworkName {
    return [Adnetworkconfigure6004 adnetworkName];
}

+ (NSString *)getSDKVersion {
    return [Adnetworkconfigure6004 getSDKVersion];
}

// Instance Variableを初期化する。また、必要な場合Configureを生成する
-(id)init {
    self = [super init];
    if (self) {
        self.configure = [Adnetworkconfigure6004 sharedInstance];
    }
    return self;
}

// Adnetwork Parameterを指定するAdnetworkParam Objectを生成する。
- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6004 alloc] initWithParam:data];
    self.configure.param = self.adParam; // Parameterを設定する
}

// Adnetwork SDKを初期化する
- (bool)initAdnetworkIfNeeded {
    if (![super initAdnetworkIfNeeded]) { // startAdが2重で実行されるケースを無くすため、１度のみ実行するように制限する
        return false;
    }
    [self initCompleteAndRetryStartAdIfNeeded];
    return true;
}

// 広告読み込みを開始する
- (bool)startAd {
    if (![super startAd]) { // 読み込みが可能な状態かをチェックする
        return false;
    }
    
    @try {
        [self requireToAsyncRequestAd];
        MaioRequest *request = [[MaioRequest alloc] initWithZoneId:((AdnetworkParam6004 *)self.adParam).maioZoneId
                                                          testMode:AdfurikunSdk.getTestMode];
        self.maioInstance = [MaioInterstitial loadAdWithRequest:request callback:self];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
    return true;
}

// 在庫取得有無を返す
- (BOOL)isPrepared {
    return self.isAdLoaded;
}

// 広告再生
- (void)showAd {
    [self showAdWithPresentingViewController:[self topMostViewController]];
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAdWithPresentingViewController:viewController];
    
    if (!self.maioInstance) {
        [self setPlayFailCallback:PlayFailCallbackReasonAdInstanceNil exception:nil];
        return;
    }

    if ([self isPrepared]) {
        @try {
            [self requireToAsyncPlay];
            [self.maioInstance showWithViewContext:viewController callback:self];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setPlayFailCallback:PlayFailCallbackReasonException exception:exception];
        }
    } else {
        [self setPlayFailCallback:PlayFailCallbackReasonIsPreparedFalse exception:nil];
    }
}


#pragma mark MaioInterstitialLoadCallback

- (void)didLoad:(MaioInterstitial * _Nonnull)ad {
    AdapterTrace;
    if (!self.isAdLoaded) {
        [self setCallbackStatus:MovieRewardCallbackFetchComplete];
    }
}

// https://github.com/imobile/MaioSDK-v2-iOS/wiki/API-Rererences#errorcode
- (void)didFail:(MaioInterstitial * _Nonnull)ad errorCode:(NSInteger)errorCode {
    AdapterTraceP(@"zone id : %@, error code : %d", ad.request.zoneId, (int)errorCode);
    [self setErrorWithMessage:@"" code:errorCode];

    // 0を含めて、1xxxx Error Codeは読み込み時のエラー
    if (errorCode <= 19999) {
        [self setCallbackStatus:MovieRewardCallbackFetchFail];
    } else { // 20000以上のError Codeは再生時のエラー
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

#pragma mark MaioInterstitialShowCallback

- (void)didOpen:(MaioInterstitial * _Nonnull)ad {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)didClose:(MaioInterstitial * _Nonnull)ad {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    [self setCallbackStatus:MovieRewardCallbackClose];
}

@end

@implementation MovieInterstitial6100
@end

@implementation MovieInterstitial6101
@end

@implementation MovieInterstitial6102
@end

@implementation MovieInterstitial6103
@end

@implementation MovieInterstitial6104
@end
