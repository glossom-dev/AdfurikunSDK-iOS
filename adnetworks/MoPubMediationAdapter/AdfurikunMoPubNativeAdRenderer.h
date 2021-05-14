//
//  AdfurikunMoPubNativeAdRenderer.h
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import <MoPubSDK/MoPub.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdfurikunMoPubNativeAdRenderer : NSObject <MPNativeAdRenderer, MPNativeAdRendererSettings>
@property (nonatomic, readonly)MPNativeViewSizeHandler viewSizeHandler;
@property (nonatomic, strong) Class renderingViewClass;

+ (MPNativeAdRendererConfiguration *)rendererConfigurationWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings;
@end

NS_ASSUME_NONNULL_END
