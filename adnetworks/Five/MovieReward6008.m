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
@property (nonatomic) bool invokeFinishCallback;

@end

@implementation MovieReward6008

+ (NSString *)getAdapterRevisionVersion {
    return @"6";
}

+ (NSString *)adnetworkClassName {
    return @"FADVideoReward";
}

+ (NSString *)adnetworkName {
    return @"LINE Ads Platform";
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
            [self.fullscreen setEventListener:self];
            
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
    UIViewController *vc = [self topMostViewController];
    if (vc) {
        [self showAdWithPresentingViewController:vc];
    } else {
        AdapterLog(@"top most viewcontroller is nil");
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

-(void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAdWithPresentingViewController:viewController];
    
    if (self.fullscreen) {
        @try {
            [self requireToAsyncPlay];
            self.invokeFinishCallback = false;
            [self.fullscreen showWithViewController:viewController];
        } @catch (NSException *exception) {
            [self adnetworkExceptionHandling:exception];
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    }
}

#pragma mark FADVideoRewardEventListener
- (void)fiveVideoRewardAd:(nonnull FADVideoReward*)ad didFailedToShowAdWithError:(FADErrorCode) errorCode {
    // エラー時の処理
    AdapterLogP(@"errorCode: %ld, slotId: %@", (long)errorCode, self.fiveSlotId);
    [self setErrorWithMessage:nil code:errorCode];
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}

- (void)fiveVideoRewardAdDidReward:(nonnull FADVideoReward*)ad {
    // 【新規】リワード付与の処理
    AdapterTrace;
    if (!self.invokeFinishCallback) {
        // 静止画の場合fiveVideoRewardAdDidViewThroughが発生しないため、Reward CallbackでFinishも発生させる
        [self setCallbackStatus:MovieRewardCallbackPlayComplete];
        self.invokeFinishCallback = true;
    }
    [self setCallbackStatus:MovieRewardCallbackClose];
}

- (void)fiveVideoRewardAdDidImpression:(nonnull FADVideoReward*)ad {
    // インプレッション時の処理
    AdapterTrace;
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)fiveVideoRewardAdDidClick:(nonnull FADVideoReward*)ad {
    // クリック時の処理
    AdapterTrace;
}

- (void)fiveVideoRewardAdFullScreenDidOpen:(nonnull FADVideoReward*)ad {
    // 【新規】フルスクリーン広告ビューオープン時の処理
    AdapterTrace;
}

- (void)fiveVideoRewardAdFullScreenDidClose:(nonnull FADVideoReward*)ad {
    // フルスクリーン広告ビュークローズ時の処理
    AdapterTrace;
}

- (void)fiveVideoRewardAdDidPlay:(nonnull FADVideoReward*)ad {
    // 再生開始時の処理（動画広告のみ）
    AdapterTrace;
}

- (void)fiveVideoRewardAdDidPause:(nonnull FADVideoReward*)ad {
    // 一時停止時の処理（動画広告のみ）
    AdapterTrace;
}

- (void)fiveVideoRewardAdDidViewThrough:(nonnull FADVideoReward*)ad {
    // 再生完了時の処理（動画広告のみ）
    AdapterTrace;
    
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
    self.invokeFinishCallback = true; // finish callback発火済み
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

@implementation MovieReward6075
@end

@implementation MovieReward6076
@end

@implementation MovieReward6077
@end

@implementation MovieReward6078
@end

@implementation MovieReward6079
@end
