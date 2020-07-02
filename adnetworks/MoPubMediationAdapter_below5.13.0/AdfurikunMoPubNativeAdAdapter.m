//
//  AdfurikunMoPubNativeAdAdapter.m
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

#import "AdfurikunMoPubNativeAdAdapter.h"

@interface AdfurikunMoPubNativeAdAdapter () <ADFMediaViewDelegate>
@property (nonatomic)ADFNativeAdInfo *adfurikunAdInfo;
@property (nonatomic)NSString *appId;
@end

@implementation AdfurikunMoPubNativeAdAdapter

@synthesize properties = _properties;

- (instancetype)initWithAdInfo:(ADFNativeAdInfo *)adInfo appId:(NSString *)appId {
    if (self = [super init]) {
        self.appId = appId;
        self.adfurikunAdInfo = adInfo;
        adInfo.mediaView.mediaViewDelegate = self;
        [adInfo playMediaView];
        
        NSMutableDictionary *properties;
        if (adInfo.title) {
            [properties setObject:adInfo.title forKey:kAdTitleKey];
        }
        if (adInfo.desc) {
            [properties setObject:adInfo.desc forKey:kAdTextKey];
        }
        [properties setObject:adInfo.mediaView forKey:kAdMainMediaViewKey];
        _properties = properties;
    }
    return self;
}

- (void)willAttachToView:(UIView *)view {
    
}

- (void)willAttachToView:(UIView *)view withAdContentViews:(NSArray *)adContentViews {
    [self.adfurikunAdInfo registerInteractionViews:adContentViews];
}

#pragma mark - MPNativeAdAdapter

- (NSURL *)defaultActionURL {
    return nil;
}

- (UIView *)mainMediaView {
    return self.adfurikunAdInfo.mediaView;
}

#pragma mark - ADFMediaViewDelegate

- (void)onADFMediaViewPlayStart {
    MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], self.appId);
    MPLogAdEvent([MPLogEvent adWillAppearForAdapter:NSStringFromClass(self.class)], self.appId);
    [self.delegate nativeAdWillLogImpression:self];
}

- (void)onADFMediaViewPlayFail {
    
}

- (void)onADFMediaViewClick {
    [self.delegate nativeAdDidClick:self];
}

- (void)onADFMediaViewPlayFinish {
    
}

@end
