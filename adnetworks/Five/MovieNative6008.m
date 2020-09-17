//
//  MovieNative6008.m
//  MovieRewardSampleDev
//
//  Created by Junhua Li on 2018/06/22.
//  Copyright © 2018年 A .D F. U. L. L. Y Co., Ltd. All rights reserved.
//

#import "MovieNative6008.h"
#import "MovieInterstitial6008.h"
#import <ADFMovieReward/ADFMovieOptions.h>

@interface MovieNative6008()<FADDelegate>
@property (nonatomic, strong) NSString *fiveAppId;
@property (nonatomic, strong) NSString *fiveSlotId;
@property (nonatomic, strong) NSString* submittedPackageName;
@property (nonatomic) BOOL testFlg;
@property (nonatomic) FADAdViewCustomLayout *adCustomLayout;

@end

@implementation MovieNative6008

//課題：ANDW SDKのバージョン情報をSDKから取得できるようにする
+ (NSString *)getSDKVersion {
    return FADSettings.version;
}

-(BOOL)isClassReference {
    Class clazz = NSClassFromString(@"FADAdViewCustomLayout");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: FiveAd");
        return NO;
    }
    return YES;
}

- (void)setData:(NSDictionary *)data {
    [super setData:data];
    
    self.fiveAppId = [NSString stringWithFormat:@"%@", [data objectForKey:@"app_id"]];
    self.fiveSlotId = [NSString stringWithFormat:@"%@", [data objectForKey:@"slot_id"]];
    self.submittedPackageName = [data objectForKey:@"package_name"];
    if (ADFMovieOptions.getTestMode) {
        self.testFlg = YES;
    } else {
        self.testFlg = [[data objectForKey:@"test_flg"] boolValue];
    }
}

-(void)initAdnetworkIfNeeded {
    if (self.fiveAppId.length > 0) {
        [MovieConfigure6008 configureWithAppId:self.fiveAppId isTest:self.testFlg];
    }
}

- (void)startAd {
    [super startAd];
    
    self.adCustomLayout = [[FADAdViewCustomLayout alloc] initWithSlotId:self.fiveSlotId width:320.0];
    self.adCustomLayout.delegate = self;

    //音出力設定
    ADFMovieOptions_Sound soundState = [ADFMovieOptions getSoundState];
    if (ADFMovieOptions_Sound_On == soundState) {
        [self.adCustomLayout enableSound:true];
    } else if (ADFMovieOptions_Sound_Off == soundState) {
        [self.adCustomLayout enableSound:false];
    }

    [self.adCustomLayout loadAdAsync];
}

- (void)cancel {
}

// ここからはFiveのDelegateを受け取る箇所
#pragma mark -  FiveDelegate
- (void)fiveAdDidLoad:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
    MovieNativeAdInfo6008 *info = [[MovieNativeAdInfo6008 alloc] initWithVideoUrl:nil
                                                                            title:@""
                                                                      description:@""
                                                                     adnetworkKey:@"6008"];
    if (ad.creativeType == kFADCreativeTypeImage) {
        info.mediaType = ADFNativeAdType_Image;
    } else if (ad.creativeType == kFADCreativeTypeMovie) {
        info.mediaType = ADFNativeAdType_Movie;
    }

    info.adapter = self;
    info.ad = self.adCustomLayout;
    [info setupMediaView:info.ad];
    self.adInfo = info;
    self.isAdLoaded = YES;
    [self.delegate onNativeMovieAdLoadFinish:self.adInfo];
}

- (void)fiveAd:(id<FADAdInterface>)ad didFailedToReceiveAdWithError:(FADErrorCode)errorCode {
    NSLog(@"%s, error code : %ld", __func__, (long)errorCode);
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(onNativeMovieAdLoadError:)]) {
            [self setErrorWithMessage:nil code:errorCode];
            [self.delegate onNativeMovieAdLoadError:self];
        } else {
            NSLog(@"%s onNativeMovieAdLoadError selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s Delegate is not setting", __FUNCTION__);
    }
}

- (void)fiveAdDidClick:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
}

- (void)fiveAdDidClose:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
}

- (void)fiveAdDidStart:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);

    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewPlayStart)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewPlayStart];
        } else {
            NSLog(@"%s onADFMediaViewPlayStart selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

- (void)fiveAdDidPause:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
}

- (void)fiveAdDidReplay:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
}

- (void)fiveAdDidResume:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
}

- (void)fiveAdDidViewThrough:(id<FADAdInterface>)ad {
    NSLog(@"%s", __func__);
    
    if (self.adInfo.mediaView.adapterInnerDelegate) {
        if ([self.adInfo.mediaView.adapterInnerDelegate respondsToSelector:@selector(onADFMediaViewPlayFinish)]) {
            [self.adInfo.mediaView.adapterInnerDelegate onADFMediaViewPlayFinish];
        } else {
            NSLog(@"%s onADFMediaViewPlayFinish selector is not responding", __FUNCTION__);
        }
    } else {
        NSLog(@"%s adInfo.mediaView.adapterInnerDelegate is not setting", __FUNCTION__);
    }
}

@end

@implementation MovieNativeAdInfo6008

- (void)playMediaView {
    NSLog(@"%s", __func__);
    self.ad.hidden = NO;
}

@end
