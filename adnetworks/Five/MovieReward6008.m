//
//  MovieReward6008.m(Five)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import "MovieReward6008.h"
#import <FiveAd/FiveAd.h>
#import <ADFMovieReward/ADFMovieOptions.h>

@interface MovieReward6008()<FADLoadDelegate, FADAdViewEventListener>

@property (nonatomic) FADVideoReward *fullscreen;
@property (nonatomic, strong)NSString *fiveAppId;
@property (nonatomic, strong)NSString *fiveSlotId;
@property (nonatomic, strong)NSString* submittedPackageName;
@property (nonatomic)BOOL testFlg;
@property (nonatomic)BOOL didRetryForNoCache;
@property (nonatomic) BOOL requireToAsyncRequestAd;

@end

@implementation MovieReward6008

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

-(BOOL)isPrepared {
    //申請済のバンドルIDと異なる場合のメッセージ
    //(バンドルIDが申請済のものと異なると、正常に広告が返却されない可能性があります)
    if(![self.submittedPackageName isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
        //表示を消したい場合は、こちらをコメントアウトして下さい。
        NSLog(@"[ADF] [SEVERE] [Five]アプリのバンドルIDが、申請されたもの（%@）と異なります。", self.submittedPackageName);
    }
    
    if (self.fullscreen) {
        return self.fullscreen.state == kFADStateLoaded;
    }
    return NO;
}

-(void)initAdnetworkIfNeeded {
    if (![self needsToInit]) {
        return;
    }

    if (self.fiveAppId && self.fiveSlotId && [self.fiveAppId length] > 0 && [self.fiveSlotId length] > 0) {
        [self requireToAsyncInit];
        [MovieConfigure6008.sharedInstance configureWithAppId:self.fiveAppId isTest:self.testFlg gdprStatus:self.gdprStatus completion:^{
            [self initCompleteAndRetryStartAdIfNeeded];
        }];
    }
}

-(void)startAd {
    NSLog(@"[ADF] Adnetwork 6008 %s", __FUNCTION__);
    
    if (![self canStartAd]) {
        return;
    }
    
    if (self.requireToAsyncRequestAd) {
        NSLog(@"[ADF] Adnetwork 6008 %s, requireToAsyncRequestAd is true", __FUNCTION__);
        return;
    }

    if (self.fullscreen) {
        self.fullscreen = nil;
    }
    
    if (self.fiveSlotId && self.fiveSlotId.length > 0) {
        @try {
            [self requireToAsyncRequestAd];
            self.requireToAsyncRequestAd = true;
            NSLog(@"[ADF] Adnetwork 6008 %s reward load", __FUNCTION__);

            self.fullscreen = [[FADVideoReward alloc] initWithSlotId:self.fiveSlotId];
            [self.fullscreen setLoadDelegate:self];
            [self.fullscreen setAdViewEventListener:self];

            //音出力設定
            ADFMovieOptions_Sound soundState = [ADFMovieOptions getSoundState];
            if (ADFMovieOptions_Sound_On == soundState) {
                [self.fullscreen enableSound:true];
            } else if (ADFMovieOptions_Sound_Off == soundState) {
                [self.fullscreen enableSound:false];
            }
            [self.fullscreen loadAdAsync];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
        }
    }
}

-(void)showAd {
    [super showAd];
    
    if (self.fullscreen) {
        @try {
            [self requireToAsyncPlay];
            BOOL res = [self.fullscreen show];
            if (!res) {
                [self setCallbackStatus:MovieRewardCallbackPlayFail];
            }
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    }
}

-(void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [self showAd];
}

-(BOOL)isClassReference {
    Class clazz = NSClassFromString(@"FADVideoReward");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: FiveAd");
        return NO;
    }
    return YES;
}

@end

@implementation MovieReward6070

@end

@implementation MovieReward6071

@end

@implementation MovieReward6072

@end
