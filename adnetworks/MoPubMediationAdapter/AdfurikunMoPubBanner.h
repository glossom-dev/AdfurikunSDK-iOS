//
//  AdfurikunMoPubBanner.h
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import <MoPub/MoPub.h>
#import <ADFMovieReward/ADFmyBanner.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdfurikunMoPubBanner : MPInlineAdAdapter<MPThirdPartyInlineAdAdapter, ADFmyNativeAdDelegate, ADFMediaViewDelegate>

@end

NS_ASSUME_NONNULL_END
