//
//  MovieInterstitial6004.m
//  SampleViewRecipe
//
//  Created by Junhua Li on 2016/11/03.
//
//

#import "MovieInterstitial6004.h"
#import "AdnetworkParam6004.h"

#import <Foundation/Foundation.h>
#import <ADFMovieReward/ADFMovieOptions.h>

@interface MovieInterstitial6004()

@property (nonatomic) MaioInterstitial *maioInstance;
@property (nonatomic) AdnetworkParam6004 *param;
@property (nonatomic) BOOL isFireCloseCallback;

@end


@implementation MovieInterstitial6004

+ (NSString *)getSDKVersion {
    return [MaioVersion.shared toString];
}

+ (NSString *)getAdapterRevisionVersion {
    return @"1";
}

+ (NSString *)adnetworkClassName {
    return @"Maio.MaioInterstitial";
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
        self.maioInstance = [MaioInterstitial loadAdWithRequest:request callback:self];
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

- (void)didLoad:(MaioInterstitial * _Nonnull)ad {
    AdapterTrace;
    if (!self.isAdLoaded) {
        self.isAdLoaded = true;
        [self setCallbackStatus:MovieRewardCallbackFetchComplete];
    }
}

- (void)didFail:(MaioInterstitial * _Nonnull)ad errorCode:(NSInteger)errorCode {
    AdapterTraceP(@"zone id : %@, error code : %d", ad.request.zoneId, (int)errorCode);
    [self setErrorWithMessage:@"" code:errorCode];

    if (self.isAdLoaded) { // load完了後のdidFailは再生エラー
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
        self.isAdLoaded = false;
    } else {
        [self setCallbackStatus:MovieRewardCallbackFetchFail];
    }
}

- (void)didOpen:(MaioInterstitial * _Nonnull)ad {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)didClose:(MaioInterstitial * _Nonnull)ad {
    AdapterTrace;
    if (!self.isFireCloseCallback) {
        [self setCallbackStatus:MovieRewardCallbackPlayComplete];
        [self setCallbackStatus:MovieRewardCallbackClose];
        self.isAdLoaded = false;
        self.isFireCloseCallback = true;
    }
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
