//
//  MovieReward6006.m(Vungle)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//
#import <UIKit/UIKit.h>
#import "MovieReward6006.h"
#import <ADFMovieReward/ADFMovieOptions.h>

@interface MovieReward6006()
@property (nonatomic, strong)NSString* vungleAppID;
@property (nonatomic) NSString *placementID;
@property (nonatomic) NSArray *allPlacementIDs;
@property (nonatomic) BOOL isNeedToStartAd;

@end

@implementation MovieReward6006

//課題：ADNW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion {
    return VungleSDKVersion;
}

+ (NSString *)getAdapterRevisionVersion {
    return @"5";
}

- (id)init{
    self = [super init];
    if(self){
        _allPlacementIDs = [NSArray new];
        _isNeedToStartAd = NO;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MovieReward6006 *newSelf = [super copyWithZone:zone];
    if (newSelf) {
        newSelf.vungleAppID = self.vungleAppID;
        newSelf.placementID = self.placementID;
        newSelf.allPlacementIDs = self.allPlacementIDs;
        newSelf.isNeedToStartAd = self.isNeedToStartAd;
    }
    return newSelf;
}

/**
 *  データの設定
 */
-(void)setData:(NSDictionary *)data
{
    [super setData:data];
    
    NSLog(@"data : %@",data);
    
    NSString* vungleAppID = [data objectForKey:@"application_id"];
    if ([self isNotNull:vungleAppID]) {
        self.vungleAppID = [[NSString alloc] initWithFormat:@"%@", vungleAppID];
    }
    NSString *placementID = [data objectForKey:@"placement_reference_id"];
    if ([self isNotNull:placementID]) {
        self.placementID = [NSString stringWithFormat:@"%@", placementID];
    }
    NSArray *placementIDs = [data objectForKey:@"all_placements"];
    if ([self isNotNull:placementIDs] && [placementIDs isKindOfClass:[NSArray class]]) {
        self.allPlacementIDs = [NSArray arrayWithArray:placementIDs];
    }

    if (self.vungleAppID == nil || self.placementID == nil) {
        NSLog(@"%s Vungle data is invalid", __PRETTY_FUNCTION__);
        return;
    }
    if (self.allPlacementIDs.count == 0) {
        self.allPlacementIDs = @[self.placementID];
    }
}

- (void)initVungle {
    @try {
        if ([VungleSDK sharedSDK].isInitialized) {
            return;
        }
        NSError *error;
        if (![[VungleSDK sharedSDK] startWithAppId:self.vungleAppID error:&error]) {
            NSLog(@"Error while starting VungleSDK %@", [error localizedDescription]);
        }
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

-(void)initAdnetworkIfNeeded {
    if (self.placementID == nil || self.vungleAppID == nil) {
        return;
    }
    
    MovieDelegate6006 *delegate = [MovieDelegate6006 sharedInstance];
    [delegate setMovieReward:self inZone:self.placementID];
    [[VungleSDK sharedSDK] setDelegate:delegate];
    [[VungleSDK sharedSDK] setLoggingEnabled:YES];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self initVungle];
    });
    //音出力設定
    ADFMovieOptions_Sound soundState = [ADFMovieOptions getSoundState];
    if (ADFMovieOptions_Sound_On == soundState) {
        [[VungleSDK sharedSDK] setMuted:false];
    } else if (ADFMovieOptions_Sound_Off == soundState) {
        [[VungleSDK sharedSDK] setMuted:true];
    }
    [self initCompleteAndRetryStartAdIfNeeded];
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd
{
    if (![self canStartAd]) {
        return;
    }

    @try {
        VungleSDK *sdk = [VungleSDK sharedSDK];
        if (!sdk.initialized) {
            self.isNeedToStartAd = YES;
            return;
        }
        
        [self requireToAsyncRequestAd];
        
        NSError *error = nil;
        if (![sdk loadPlacementWithID:self.placementID error:&error]) {
            NSLog(@"Unable to load vungle placement with reference ID :%@, Error %@", self.placementID, error);
            [self setErrorWithMessage:error.localizedDescription code:error.code];
            [self setCallbackStatus:MovieRewardCallbackFetchFail];
        }
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

-(BOOL)isPrepared{
    if (!self.delegate) {
        return NO;
    }
    return [[VungleSDK sharedSDK] isAdCachedForPlacementID:self.placementID];
}

/**
 *  広告の表示を行う
 */
-(void)showAd
{
    [super showAd];

    VungleSDK* sdk = [VungleSDK sharedSDK];
    NSError* error;

    //[VUNGLESDK] WARNING: The topmost presented ViewController <XXX> is not equal to the one being passed to the `playAd` method <YYY>
    UIViewController *topMostViewController = [self topMostViewController];
    if (topMostViewController) {
        @try {
            [self requireToAsyncPlay];
            
            [sdk playAd:topMostViewController options:nil placementID:self.placementID error:&error];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    }

    if (topMostViewController == nil || error) {
        NSLog(@"Error encountered playing ad : %@", error);
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

-(void)showAdWithPresentingViewController:(UIViewController *)viewController
{
    [super showAdWithPresentingViewController:viewController];

    VungleSDK* sdk = [VungleSDK sharedSDK];
    NSError* error;
    
    @try {
        [self requireToAsyncPlay];
        
        [sdk playAd:viewController options:nil placementID:self.placementID error:&error];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }

    if (error) {
        NSLog(@"Error encountered playing ad : %@", error);
        [self setErrorWithMessage:error.localizedDescription code:error.code];
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

/**
 * 対象のクラスがあるかどうか？
 */
-(BOOL)isClassReference
{
    NSLog(@"MovieReward6006 isClassReference");
    Class clazz = NSClassFromString(@"VungleSDK");
    if (clazz) {
        NSLog(@"Found Class: Vungle");
    }
    else {
        NSLog(@"Not found Class: Vungle");
        return NO;
    }
    return YES;
}

-(void)setHasUserConsent:(BOOL)hasUserConsent {
    [super setHasUserConsent:hasUserConsent];
    VungleSDK* sdk = [VungleSDK sharedSDK];
    [sdk updateConsentStatus:hasUserConsent ? VungleConsentAccepted : VungleConsentDenied consentMessageVersion:@"1.0.0"];
}

- (void)dealloc{
    if(_vungleAppID){
        _vungleAppID = nil;
    }
}

@end

@interface MovieDelegate6006()

@property (nonatomic) NSMutableDictionary<NSString *, Banner6006 *> *infeedMap;

@end

@implementation MovieDelegate6006

+ (instancetype)sharedInstance {
    static MovieDelegate6006 *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super new];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.infeedMap = [NSMutableDictionary new];
    }
    return self;
}

- (void)dealloc {
    [[VungleSDK sharedSDK] setDelegate:nil];
}

- (void)setBanner:(Banner6006 *)banner inZone:(NSString *)zoneId {
    if (!zoneId) {
        [self.infeedMap setValue:banner forKey:@"default"];
    } else {
        [self.infeedMap setValue:banner forKey:zoneId];
    }
}

- (void)removeBannerInZone:(NSString *)zoneId {
    if (zoneId) {
        [self.infeedMap removeObjectForKey:zoneId];
    }
}

- (Banner6006 *)getBannerWithZone:(NSString *)zoneId {
    if (!zoneId || zoneId.length == 0 || !self.infeedMap[zoneId]) {
        zoneId = @"default";
    }
    return self.infeedMap[zoneId];
}

#pragma mark - VungleSDKDelegate

- (void)vungleSDKDidInitialize {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSDictionary *movieRewardList = [self getAllMovieReward];
    [movieRewardList enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, MovieReward6006 *  _Nonnull movieReward, BOOL * _Nonnull stop) {
        if (movieReward.isNeedToStartAd) {
            [movieReward startAd];
            movieReward.isNeedToStartAd = NO;
        }
    }];
    [self.infeedMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, Banner6006 *  _Nonnull banner, BOOL * _Nonnull stop) {
        if (banner.isNeedToStartAd) {
            [banner startAd];
            banner.isNeedToStartAd = NO;
        }
    }];
}

- (void)vungleSDKFailedToInitializeWithError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"%@", error.localizedDescription);
}

//Vungle delegate
/** 広告準備完了 */
- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable placementID:(nullable NSString *)placementID error:(nullable NSError *)error {
    NSLog(@"%s isAdPlayable: %@ placementID: %@", __PRETTY_FUNCTION__, (isAdPlayable ? @"YES" : @"NO"), placementID);
    NSLog(@"%@", [[VungleSDK sharedSDK] debugInfo]);

    if (isAdPlayable) {
        // 広告準備完了
        Banner6006 *banner = [self getBannerWithZone:placementID];
        if (banner) {
            [banner loadCompleted];
        } else {
            [self setCallbackStatus:MovieRewardCallbackFetchComplete zone:placementID];
        }
    } else {
        Banner6006 *banner = [self getBannerWithZone:placementID];
        if (banner) {
            [banner loadFailed];
        }
    }
}

/** 動画再生開始 */
- (void)vungleWillShowAdForPlacementID:(NSString *)placementID {
    NSLog(@"%s placementID: %@", __PRETTY_FUNCTION__, placementID);
    [self setCallbackStatus:MovieRewardCallbackPlayStart zone:placementID];
}

/** 動画再生終了&エンドカード終了 */
- (void)vungleWillCloseAdForPlacementID:(NSString *)placementID {
    NSLog(@"%s placementID: %@", __PRETTY_FUNCTION__, placementID);
    [self setCallbackStatus:MovieRewardCallbackPlayComplete zone:placementID];
    [self setCallbackStatus:MovieRewardCallbackClose zone:placementID];
}

- (void)vungleTrackClickForPlacementID:(nullable NSString *)placementID {
    NSLog(@"%s placementID: %@", __PRETTY_FUNCTION__, placementID);
    Banner6006 *banner = [self getBannerWithZone:placementID];
    if (banner) {
        [banner adClicked];
    }
}

@end
