//
//  MovieReward6008.m(Five)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import "MovieReward6008.h"
#import <ADFMovieReward/ADFMovieOptions.h>

@interface MovieReward6008()

@property (nonatomic) FADVideoReward *fullscreen;

@end

@implementation MovieReward6008

+ (NSString *)getAdapterRevisionVersion {
    return @"1";
}

-(BOOL)isPrepared {
    //申請済のバンドルIDと異なる場合のメッセージ
    //(バンドルIDが申請済のものと異なると、正常に広告が返却されない可能性があります)
    if(![self.submittedPackageName isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
        //表示を消したい場合は、こちらをコメントアウトして下さい。
        AdapterLogP(@"[SEVERE] [Five]アプリのバンドルIDが、申請されたもの（%@）と異なります。", self.submittedPackageName);
    }
    
    if (self.fullscreen) {
        return self.isAdLoaded && self.fullscreen.state == kFADStateLoaded;
    }
    return NO;
}

-(void)startAd {
    if (![self canStartAd]) {
        return;
    }
    
    if (self.fullscreen) {
        self.fullscreen = nil;
    }
    
    [super startAd];
    
    if (self.fiveSlotId && self.fiveSlotId.length > 0) {
        @try {
            [self requireToAsyncRequestAd];
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
        AdapterLog(@"Not found Class: FiveAd");
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

@implementation MovieReward6073
@end

@implementation MovieReward6074
@end
