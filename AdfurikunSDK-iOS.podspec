Pod::Spec.new do |s|
  s.name            = "AdfurikunSDK-iOS"
  s.version         = "0.4.2.1"
  s.summary         = "An iOS SDK for ADFURIKUN Movie Reward Ads"
  s.homepage        = "https://adfurikun.jp/adfurikun/"
  s.license         = { :type => 'Copyright', :text => 'Copyright GREE X, Inc. All rights reserved.' }
  s.author          = "GREE X, Inc."
  s.platform        = :ios, "13.0"
  s.source          = { :git => "https://github.com/glossom-dev/AdfurikunSDK-iOS", :tag => "#{s.version}" }
  s.resource_bundles = {'AdfurikunSDK-iOS_resources' => ['PrivacyInfo.xcprivacy']}  
  s.default_subspec = 'All'
  s.static_framework = true
  s.swift_version = '5.0'
  s.xcconfig = { "VALID_ARCHS": "armv7 armv7s x86_64 arm64" }
  
  s.subspec 'Core' do |core|
    core.vendored_frameworks = '**/ADFMovieReward.xcframework'
    core.frameworks = 'AdSupport', 'AVFoundation', 'CoreGraphics', 'CoreMedia', 'CoreTelephony', 'MediaPlayer', 'StoreKit', 'SystemConfiguration', 'SafariServices', 'UIKit', 'WebKit'
    core.libraries = 'z'
    core.pod_target_xcconfig = { 'OTHER_LDFLAGS' => ['-ObjC', '-fobjc-arc'] }
  end

  s.subspec 'AdMob' do |admob|
    admob.dependency 'AdfurikunSDK-iOS/Core'
    admob.dependency 'Google-Mobile-Ads-SDK', '>=11.2.0'
    admob.source_files = '**/adnetworks/AdMob/*.{h,m}'
    admob.resource = '**/adnetworks/AdMob/*.{txt,xib}'
  end

  s.subspec 'AdMobMediationAdapter' do |admobMediationAdapter|
    admobMediationAdapter.dependency 'AdfurikunSDK-iOS/Core'
    admobMediationAdapter.dependency 'Google-Mobile-Ads-SDK', '>=11.2.0'
    admobMediationAdapter.source_files = '**/adnetworks/AdMobMediationAdapter/*.{h,m}'
  end

  s.subspec 'AdMobMediationAdapterUnity' do |admobMediationAdapterUnity|
    admobMediationAdapterUnity.dependency 'AdfurikunSDK-iOS/Core'
    admobMediationAdapterUnity.dependency 'AdfurikunSDK-iOS/AdMobMediationAdapter'
    admobMediationAdapterUnity.source_files = '**/adnetworks/AdMobMediationAdapter/Unity/*.{h,m}'
  end

  s.subspec 'Afio' do |afio|
    afio.dependency 'AdfurikunSDK-iOS/Core'
    afio.dependency 'AMoAd', '<=6.2.7'
    afio.source_files = '**/adnetworks/Afio/*.swift'
    afio.resource = '**/adnetworks/Afio/*.txt'
  end

  s.subspec 'AppLovin' do |applovin|
    applovin.dependency 'AdfurikunSDK-iOS/Core'
    applovin.dependency 'AppLovinSDK', '13.1.0'
    applovin.source_files = '**/adnetworks/AppLovin/*.{h,m}'
    applovin.resource = '**/adnetworks/AppLovin/*.txt'
  end

  s.subspec 'FAN' do |fan|
    fan.dependency 'AdfurikunSDK-iOS/Core'
    fan.dependency 'FBAudienceNetwork', '6.9.0'
    fan.source_files = '**/adnetworks/FAN/*.{h,m}'
    fan.resource = '**/adnetworks/FAN/*.txt'
  end

  s.subspec 'Five' do |five|
    five.dependency 'AdfurikunSDK-iOS/Core'
    five.dependency 'FiveAd', '2.9.20250512'
    five.source_files = '**/adnetworks/Five/*.{h,m}'
    five.resource = '**/adnetworks/Five/*.txt'
  end

  s.subspec 'Fyber' do |fyber|
    fyber.dependency 'AdfurikunSDK-iOS/Core'
    fyber.dependency 'Fyber_Marketplace_SDK', '8.3.2'
    fyber.source_files = '**/adnetworks/Fyber/*.{h,m}'
    fyber.resource = '**/adnetworks/Fyber/*.txt'
  end

  s.subspec 'InMobi' do |inMobi|
    inMobi.dependency 'AdfurikunSDK-iOS/Core'
    inMobi.dependency 'InMobiSDK', '10.8.3'
    inMobi.source_files = '**/adnetworks/InMobi/*.{h,m}'
    inMobi.resource = '**/adnetworks/InMobi/*.txt'
  end

  s.subspec 'ironSource' do |ironSource|
    ironSource.dependency 'AdfurikunSDK-iOS/Core'
    ironSource.dependency 'IronSourceSDK', '8.10.0.0'
    ironSource.source_files = '**/adnetworks/IronSource/*.{h,m}'
    ironSource.resource = '**/adnetworks/IronSource/*.txt'
  end

  s.subspec 'Maio' do |maio|
    maio.dependency 'AdfurikunSDK-iOS/Core'
    maio.dependency 'MaioSDK-v2', '2.1.6'
    maio.source_files = '**/adnetworks/Maio/*.{h,m}'
    maio.resource = '**/adnetworks/Maio/*.txt'
  end

  s.subspec 'Mintegral' do |mintegral|
    mintegral.dependency 'AdfurikunSDK-iOS/Core'
    mintegral.dependency 'MintegralAdSDK/BidNativeAd', '7.7.9'
    mintegral.dependency 'MintegralAdSDK/BidNativeAdvancedAd', '7.7.9'
    mintegral.dependency 'MintegralAdSDK/BidRewardVideoAd', '7.7.9'
    mintegral.dependency 'MintegralAdSDK/BidNewInterstitialAd', '7.7.9'
    mintegral.dependency 'MintegralAdSDK/BidBannerAd', '7.7.9'
    mintegral.dependency 'MintegralAdSDK/BidSplashAd', '7.7.9'
    mintegral.source_files = '**/adnetworks/Mintegral/*.{h,m}'
    mintegral.resource = '**/adnetworks/Mintegral/*.txt'
  end

  s.subspec 'Pangle' do |pangle|
    pangle.dependency 'AdfurikunSDK-iOS/Core'
    pangle.dependency 'Ads-Global', '7.1.1.1'
    pangle.source_files = '**/adnetworks/Pangle/*.{h,m}'
    pangle.resource = '**/adnetworks/Pangle/*.txt'
  end

  s.subspec 'UnityAds' do |unityads|
    unityads.dependency 'AdfurikunSDK-iOS/Core'
    unityads.dependency 'UnityAds', '4.12.5'
    unityads.source_files = '**/adnetworks/UnityAds/*.{h,m}'
    unityads.resource = '**/adnetworks/UnityAds/*.txt'
  end

  s.subspec 'Vungle' do |vungle|
    vungle.dependency 'AdfurikunSDK-iOS/Core'
    vungle.dependency 'VungleAds', '7.4.2'
    vungle.source_files = '**/adnetworks/Vungle/*.{h,m}'
    vungle.resource = '**/adnetworks/Vungle/*.txt'
  end

  s.subspec 'All' do |all|
    all.dependency 'AdfurikunSDK-iOS/Core'
    all.dependency 'AdfurikunSDK-iOS/AdMob'
    all.dependency 'AdfurikunSDK-iOS/Afio'
    all.dependency 'AdfurikunSDK-iOS/AppLovin'
    all.dependency 'AdfurikunSDK-iOS/Five'
    all.dependency 'AdfurikunSDK-iOS/Fyber'
    all.dependency 'AdfurikunSDK-iOS/InMobi'
    all.dependency 'AdfurikunSDK-iOS/ironSource'
    all.dependency 'AdfurikunSDK-iOS/Maio'
    all.dependency 'AdfurikunSDK-iOS/Mintegral'
    all.dependency 'AdfurikunSDK-iOS/Pangle'
    all.dependency 'AdfurikunSDK-iOS/UnityAds'
    all.dependency 'AdfurikunSDK-iOS/Vungle'
  end

end
