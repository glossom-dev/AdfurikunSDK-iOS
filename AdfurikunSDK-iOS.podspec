Pod::Spec.new do |s|
  s.name            = "AdfurikunSDK-iOS"
  s.version         = "3.5.0"
  s.summary         = "An iOS SDK for ADFURIKUN Movie Reward Ads"
  s.homepage        = "https://adfurikun.jp/adfurikun/"
  s.license         = { :type => 'Copyright', :text => 'Copyright Glossom Inc. All rights reserved.' }
  s.author          = "Glossom Inc."
  s.platform        = :ios, "10.0"
  s.source          = { :git => "https://github.com/glossom-dev/AdfurikunSDK-iOS", :tag => "#{s.version}" }
  s.default_subspec = 'All'
  s.static_framework = true
  s.xcconfig = { "VALID_ARCHS": "armv7 armv7s x86_64 arm64" }
  
  s.subspec 'Core' do |core|
    core.vendored_frameworks = '**/ADFMovieReward.framework'
    core.frameworks = 'AdSupport', 'AVFoundation', 'CoreGraphics', 'CoreMedia', 'CoreTelephony', 'MediaPlayer', 'StoreKit', 'SystemConfiguration', 'SafariServices', 'UIKit', 'WebKit'
    core.pod_target_xcconfig = { 'OTHER_LDFLAGS' => ['-ObjC', '-fobjc-arc'] }
  end

  s.subspec 'AdColony' do |adcolony|
    adcolony.dependency 'AdfurikunSDK-iOS/Core'
    adcolony.dependency 'AdColony', '4.1.5'
    adcolony.source_files = '**/adnetworks/AdColony/*.{h,m,txt}'
  end

  s.subspec 'AdMob' do |admob|
    admob.dependency 'AdfurikunSDK-iOS/Core'
    admob.dependency 'Google-Mobile-Ads-SDK', '7.58.0'
    admob.source_files = '**/adnetworks/AdMob/*.{h,m,txt}'
  end

  s.subspec 'AfiO' do |afio|
    afio.dependency 'AdfurikunSDK-iOS/Core'
    afio.dependency 'AMoAd', '6.0.4'
    afio.source_files = '**/adnetworks/Afio/*.{h,m,txt}'
  end

  s.subspec 'AppLovin' do |applovin|
    applovin.dependency 'AdfurikunSDK-iOS/Core'
    applovin.dependency 'AppLovinSDK', '6.12.8'
    applovin.source_files = '**/adnetworks/AppLovin/*.{h,m,txt}'
  end

  s.subspec 'FAN' do |fan|
    fan.dependency 'AdfurikunSDK-iOS/Core'
    fan.dependency 'FBAudienceNetwork', '5.9.0'
    fan.source_files = '**/adnetworks/FAN/*.{h,m,txt}'
  end

  s.subspec 'Maio' do |maio|
    maio.dependency 'AdfurikunSDK-iOS/Core'
    maio.dependency 'MaioSDK', '1.5.4'
    maio.source_files = '**/adnetworks/Maio/*.{h,m,txt}'
  end

  s.subspec 'NendAd' do |nendad|
    nendad.dependency 'AdfurikunSDK-iOS/Core'
    nendad.dependency 'NendSDK_iOS', '5.4.1'
    nendad.source_files = '**/adnetworks/NendAd/*.{h,m,txt}'
  end

  s.subspec 'Pangle' do |pangle|
    pangle.dependency 'AdfurikunSDK-iOS/Core'
    pangle.dependency 'Bytedance-UnionAD', '3.0.0.2'
    pangle.source_files = '**/adnetworks/Pangle/*.{h,m,txt}'
  end

  s.subspec 'Tapjoy' do |tapjoy|
    tapjoy.dependency 'AdfurikunSDK-iOS/Core'
    tapjoy.dependency 'TapjoySDK', '12.4.2'
    tapjoy.source_files = '**/adnetworks/Tapjoy/*.{h,m,txt}'
  end

  s.subspec 'UnityAds' do |unityads|
    unityads.dependency 'AdfurikunSDK-iOS/Core'
    unityads.dependency 'UnityAds', '3.4.6'
    unityads.source_files = '**/adnetworks/UnityAds/*.{h,m,txt}'
  end

  s.subspec 'Vungle' do |vungle|
    vungle.dependency 'AdfurikunSDK-iOS/Core'
    vungle.dependency 'VungleSDK-iOS', '6.5.3'
    vungle.source_files = '**/adnetworks/Vungle/*.{h,m,txt}'
  end
  
  s.subspec 'MoPub' do |mopub|
    mopub.dependency 'AdfurikunSDK-iOS/Core'
    mopub.dependency 'mopub-ios-sdk', '5.13.0'
    mopub.source_files = '**/adnetworks/MoPub/*.{h,m,txt}'
  end

  s.subspec 'All' do |all|
    all.dependency 'AdfurikunSDK-iOS/Core'
    all.dependency 'AdfurikunSDK-iOS/AdColony'
    all.dependency 'AdfurikunSDK-iOS/AdMob'
    all.dependency 'AdfurikunSDK-iOS/AfiO'
    all.dependency 'AdfurikunSDK-iOS/AppLovin'
    all.dependency 'AdfurikunSDK-iOS/FAN'
    all.dependency 'AdfurikunSDK-iOS/Maio'
    all.dependency 'AdfurikunSDK-iOS/NendAd'
    all.dependency 'AdfurikunSDK-iOS/Pangle'
    all.dependency 'AdfurikunSDK-iOS/Tapjoy'
    all.dependency 'AdfurikunSDK-iOS/UnityAds'
    all.dependency 'AdfurikunSDK-iOS/Vungle'
    all.dependency 'AdfurikunSDK-iOS/MoPub'
  end

end
