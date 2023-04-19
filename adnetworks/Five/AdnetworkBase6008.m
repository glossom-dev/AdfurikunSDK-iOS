//
//  Copyright © 2022 Glossom, Inc. All rights reserved.
//

#import "AdnetworkBase6008.h"
#import <ADFMovieReward/ADFMovieOptions.h>

#define kRetryTimeForNoCache 30.0

@implementation AdnetworkBase6008

+ (NSString *)getSDKVersion {
    return FADSettings.version;
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
    
    NSString *fiveAppId = [data objectForKey:@"app_id"];
    if ([self isNotNull:fiveAppId]) {
        self.fiveAppId = [NSString stringWithFormat:@"%@", fiveAppId];
    }
    NSString *fiveSlotId = [data objectForKey:@"slot_id"];
    if ([self isNotNull:fiveSlotId]) {
        self.fiveSlotId = [NSString stringWithFormat:@"%@", fiveSlotId];
    }
    NSString *submittedPackageName = [data objectForKey:@"package_name"];
    if ([self isNotNull:submittedPackageName]) {
        self.submittedPackageName = [NSString stringWithFormat:@"%@", submittedPackageName];
    }
    
    if (ADFMovieOptions.getTestMode) {
        self.testFlg = YES;
    } else {
        NSNumber *testFlg = [data objectForKey:@"test_flg"];
        if ([self isNotNull:testFlg] && [testFlg isKindOfClass:[NSNumber class]]) {
            self.testFlg = [testFlg boolValue];
        }
    }
}

-(void)initAdnetworkIfNeeded {
    if (![self needsToInit]) {
        return;
    }
    
    if (self.fiveAppId && self.fiveSlotId && [self.fiveAppId length] > 0 && [self.fiveSlotId length] > 0) {
        [self requireToAsyncInit];
        [MovieConfigure6008.sharedInstance configureWithAppId:self.fiveAppId
                                                       isTest:self.testFlg
                                                   completion:^{
            [self initCompleteAndRetryStartAdIfNeeded];
        }];
    }
}



#pragma mark - FiveDelegate
- (void)fiveAdDidLoad:(id<FADAdInterface>)ad {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

- (void)fiveAd:(id<FADAdInterface>)ad didFailedToReceiveAdWithError:(FADErrorCode)errorCode {
    AdapterLogP(@"errorCode: %ld, slotId: %@", (long)errorCode, self.fiveSlotId);
    [self setErrorWithMessage:nil code:errorCode];
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
    
    if (errorCode == kFADErrorCodeNoAd && self.didRetryForNoCache == false) {
        self.didRetryForNoCache = true;
        AdnetworkBase6008 __weak *weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, kRetryTimeForNoCache * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [weakSelf startAd];
        });
    }
}

#pragma mark - FADAdViewEventListener

- (void)fiveAd:(id<FADAdInterface>)ad didFailedToShowAdWithError:(FADErrorCode)errorCode {
    AdapterLogP(@"errorCode: %ld, slotId: %@", (long)errorCode, self.fiveSlotId);
    [self setErrorWithMessage:nil code:errorCode];
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}

- (void)fiveAdDidClick:(id<FADAdInterface>)ad {
    AdapterTrace;
}

- (void)fiveAdDidClose:(id<FADAdInterface>)ad {
    AdapterTrace;
    if (ad.state == kFADStateError) { // StateがErrorの場合
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    } else {  // Stateが正常の場合
        // 30秒より長い広告ではFinishが発生しないケースもあるのでCloseの時にFinishを発生する
        [self setCallbackStatus:MovieRewardCallbackPlayComplete];
        [self setCallbackStatus:MovieRewardCallbackClose];
    }
}

- (void)fiveAdDidImpression:(id<FADAdInterface>)ad {
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)fiveAdDidPause:(id<FADAdInterface>)ad {
    AdapterTrace;
}

- (void)fiveAdDidReplay:(id<FADAdInterface>)ad {
    AdapterTrace;
}

- (void)fiveAdDidResume:(id<FADAdInterface>)ad {
    AdapterTrace;
}

- (void)fiveAdDidViewThrough:(id<FADAdInterface>)ad {
    AdapterTrace;
}

- (void)fiveAdDidStall:(id<FADAdInterface>)ad {
    AdapterTrace;
}

- (void)fiveAdDidRecover:(id<FADAdInterface>)ad {
    AdapterTrace;
}

@end

typedef enum : NSUInteger {
    initializeNotYet,
    initializing,
    initializeComplete,
} FADInitializeStatus;

@interface MovieConfigure6008()

@property (nonatomic) FADInitializeStatus initStatus;
@property (nonatomic) NSMutableArray <completionHandlerType> *handlers;

@end

@implementation MovieConfigure6008
+ (instancetype)sharedInstance {
    static MovieConfigure6008 *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.initStatus = initializeNotYet;
        self.handlers = [NSMutableArray new];
    }
    return self;
}

- (void)configureWithAppId:(NSString *)fiveAppId
                    isTest:(BOOL)isTest
                completion:(completionHandlerType)completionHandler {
    if (!fiveAppId || !completionHandler) {
        return;
    }
    
    if (self.initStatus == initializeComplete) {
        completionHandler();
        return;
    }
    
    if (self.initStatus == initializing) {
        [self.handlers addObject:completionHandler];
        return;
    }
    
    if (self.initStatus == initializeNotYet) {
        self.initStatus = initializing;
        [self.handlers addObject:completionHandler];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @try {
                FADConfig *config = [[FADConfig alloc] initWithAppId:fiveAppId];
                if (isTest) {
                    config.isTest =  YES;
                }
                
                [FADSettings registerConfig:config];
                
                self.initStatus = initializeComplete;
                
                for (completionHandlerType handler in self.handlers) {
                    handler();
                }
            } @catch (NSException *exception) {
                NSLog(@"adnetwork exception : %@", exception);
            }
        });
    }
}

@end
