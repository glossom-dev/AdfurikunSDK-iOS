//
//  AdfurikunMoPubNativeAdAdapter.h
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import <MoPub/MoPub.h>
#import <ADFMovieReward/ADFmyNativeAd.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdfurikunMoPubNativeAdAdapter : NSObject <MPNativeAdAdapter>
@property(nonatomic, weak) id<MPNativeAdAdapterDelegate> delegate;

- (instancetype)initWithAdInfo:(ADFNativeAdInfo *)adInfo appId:(NSString *)appId;
@end

NS_ASSUME_NONNULL_END
