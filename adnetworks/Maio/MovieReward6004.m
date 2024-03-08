//
//  MovieReword6004.m
//  SampleViewRecipe
//
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//
#import "MovieReward6004.h"
#import "AdnetworkParam6004.h"

#import <Foundation/Foundation.h>
#import <ADFMovieReward/ADFMovieOptions.h>

@interface MovieReward6004()

@property (nonatomic) MaioRewarded *maioInstance;
@property (nonatomic) AdnetworkParam6004 *param;
@property (nonatomic) BOOL isFireCloseCallback;

@end


@implementation MovieReward6004

+ (NSString *)getSDKVersion {
    return [MaioVersion.shared toString];
}

+ (NSString *)getAdapterRevisionVersion {
    return @"12";
}

+ (NSString *)adnetworkClassName {
    return @"Maio.MaioRewarded";
}

+ (NSString *)adnetworkName {
    return @"maio";
}

- (id)init {
    self = [super init];
    
    if ( self ) {
    }
    
    return self;
}

- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.param = [[AdnetworkParam6004 alloc] initWithParam:data];
}

- (void)initAdnetworkIfNeeded {
    [self initCompleteAndRetryStartAdIfNeeded];
}

- (void)startAd {
    if (![self canStartAd]) {
        return;
    }

    if (self.param == nil || [self.param isValid] == false) {
        return;
    }
    
    [super startAd];
    
    @try {
        [self requireToAsyncRequestAd];
        
        MaioRequest *request = [[MaioRequest alloc] initWithZoneId:self.param.maioZoneId testMode:ADFMovieOptions.getTestMode];
        self.maioInstance = [MaioRewarded loadAdWithRequest:request callback:self];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}

- (void)showAd {
    [self showAdWithPresentingViewController:[self topMostViewController]];
}

- (void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAd];

    self.isFireCloseCallback = false;
    if (self.maioInstance) {
        @try {
            [self requireToAsyncPlay];
            [self.maioInstance showWithViewContext:viewController callback:self];
        }
        @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    } else {
        AdapterLog(@"play error because maio instance is nil");
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

- (void)didLoad:(MaioRewarded * _Nonnull)ad {
    AdapterTrace;
    if (!self.isAdLoaded) {
        self.isAdLoaded = true;
        [self setCallbackStatus:MovieRewardCallbackFetchComplete];
    }
}

- (void)didFail:(MaioRewarded * _Nonnull)ad errorCode:(NSInteger)errorCode {
    AdapterTraceP(@"zone id : %@, error code : %d", ad.request.zoneId, (int)errorCode);
    [self setErrorWithMessage:@"" code:errorCode];

    if (self.isAdLoaded) { // load完了後のdidFailは再生エラー
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
        self.isAdLoaded = false;
    } else {
        [self setCallbackStatus:MovieRewardCallbackFetchFail];
    }
}

- (void)didOpen:(MaioRewarded * _Nonnull)ad {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)didClose:(MaioRewarded * _Nonnull)ad {
    AdapterTrace;
    if (!self.isFireCloseCallback) {
        [self setCallbackStatus:MovieRewardCallbackClose];
        self.isAdLoaded = false;
        self.isFireCloseCallback = true;
    }
}

- (void)didReward:(MaioRewarded * _Nonnull)ad reward:(RewardData * _Nonnull)reward {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
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
