Pod::Spec.new do |s|
  s.name            = "AdfurikunSDK-iOS"
  s.version         = "3.19.3.3"
  s.summary         = "An iOS SDK for ADFURIKUN Movie Reward Ads"
  s.homepage        = "https://adfurikun.jp/adfurikun/"
  s.license         = { :type => 'Copyright', :text => 'Copyright Glossom Inc. All rights reserved.' }
  s.author          = "Glossom Inc."
  s.platform        = :ios, "11.0"
  s.source          = { :git => "https://github.com/glossom-dev/AdfurikunSDK-iOS", :tag => "#{s.version}" }
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

  s.subspec 'AdColony' do |adcolony|
    adcolony.dependency 'AdfurikunSDK-iOS/Core'
    adcolony.dependency 'AdColony', '4.9.0'
    adcolony.source_files = '**/adnetworks/AdColony/*.{h,m}'
    adcolony.resource = '**/adnetworks/AdColony/*.txt'
  end

  s.subspec 'AdMob' do |admob|
    admob.dependency 'AdfurikunSDK-iOS/Core'
    admob.dependency 'Google-Mobile-Ads-SDK'
    admob.source_files = '**/adnetworks/AdMob/*.{h,m}'
    admob.resource = '**/adnetworks/AdMob/*.{txt,xib}'
  end

  s.subspec 'Afio' do |afio|
    afio.dependency 'AdfurikunSDK-iOS/Core'
    afio.dependency 'AMoAd', '<=6.1.16'
    afio.source_files = '**/adnetworks/Afio/*.swift'
    afio.resource = '**/adnetworks/Afio/*.txt'
  end

  s.subspec 'AppLovin' do |applovin|
    applovin.dependency 'AdfurikunSDK-iOS/Core'
    applovin.dependency 'AppLovinSDK', '11.10.1'
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
    five.dependency 'FiveAd', '2.6.20230609'
    five.source_files = '**/adnetworks/Five/*.{h,m}'
    five.resource = '**/adnetworks/Five/*.txt'
  end

  s.subspec 'Fyber' do |fyber|
    fyber.dependency 'AdfurikunSDK-iOS/Core'
    fyber.dependency 'Fyber_Marketplace_SDK', '8.2.2'
    fyber.source_files = '**/adnetworks/Fyber/*.{h,m}'
    fyber.resource = '**/adnetworks/Fyber/*.txt'
  end

  s.subspec 'ironSource' do |ironSource|
    ironSource.dependency 'AdfurikunSDK-iOS/Core'
    ironSource.dependency 'IronSourceSDK', '7.3.1'
    ironSource.source_files = '**/adnetworks/IronSource/*.{h,m}'
    ironSource.resource = '**/adnetworks/IronSource/*.txt'
  end

  s.subspec 'Maio' do |maio|
    maio.dependency 'AdfurikunSDK-iOS/Core'
    maio.dependency 'MaioSDK', '1.6.3'
    maio.source_files = '**/adnetworks/Maio/*.{h,m}'
    maio.resource = '**/adnetworks/Maio/*.txt'
  end

  s.subspec 'NendAd' do |nendad|
    nendad.dependency 'AdfurikunSDK-iOS/Core'
    nendad.dependency 'NendSDK_iOS', '8.0.1'
    nendad.source_files = '**/adnetworks/NendAd/*.{h,m}'
    nendad.resource = '**/adnetworks/NendAd/*.txt'
  end

  s.subspec 'Pangle' do |pangle|
    pangle.dependency 'AdfurikunSDK-iOS/Core'
    pangle.dependency 'Ads-Global', '5.1.1.0'
    pangle.source_files = '**/adnetworks/Pangle/*.{h,m}'
    pangle.resource = '**/adnetworks/Pangle/*.txt'
  end

  s.subspec 'UnityAds' do |unityads|
    unityads.dependency 'AdfurikunSDK-iOS/Core'
    unityads.dependency 'UnityAds', '4.8.0'
    unityads.source_files = '**/adnetworks/UnityAds/*.{h,m}'
    unityads.resource = '**/adnetworks/UnityAds/*.txt'
  end

  s.subspec 'Vungle' do |vungle|
    vungle.dependency 'AdfurikunSDK-iOS/Core'
    vungle.dependency 'VungleSDK-iOS', '6.12.3'
    vungle.source_files = '**/adnetworks/Vungle/*.{h,m}'
    vungle.resource = '**/adnetworks/Vungle/*.txt'
  end

  s.subspec 'Mintegral' do |mintegral|
    mintegral.dependency 'AdfurikunSDK-iOS/Core'
    mintegral.dependency 'MintegralAdSDK/BidNativeAd', '7.3.9'
    mintegral.dependency 'MintegralAdSDK/BidNativeAdvancedAd', '7.3.9'
    mintegral.dependency 'MintegralAdSDK/BidRewardVideoAd', '7.3.9'
    mintegral.dependency 'MintegralAdSDK/BidNewInterstitialAd', '7.3.9'
    mintegral.dependency 'MintegralAdSDK/BidBannerAd', '7.3.9'
    mintegral.dependency 'MintegralAdSDK/BidSplashAd', '7.3.9'
    mintegral.source_files = '**/adnetworks/Mintegral/*.{h,m}'
    mintegral.resource = '**/adnetworks/Mintegral/*.txt'
  end

  s.subspec 'Zucks' do |zucks|
    zucks.dependency 'AdfurikunSDK-iOS/Core'
    zucks.dependency 'ZucksAdNetworkSDK', '4.11.0'
    zucks.source_files = '**/adnetworks/Zucks/*.{h,m}'
    zucks.resource = '**/adnetworks/Zucks/*.txt'
  end
  
  s.subspec 'All' do |all|
    all.dependency 'AdfurikunSDK-iOS/Core'
    all.dependency 'AdfurikunSDK-iOS/AdColony'
    all.dependency 'AdfurikunSDK-iOS/AdMob'
    all.dependency 'AdfurikunSDK-iOS/Afio'
    all.dependency 'AdfurikunSDK-iOS/AppLovin'
    all.dependency 'AdfurikunSDK-iOS/Five'
    all.dependency 'AdfurikunSDK-iOS/Fyber'
    all.dependency 'AdfurikunSDK-iOS/ironSource'
    all.dependency 'AdfurikunSDK-iOS/Maio'
    all.dependency 'AdfurikunSDK-iOS/NendAd'
    all.dependency 'AdfurikunSDK-iOS/Pangle'
    all.dependency 'AdfurikunSDK-iOS/UnityAds'
    all.dependency 'AdfurikunSDK-iOS/Vungle'
    all.dependency 'AdfurikunSDK-iOS/Mintegral'
    all.dependency 'AdfurikunSDK-iOS/Zucks'
  end

end
