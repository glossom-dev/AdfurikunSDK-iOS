//
//  MovieReward6005.m (Tapjoy)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//
#import <UIKit/UIKit.h>
#import "MovieReward6005.h"
#import <ADFMovieReward/ADFMovieOptions.h>

#import <Tapjoy/Tapjoy.h>

@interface MovieReward6005()
@property (nonatomic, assign)BOOL test_flg;
@property (nonatomic, strong)NSString* placement_id;
@property (nonatomic, strong)NSString* sdkKey;
@property (nonatomic) BOOL isNeedStartAd;
@property (nonatomic) BOOL isConnectionFail;

@end

@implementation MovieReward6005

//課題：ANDW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion {
    return Tapjoy.getVersion;
}

+ (NSString *)getAdapterRevisionVersion {
    return @"9";
}

- (id)init {
    self = [super init];
    if (self) {
        _p = nil;
        _isNeedStartAd = NO;
        _isConnectionFail = NO;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MovieReward6005 *newSelf = [super copyWithZone:zone];
    if (newSelf) {
        newSelf.p = self.p;
        newSelf.isNeedStartAd = self.isNeedStartAd;
    }
    return newSelf;
}

/**
 *  データの設定
 */
-(void)setData:(NSDictionary *)data {
    [super setData:data];
    
    NSString *placement_id = [data objectForKey:@"placement_id"];
    if ([self isNotNull:placement_id]) {
        self.placement_id = [NSString stringWithFormat:@"%@", placement_id];
    }

    NSString *sdkKey = [data objectForKey:@"sdk_key"];
    if ([self isNotNull:sdkKey]) {
        self.sdkKey = [NSString stringWithFormat:@"%@", sdkKey];
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

-(void)initAdnetworkIfNeeded {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @try {
            //Set up success and failure notifications
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(tjcConnectSuccess:)
                                                         name:TJC_LIMITED_CONNECT_SUCCESS
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(tjcConnectFail:)
                                                         name:TJC_LIMITED_CONNECT_FAILED
                                                       object:nil];
            
            [Tapjoy limitedConnect:self.sdkKey];
            [Tapjoy setDebugEnabled:self.test_flg];
            
            MovieDelegate6005 *delegate = [MovieDelegate6005 sharedInstance];
            [delegate setMovieReward:self inZone:self.placement_id];
            
            _p = [TJPlacement limitedPlacementWithName:_placement_id mediationAgent:@"adfully" delegate:delegate];
            _p.videoDelegate = delegate;
            _p.adapterVersion = @"1.0.1";
            
            [self initCompleteAndRetryStartAdIfNeeded];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    });
    AdapterLog(@"initAdnetworkIfNeeded end");
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd {
    if (![self canStartAd]) {
        return;
    }

    if (self.sdkKey && self.placement_id && self.p) {
        [super startAd];
        @try {
            if (![Tapjoy isLimitedConnected]) {
                self.isNeedStartAd = YES;
                
                if (self.isConnectionFail) {
                    [Tapjoy limitedConnect:self.sdkKey];
                }
                
                return;
            }
            [self requireToAsyncRequestAd];
            [_p requestContent];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    }
}

-(BOOL)isPrepared {
    if (!_p) {
        return NO;
    }
    if ([_p isKindOfClass:[TJPlacement class]]) {
        return self.isAdLoaded && _p.isContentAvailable && _p.isContentReady;
    }
    return NO;
}

/**
 *  広告の表示を行う
 */
-(void)showAd {
    UIViewController *topMostVC = [self topMostViewController];
    if (topMostVC) {
        [self showAdWithPresentingViewController:topMostVC];
    } else {
        MovieDelegate6005 *delegate = [MovieDelegate6005 sharedInstance];
        [delegate setCallbackStatus:MovieRewardCallbackPlayFail zone:self.placement_id];
    }
}

-(void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAdWithPresentingViewController:viewController];

    AdapterLog(@"showAdWithPresentingViewController");
    //引数に nil を渡すと弊社SDK側で再前面、全画面の View を推定して表示します。
    //多くの場合にはこれで正常に動作するのですが、View階層が複雑な場合は指定していただく必要があるケースも出ています。
    if (_p.isContentAvailable) {
        //渡したviewControllerを強制的にご利用したい場合、必ずテストしてください。
        @try {
            [self requireToAsyncPlay];
            
            [_p showContentWithViewController:viewController];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            MovieDelegate6005 *delegate = [MovieDelegate6005 sharedInstance];
            [delegate setCallbackStatus:MovieRewardCallbackPlayFail zone:self.placement_id];
        }
    }
}

/**
 * 対象のクラスがあるかどうか？
 */
-(BOOL)isClassReference {
    Class clazz = NSClassFromString(@"Tapjoy");
    if (clazz) {
        AdapterLog(@"found Class: Tapjoy");
    }
    else {
        AdapterLog(@"Not found Class: Tapjoy");
        return NO;
    }
    return YES;
}

-(void)setHasUserConsent:(BOOL)hasUserConsent {
    [super setHasUserConsent:hasUserConsent];
    TJPrivacyPolicy *privacyPolicy = [Tapjoy getPrivacyPolicy];
    [privacyPolicy setSubjectToGDPR: YES];
    [privacyPolicy setUserConsent:hasUserConsent ? @"1" : @"0"];
    AdapterLogP(@"Adnetwork 6005, gdprConsent : %@, sdk setting value : %@", self.hasGdprConsent, hasUserConsent ? @"1" : @"0");
}

- (void)isChildDirected:(BOOL)childDirected {
    [super isChildDirected:childDirected];
    TJPrivacyPolicy *privacyPolicy = [Tapjoy getPrivacyPolicy];
    [privacyPolicy setBelowConsentAge:childDirected];
    AdapterLogP(@"Adnetwork %@, childDirected : %@, input parameter : %d", self.adnetworkKey, self.childDirected, (int)childDirected);
}

-(void)dealloc {
    if(_p != nil){
        _p = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//-----------------AppDelegate内の処理を移動--------------------------------------
-(void)tjcConnectSuccess:(NSNotification*)notifyObj {
    AdapterTrace;
    if (self.isNeedStartAd) {
        [self startAd];
    }
    self.isConnectionFail = NO;
}

- (void)tjcConnectFail:(NSNotification*)notifyObj {
    AdapterTrace;
    self.isConnectionFail = YES;
}

@end


@interface MovieDelegate6005()
@end

@implementation MovieDelegate6005

+ (instancetype)sharedInstance {
    static MovieDelegate6005 *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super new];
    });
    return sharedInstance;
}

- (void)performAdsFetchError:(TJPlacement *)placement error:(NSError *)error {
    NSLog(@"[ADF] Tapjoy load error\n %@", error);
    ADFmyMovieRewardInterface *movieReward = [self getMovieRewardWithZone:placement.placementName];
    if (error) {
        [movieReward setErrorWithMessage:error.localizedDescription code:error.code];
    }
    [self setCallbackStatus:MovieRewardCallbackFetchFail zone:placement.placementName];
}

#pragma mark - TJPlacementDelegate

// SDKがTapjoyのサーバーにコンタクトした際に呼ばれます。但し、必ずしもコンテンツを利用可能であることを意味する訳ではありません。
- (void)requestDidSucceed:(TJPlacement*)placement {
    NSLog(@"[ADF] requestDidSucceed isContentAvailable : %d", placement.isContentAvailable);
    if (!placement.isContentAvailable) { // Loading失敗のケースあり
        [self performAdsFetchError:placement error:nil];
    }
}

// Tapjoyのサーバーにコネクトする途中で問題が発生した際に呼ばれます。
- (void)requestDidFail:(TJPlacement*)placement error:(NSError*)error {
    NSLog(@"[ADF] %s", __FUNCTION__);
    [self performAdsFetchError:placement error:error];
}

// コンテンツが表示可能となった際に呼ばれます。
- (void)contentIsReady:(TJPlacement*)placement {
    NSLog(@"[ADF] %s", __FUNCTION__);
    // 広告準備完了
    [self setCallbackStatus:MovieRewardCallbackFetchComplete zone:placement.placementName];
}

// コンテンツが表示される際に呼ばれます。
- (void)contentDidAppear:(TJPlacement*)placement {
    NSLog(@"[ADF] %s", __FUNCTION__);
    [self setCallbackStatus:MovieRewardCallbackPlayStart zone:placement.placementName];
}

// コンテンツが退去される際に呼ばれます。
- (void)contentDidDisappear:(TJPlacement*)placement {
    NSLog(@"[ADF] %s", __FUNCTION__);
    [self setCallbackStatus:MovieRewardCallbackClose zone:placement.placementName];
}

- (void)didClick:(TJPlacement *)placement {
    NSLog(@"[ADF] %s", __FUNCTION__);
}

#pragma mark - TJPlacementVideoDelegate

- (void)videoDidStart:(TJPlacement *)placement {
    NSLog(@"[ADF] %s", __FUNCTION__);
}

/** 動画を最後まで視聴した際に呼ばれます。 */
- (void)videoDidComplete:(TJPlacement *)placement {
    NSLog(@"[ADF] %s", __FUNCTION__);
    [self setCallbackStatus:MovieRewardCallbackPlayComplete zone:placement.placementName];
}

- (void)videoDidFail:(TJPlacement *)placement error:(NSString *)errorMsg {
    NSLog(@"[ADF] %s, error : %@", __FUNCTION__, errorMsg);
    ADFmyMovieRewardInterface *movieReward = [self getMovieRewardWithZone:placement.placementName];
    [movieReward setErrorWithMessage:errorMsg code:0];
    [self setCallbackStatus:MovieRewardCallbackPlayFail zone:placement.placementName];
}

@end

@implementation MovieReward6170
@end

@implementation MovieReward6171
@end

@implementation MovieReward6172
@end

@implementation MovieReward6173
@end

@implementation MovieReward6174
@end
