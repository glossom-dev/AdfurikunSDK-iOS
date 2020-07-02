//
//  AdfurikunMoPubNativeAdRenderer.m
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "AdfurikunMoPubNativeAdRenderer.h"
#import "AdfurikunMoPubNativeAdAdapter.h"

@interface AdfurikunMoPubNativeAdRenderer () <MPNativeAdRendererImageHandlerDelegate>
@property (nonatomic, strong) UIView<MPNativeAdRendering> *adView;
@property (nonatomic, strong) AdfurikunMoPubNativeAdAdapter *adapter;
@property (nonatomic, strong) MPNativeAdRendererImageHandler *rendererImageHandler;
@property (nonatomic, assign) BOOL adViewInViewHierarchy;
@end

@implementation AdfurikunMoPubNativeAdRenderer
- (instancetype)initWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings {
    if (self = [super init]) {
        MPStaticNativeAdRendererSettings *settings = (MPStaticNativeAdRendererSettings *)rendererSettings;
        _renderingViewClass = settings.renderingViewClass;
        _viewSizeHandler = [settings.viewSizeHandler copy];
        _rendererImageHandler = [MPNativeAdRendererImageHandler new];
        _rendererImageHandler.delegate = self;
    }
    return self;
}

+ (MPNativeAdRendererConfiguration *)rendererConfigurationWithRendererSettings:(id<MPNativeAdRendererSettings>)rendererSettings {
    MPNativeAdRendererConfiguration *config = [[MPNativeAdRendererConfiguration alloc] init];
    config.rendererClass = [self class];
    config.rendererSettings = rendererSettings;
    config.supportedCustomEvents = @[@"AdfurikunMoPubNativeAd"];
    
    return config;
}


- (UIView *)retrieveViewWithAdapter:(id<MPNativeAdAdapter>)adapter error:(NSError *__autoreleasing *)error {
    if (!adapter || ![adapter isKindOfClass:[AdfurikunMoPubNativeAdAdapter class]]) {
        if (error) {
            *error = MPNativeAdNSErrorForRenderValueTypeError();
        }
        return nil;
    }
    self.adapter = adapter;
    
    if ([self.renderingViewClass respondsToSelector:@selector(nibForAd)]) {
        self.adView = (UIView<MPNativeAdRendering> *)[[[self.renderingViewClass nibForAd] instantiateWithOwner:nil options:nil] firstObject];
    } else {
        self.adView = [[self.renderingViewClass alloc] init];
    }
    self.adView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    if ([self.adView respondsToSelector:@selector(nativeMainTextLabel)]) {
        self.adView.nativeMainTextLabel.text = [adapter.properties objectForKey:kAdTextKey];
    }
    if ([self.adView respondsToSelector:@selector(nativeTitleTextLabel)]) {
        self.adView.nativeTitleTextLabel.text = [adapter.properties objectForKey:kAdTitleKey];
    }
    if ([self.adView respondsToSelector:@selector(nativeVideoView)]) {
        UIView *mediaView = self.adapter.mainMediaView;
        mediaView.frame = self.adView.nativeVideoView.bounds;
        [self.adView.nativeVideoView addSubview:mediaView];
    } else if ([self.adView respondsToSelector:@selector(nativeMainImageView)]) {
        UIView *mediaView = self.adapter.mainMediaView;
        mediaView.frame = self.adView.nativeMainImageView.bounds;
        [self.adView.nativeMainImageView addSubview:mediaView];
    }
    return self.adView;
}

- (BOOL)nativeAdViewInViewHierarchy {
    return self.adViewInViewHierarchy;
}

@end
