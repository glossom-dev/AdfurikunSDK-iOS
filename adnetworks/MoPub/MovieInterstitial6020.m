#import <UIKit/UIKit.h>
#import "MovieInterstitial6020.h"

@interface MovieInterstitial6020()

@property (nonatomic, strong) NSString *adUnitId;
@property (nonatomic, retain) MPInterstitialAdController *interstitial;
@property (nonatomic) BOOL hasPendingStartAd;

@end

@implementation MovieInterstitial6020

- (void)setData:(NSDictionary *)data {
    NSLog(@"mopub inst: setData");
    NSString *adUnitId = [NSString stringWithFormat:@"%@", [data objectForKey:@"ad_unit_id"]];
    if (adUnitId && ![adUnitId isEqual:[NSNull null]]) {
        self.adUnitId = adUnitId;
    }
}

- (void)initAdnetworkIfNeeded {
    NSLog(@"mopub inst: initAdnetworkIfNeeded");
    if (self.adUnitId && ![self.adUnitId isEqual:[NSNull null]]) {
        MPMoPubConfiguration *sdkConfig = [[MPMoPubConfiguration alloc] initWithAdUnitIdForAppInitialization:self.adUnitId];
        [[MoPub sharedInstance] initializeSdkWithConfiguration:sdkConfig completion:^{
            NSLog(@"mopub inst: SDK has been initted!!!!!");
            if (self.hasPendingStartAd) {
                self.hasPendingStartAd = false;
                [self startAd];
            }
        }];
    }
}

- (void)startAd {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"mopub inst: startAd");
        if (![MoPub sharedInstance].isSdkInitialized) {
            NSLog(@"mopub: mopub is not initialized");
            self.hasPendingStartAd = YES;
            return;
        }
        self.interstitial = [MPInterstitialAdController
            interstitialAdControllerForAdUnitId:self.adUnitId];
        self.interstitial.delegate = self;
        [self.interstitial loadAd]; // Fetch the interstitial ad.
    });
}

-(BOOL)isClassReference {
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_9_0) {
        return NO;
    }

    Class clazz = NSClassFromString(@"FBInterstitialAd");
    if (clazz) {
    } else {
        NSLog(@"Not found Class: FBInterstitialAd");
        return NO;
    }
    return YES;
}

- (BOOL)isPrepared {
    if (self.delegate && self.interstitial && self.interstitial.ready) {
        return YES;
    } else {
        return NO;
    }
}


-(void)showAd {
    UIViewController *topMostViewController = [self topMostViewController];
    [self showAdWithPresentingViewController:topMostViewController];
}

-(void)showAdWithPresentingViewController:(UIViewController *)viewController {
    [super showAdWithPresentingViewController:viewController];

    if ([self isPrepared]) {
        if (viewController) {
            [self.interstitial showFromViewController: viewController];
        } else {
            NSLog(@"Error encountered playing ad : viewController cannot be nil");
            [self setCallbackStatus:MovieRewardCallbackPlayFail];
        }
    } else {
        NSLog(@"Error encountered playing ad : isPrepared was false");
        [self setCallbackStatus:MovieRewardCallbackPlayFail];
    }
}

#pragma mark - MPInterstitialAdControllerDelegate delegates

- (void)mopubAd:(id<MPMoPubAd>)ad didTrackImpressionWithImpressionData:(MPImpressionData * _Nullable)impressionData{ //did finish watching
    NSLog(@"MovieInterstitial6020: didTrackImpressionWithImpressionData");
    [self setCallbackStatus:MovieRewardCallbackPlayComplete];
}
- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial { // fetch completed
    NSLog(@"MovieInterstitial6020: interstitialDidLoadAd");
    [self setCallbackStatus:MovieRewardCallbackFetchComplete];
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial { // fetch failed
    NSLog(@"MovieInterstitial6020: interstitial video loading failed");
    [self setCallbackStatus:MovieRewardCallbackFetchFail];
}

 - (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial { // closed
     NSLog(@"MovieInterstitial6020: interstitialDidDisappear");
     [self setCallbackStatus:MovieRewardCallbackClose];
 }

- (void)interstitialDidAppear:(MPInterstitialAdController *)interstitial { // started
    NSLog(@"MovieInterstitial6020: interstitialDidAppear");
    [self setCallbackStatus:MovieRewardCallbackPlayStart];
}

- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial {
    NSLog(@"MovieInterstitial6020: interstitialDidExpire");
    [self setCallbackStatus:MovieRewardCallbackPlayFail];
}

@end