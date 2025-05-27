//
//  AdnetworkConfigure6110.m
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2022/08/15.
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import "AdnetworkConfigure6110.h"
#import "AdnetworkParam6110.h"
//#import "Banner6110.h"

@interface AdnetworkConfigure6110 ()

@property (nonatomic) NSMutableDictionary <NSString *, ADFmyMovieRewardInterface*> *movieRewardAdapters;
@property (nonatomic) NSMutableDictionary <NSString *, ADFmyMovieRewardInterface*> *interstitialAdapters;

@end

@implementation AdnetworkConfigure6110

// Adnetwork SDK Version
+ (NSString *)getSDKVersion {
    return [IronSource sdkVersion];
}

// Adnetwork名
+ (NSString *)adnetworkName {
    return @"ironSource";
}

+ (instancetype)sharedInstance {
    static AdnetworkConfigure6110 *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

// GDPR関連設定実装
- (void)setHasUserConsent:(BOOL)hasUserConsent {
    AdapterTraceP(@"hasUserConsent: %d", (int)hasUserConsent);
    [IronSource setConsent:hasUserConsent];
}

// COPPA関連設定実装
- (void)isChildDirected:(BOOL)childDirected {
    AdapterTraceP(@"childDirected: %d", (int)childDirected);
    [IronSource setMetaDataWithKey:@"is_child_directed" value:childDirected ? @"YES": @"NO"];
}

// Adnetwork SDK初期化ロジック実装
// 初期化成功：initSuccess()呼び出し
// 初期化失敗：initFail()呼び出し
- (void)initAdnetworkSDK {
    [IronSource setISDemandOnlyRewardedVideoDelegate:self];
    [IronSource setISDemandOnlyInterstitialDelegate:self];
    
    [IronSource initISDemandOnly:((AdnetworkParam6110 *)self.param).appKey adUnits:@[IS_REWARDED_VIDEO, IS_INTERSTITIAL, IS_BANNER]];
    
    NSString *mediationString = [NSString stringWithFormat:@"Adfurikun1SDK%@", [AdfurikunSdk version]];
    AdapterLogP(@"mediation string : %@", mediationString);
    [IronSource setMediationType:mediationString];
    [self initSuccess];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.movieRewardAdapters = [NSMutableDictionary new];
        self.interstitialAdapters = [NSMutableDictionary new];
    }
    return self;
}

- (void)setMovieRewardAdapter:(ADFmyMovieRewardInterface *)adapter instanceId:(NSString *)instanceId {
    [self.movieRewardAdapters setObject:adapter forKey:instanceId];
}

- (void)removeMovieRewardAdapterWithInstanceId:(NSString *)instanceId {
    [self.movieRewardAdapters removeObjectForKey:instanceId];
}

- (void)setInterstitialAdapter:(ADFmyMovieRewardInterface *)adapter instanceId:(NSString *)instanceId {
    [self.interstitialAdapters setObject:adapter forKey:instanceId];
}

- (void)removeInterstitialAdapterWithInstanceId:(NSString *)instanceId {
    [self.interstitialAdapters removeObjectForKey:instanceId];
}

#pragma mark - ISDemandOnlyRewardedVideoDelegate
//Called after a rewarded video has been requested and load succeed.
- (void)rewardedVideoDidLoad:(NSString *)instanceId {
    AdapterTraceP(@"instance id : %@", instanceId);
    ADFmyMovieRewardInterface *adapter = [self.movieRewardAdapters objectForKey:instanceId];
    if (adapter) {
        [adapter setCallbackStatus:MovieRewardCallbackFetchComplete];
    }
}

//Called after a rewarded video has attempted to load but failed.
//@param error The reason for the error
- (void)rewardedVideoDidFailToLoadWithError:(NSError *)error instanceId:(NSString* )instanceId {
    AdapterTraceP(@"instance id : %@, error : %@", instanceId, error);
    ADFmyMovieRewardInterface *adapter = [self.movieRewardAdapters objectForKey:instanceId];
    if (adapter) {
        [adapter setLastError:error];
        [adapter setCallbackStatus:MovieRewardCallbackFetchFail];
    }
}

//Called after a rewarded video has attempted to show but failed.
//@param error The reason for the error
- (void)rewardedVideoDidFailToShowWithError:(NSError *)error instanceId:(NSString *)instanceId {
    AdapterTraceP(@"instance id : %@, error : %@", instanceId, error);
    ADFmyMovieRewardInterface *adapter = [self.movieRewardAdapters objectForKey:instanceId];
    if (adapter) {
        [adapter setLastError:error];
        [adapter setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

//Called after a rewarded video has been opened.
- (void)rewardedVideoDidOpen:(NSString *)instanceId {
    AdapterTraceP(@"instance id : %@", instanceId);
    ADFmyMovieRewardInterface *adapter = [self.movieRewardAdapters objectForKey:instanceId];
    if (adapter) {
        [adapter setCallbackStatus:MovieRewardCallbackPlayStart];
    }
}

//Called after a rewarded video has been viewed completely and the user is //eligible for reward.
- (void)rewardedVideoAdRewarded:(NSString *)instanceId {
    AdapterTraceP(@"instance id : %@", instanceId);
    ADFmyMovieRewardInterface *adapter = [self.movieRewardAdapters objectForKey:instanceId];
    if (adapter) {
        adapter.isRewarded = true;
        [adapter setCallbackStatus:MovieRewardCallbackPlayComplete];
    }
}

//Called after a rewarded video has been dismissed.
- (void)rewardedVideoDidClose:(NSString *)instanceId {
    AdapterTraceP(@"instance id : %@", instanceId);
    ADFmyMovieRewardInterface *adapter = [self.movieRewardAdapters objectForKey:instanceId];
    if (adapter) {
        [adapter setCallbackStatus:MovieRewardCallbackClose];
    }
}

//Invoked when the end user clicked on the RewardedVideo ad
- (void)rewardedVideoDidClick:(NSString *)instanceId {
    AdapterTraceP(@"instance id : %@", instanceId);
}

#pragma mark - ISDemandOnlyInterstitialDelegate
/**
 Called after an interstitial has been loaded
 */
- (void)interstitialDidLoad:(NSString *)instanceId {
    AdapterTraceP(@"instance id : %@", instanceId);
    ADFmyMovieRewardInterface *adapter = [self.interstitialAdapters objectForKey:instanceId];
    if (adapter) {
        [adapter setCallbackStatus:MovieRewardCallbackFetchComplete];
    }
}

/**
 Called after an interstitial has attempted to load but failed.

 @param error The reason for the error
 */
- (void)interstitialDidFailToLoadWithError:(NSError *)error instanceId:(NSString *)instanceId {
    AdapterTraceP(@"instance id : %@, error : %@", instanceId, error);
    ADFmyMovieRewardInterface *adapter = [self.interstitialAdapters objectForKey:instanceId];
    if (adapter) {
        if (error) {
            [adapter setErrorWithMessage:error.localizedDescription code:error.code];
        }
        [adapter setCallbackStatus:MovieRewardCallbackFetchFail];
    }
}

/**
 Called after an interstitial has been opened.
 */
- (void)interstitialDidOpen:(NSString *)instanceId {
    AdapterTraceP(@"instance id : %@", instanceId);
    ADFmyMovieRewardInterface *adapter = [self.interstitialAdapters objectForKey:instanceId];
    if (adapter) {
        [adapter setCallbackStatus:MovieRewardCallbackPlayStart];
    }
}

/**
  Called after an interstitial has been dismissed.
 */
- (void)interstitialDidClose:(NSString *)instanceId {
    AdapterTraceP(@"instance id : %@", instanceId);
    ADFmyMovieRewardInterface *adapter = [self.interstitialAdapters objectForKey:instanceId];
    if (adapter) {
        [adapter setCallbackStatus:MovieRewardCallbackPlayComplete];
        [adapter setCallbackStatus:MovieRewardCallbackClose];
    }
}

/**
 Called after an interstitial has attempted to show but failed.

 @param error The reason for the error
 */
- (void)interstitialDidFailToShowWithError:(NSError *)error instanceId:(NSString *)instanceId {
    AdapterTraceP(@"instance id : %@, error : %@", instanceId, error);
    ADFmyMovieRewardInterface *adapter = [self.interstitialAdapters objectForKey:instanceId];
    if (adapter) {
        if (error) {
            [adapter setErrorWithMessage:error.localizedDescription code:error.code];
        }
        [adapter setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

/**
 Called after an interstitial has been clicked.
 */
- (void)didClickInterstitial:(NSString *)instanceId {
    AdapterTraceP(@"instance id : %@", instanceId);
}

@end
