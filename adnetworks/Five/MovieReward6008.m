//
//  MovieReward6008.m(Five)
//
//  Copyright (c) A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//
//

#import "MovieReward6008.h"
#import <FiveAd/FiveAd.h>
#import <ADFMovieReward/ADFMovieOptions.h>

@interface MovieReward6008()<FADDelegate>

@property (nonatomic) FADVideoReward *fullscreen;
@property (nonatomic, strong)NSString *fiveAppId;
@property (nonatomic, strong)NSString *fiveSlotId;
@property (nonatomic, strong)NSString* submittedPackageName;
@property (nonatomic)BOOL testFlg;
@property (nonatomic)BOOL didRetryForNoCache;

@end

@implementation MovieReward6008

-(void)setData:(NSDictionary *)data {
    self.fiveAppId = [NSString stringWithFormat:@"%@", [data objectForKey:@"app_id"]];
    self.fiveSlotId = [NSString stringWithFormat:@"%@", [data objectForKey:@"slot_id"]];
    self.submittedPackageName = [data objectForKey:@"package_name"];
    if (ADFMovieOptions.getTestMode) {
        self.testFlg = YES;
    } else {
        self.testFlg = [[data objectForKey:@"test_flg"] boolValue];
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
    if (self.fiveAppId.length > 0) {
        [MovieConfigure6008 configureWithAppId:self.fiveAppId isTest:self.testFlg];
    }
}

-(void)startAd {
    if (self.fullscreen) {
        self.fullscreen = nil;
    }
    if (self.fiveSlotId.length > 0) {
        self.fullscreen = [[FADVideoReward alloc] initWithSlotId:self.fiveSlotId];
        self.fullscreen.delegate = self;
        //音出力設定
        ADFMovieOptions_Sound soundState = [ADFMovieOptions getSoundState];
        if (ADFMovieOptions_Sound_On == soundState) {
            [self.fullscreen enableSound:true];
        } else if (ADFMovieOptions_Sound_Off == soundState) {
            [self.fullscreen enableSound:false];
        }
        [self.fullscreen  loadAdAsync];
    }
}

-(void)showAd {
    [super showAd];

    if (self.fullscreen) {
        BOOL res = [self.fullscreen show];
        if (!res) {
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

