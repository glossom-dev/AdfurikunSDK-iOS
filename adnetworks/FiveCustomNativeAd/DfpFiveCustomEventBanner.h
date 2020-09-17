@import GoogleMobileAds;

@interface DfpFiveCustomEventBanner : NSObject <GADCustomEventBanner>

@property(nonatomic, weak) id<GADCustomEventBannerDelegate> delegate;

- (void)requestBannerAd:(GADAdSize) adSize
              parameter:(NSString *)serverParameter
                  label:(NSString *)serverLabel
                request:(GADCustomEventRequest *)request;

@end
