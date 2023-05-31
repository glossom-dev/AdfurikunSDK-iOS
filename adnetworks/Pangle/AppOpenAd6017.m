//
//  AppOpenAd6017.m
//  MovieRewardTestApp
//
//  Copyright © 2023 Glossom, Inc. All rights reserved.
//

#import "AppOpenAd6017.h"
#import <BUAdSDK/BUAdSDK.h>
#import "MovieReward6017.h"
#import "AdnetworkParam6017.h"

#define kLoadTimeoutDefault 3

@interface AppOpenAd6017 ()<BUAppOpenAdDelegate>

@property (nonatomic, strong) BUAppOpenAd *openAd;
@property (nonatomic) AdnetworkParam6017 *adParam;

// ロードタイムアウト秒数
@property (nonatomic) NSTimeInterval timeout;

// close済みか判定フラグ（2重実行防止の為）
@property (nonatomic) BOOL didClose;
@end

@implementation AppOpenAd6017

+ (NSString *)getSDKVersion {
    return BUAdSDKManager.SDKVersion;
}

+ (NSString *)getAdapterRevisionVersion {
    return @"2";
}

- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.adParam = [[AdnetworkParam6017 alloc] initWithParam:data];
}

- (BOOL)isClassReference {
    Class clazz = NSClassFromString(@"BUAppOpenAd");
    if (clazz) {
        AdapterLog(@"found Class: BUAppOpenAd");
        return YES;
    } else {
        AdapterLog(@"Not found Class: BUAppOpenAd");
        return NO;
    }
}

- (void)initAdnetworkIfNeeded {
    if (![self needsToInit]) {
        return;
    }
    if (!self.adParam || ![self.adParam isValid]) {
        return;
    }

    @try {
        [self requireToAsyncInit];
        
        [MovieConfigure6017.sharedInstance configureWithAppId:self.adParam.appID
                                                   gdprStatus:self.hasGdprConsent
                                                childDirected:self.childDirected
                                                   completion:^{
            [self initCompleteAndRetryStartAdIfNeeded];
        }];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (void)startAd {
    [self startAdWithOption:nil];
}

- (void)startAdWithOption:(NSDictionary *)option {
    if (![self canStartAd]) {
        return;
    }
    if (!self.adParam || ![self.adParam isValid]) {
        return;
    }

    self.isAdLoaded = NO;
    if (self.openAd) {
        self.openAd = nil;
    }
    @try {
        [self requireToAsyncRequestAd];
        
        if (option) {
            NSLog(@"custom event option : %@", option);
            NSNumber *timeout = option[@"timeout"];
            if ([self isNotNull:timeout] && [timeout isKindOfClass:[NSNumber class]]) {
                self.timeout = [timeout doubleValue];
            }
        }
        if (self.timeout <= 0) {
            self.timeout = kLoadTimeoutDefault;
        }
        
        BUAdSlot *slot = [[BUAdSlot alloc] init];
        slot.ID = self.adParam.slotID;
        slot.AdType = BUAdSlotAdTypeSplash;
        
        self.openAd = [[BUAppOpenAd alloc] initWithSlot:slot];
        [self.openAd loadOpenAdWithTimeout:self.timeout completionHandler:^(BUAppOpenAd * _Nullable appOpenAd, NSError * _Nullable error) {
            if (error) {
                AdapterTraceP(@"error : %@", error);
                [self setErrorWithMessage:error.localizedDescription code:error.code];
                [self setCallbackStatus:MovieRewardCallbackFetchFail];
                return;
            } else if (appOpenAd == nil) {
                NSString *errorMsg = @"appOpenAd is nil";
                AdapterTraceP(@"error : %@", errorMsg);
                [self setErrorWithMessage:errorMsg code:0];
                [self setCallbackStatus:MovieRewardCallbackFetchFail];
                return;
            }
            self.isAdLoaded = YES;
            self.openAd = appOpenAd;
            self.openAd.delegate = self;
            [self setCallbackStatus:MovieRewardCallbackFetchComplete];
        }];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (void)showAd {
    [self.openAd presentFromRootViewController:[self topMostViewController]];
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    if (self.openAd) {
        [super showAdWithPresentingViewController:viewController];
        self.didClose = NO;
        
        @try {
            [self requireToAsyncPlay];
            
            [self.openAd presentFromRootViewController:viewController];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
            self.isAdLoaded = NO;
        }
    }
}

- (void)sendAdClose {
    if (self.didClose == NO) {
        self.isAdLoaded = NO;
        self.didClose = YES;
        [self setCallbackStatus:MovieRewardCallbackClose];
    }
}

#pragma BUAppOpenAdDelegate

/// The ad has been presented.
/// @param appOpenAd The BUAppOpenAd instance.
- (void)didPresentForAppOpenAd:(BUAppOpenAd *)appOpenAd {
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

/// The ad was clicked.
/// @param appOpenAd The BUAppOpenAd instance.
- (void)didClickForAppOpenAd:(BUAppOpenAd *)appOpenAd {
    
}

/// The ad was skipped.
/// @param appOpenAd The BUAppOpenAd instance.
- (void)didClickSkipForAppOpenAd:(BUAppOpenAd *)appOpenAd {
    [self sendAdClose];
}

/// The ad countdown is over.
/// @param appOpenAd The BUAppOpenAd instance.
- (void)countdownToZeroForAppOpenAd:(BUAppOpenAd *)appOpenAd {
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    [self sendAdClose];
}

@end

@implementation AppOpenAd6090
@end

@implementation AppOpenAd6091
@end

@implementation AppOpenAd6092
@end

@implementation AppOpenAd6093
@end

@implementation AppOpenAd6094
@end
