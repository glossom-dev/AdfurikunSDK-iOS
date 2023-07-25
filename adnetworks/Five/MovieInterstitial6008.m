//
//  MovieInterstitial6008.m(Five)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import "MovieInterstitial6008.h"
#import <ADFMovieReward/ADFMovieOptions.h>

@interface MovieInterstitial6008()

@property (nonatomic)FADInterstitial *interstitial;

@end

@implementation MovieInterstitial6008

+ (NSString *)getAdapterRevisionVersion {
    return @"12";
}

+ (NSString *)adnetworkClassName {
    return @"FADInterstitial";
}

-(BOOL)isPrepared {
    //申請済のバンドルIDと異なる場合のメッセージ
    //(バンドルIDが申請済のものと異なると、正常に広告が返却されない可能性があります)
    if(![self.submittedPackageName isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
        //表示を消したい場合は、こちらをコメントアウトして下さい。
        AdapterLogP(@"[SEVERE] [Five]アプリのバンドルIDが、申請されたもの（%@）と異なります。", self.submittedPackageName);
    }
    
    if (self.interstitial) {
        return self.isAdLoaded && self.interstitial.state == kFADStateLoaded;
    }
    return NO;
}

/**
 *  広告の読み込みを開始する
 */
-(void)startAd {
    if (![self canStartAd]) {
        return;
    }
    
    if (self.interstitial) {
        self.interstitial = nil;
    }
    
    [super startAd];

    @try {
        [self requireToAsyncRequestAd];
        self.interstitial = [[FADInterstitial alloc] initWithSlotId:self.fiveSlotId];
        [self.interstitial setLoadDelegate:self];
        [self.interstitial setAdViewEventListener:self];
        //音出力設定
        ADFMovieOptions_Sound soundState = [ADFMovieOptions getSoundState];
        if (ADFMovieOptions_Sound_On == soundState) {
            [self.interstitial enableSound:true];
        } else if (ADFMovieOptions_Sound_Off == soundState) {
            [self.interstitial enableSound:false];
        }
        
        [self.interstitial loadAdAsync];
    } @catch (NSException *exception) {
        [self adnetworkExceptionHandling:exception];
    }
}


/**
 *  広告の表示を行う
 */
-(void)showAd {
    [super showAd];
    
    if (self.interstitial) {
        @try {
            [self requireToAsyncPlay];
            BOOL res = [self.interstitial show];
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

-(void)dealloc {
}

@end

@implementation MovieInterstitial6070
@end

@implementation MovieInterstitial6071
@end

@implementation MovieInterstitial6072
@end

@implementation MovieInterstitial6073
@end

@implementation MovieInterstitial6074
@end
