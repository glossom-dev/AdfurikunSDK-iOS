#import <FiveAd/FiveAd.h>
#import "DfpFiveCustomEventBanner.h"

@interface DfpFiveCustomEventBanner () <FADDelegate>
@property(nonatomic) FADAdViewCustomLayout *customLayout;
@end

@implementation DfpFiveCustomEventBanner

- (void)requestBannerAd:(GADAdSize)adSize
              parameter:(NSString *)serverParameter
                  label:(NSString *)serverLabel
                request:(GADCustomEventRequest *)request {
    NSLog(@"%s called", __func__);
    id slotId = [[request additionalParameters] objectForKey:@"five_banner_slot_id"];
    self.customLayout = [[FADAdViewCustomLayout alloc] initWithSlotId:slotId width:adSize.size.width];
    self.customLayout.delegate = self;
    [self.customLayout loadAdAsync];
}

- (void)fiveAdDidLoad:(id<FADAdInterface>)ad {
    NSLog(@"%s called", __func__);
    [self.delegate customEventBanner:self didReceiveAd:self.customLayout];
}
- (void)fiveAd:(id<FADAdInterface>)ad didFailedToReceiveAdWithError:(FADErrorCode) errorCode {
    NSLog(@"%s called", __func__);
    [self.delegate customEventBanner:self didFailAd:nil];
}
- (void)fiveAdDidClick:(id<FADAdInterface>)ad {
    [self.delegate customEventBannerWillLeaveApplication:self];
}
- (void)fiveAdDidClose:(id<FADAdInterface>)ad {}
- (void)fiveAdDidStart:(id<FADAdInterface>)ad {}
- (void)fiveAdDidPause:(id<FADAdInterface>)ad {}
- (void)fiveAdDidResume:(id<FADAdInterface>)ad {}
- (void)fiveAdDidViewThrough:(id<FADAdInterface>)ad {}
- (void)fiveAdDidReplay:(id<FADAdInterface>)ad {}
- (void)fiveAdDidStall:(id<FADAdInterface>)ad {}
- (void)fiveAdDidRecover:(id<FADAdInterface>)ad {}
- (void)fiveAdDidImpressionImage:(id<FADAdInterface>)ad {}

@end
