Pod::Spec.new do |s|
  s.name            = "AdfurikunSDK-iOS"
  s.version         = "3.11.0"
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
    core.libraries = 'z'
    core.pod_target_xcconfig = { 'OTHER_LDFLAGS' => ['-ObjC', '-fobjc-arc'] }
  end

  s.subspec 'AdColony' do |adcolony|
    adcolony.dependency 'AdfurikunSDK-iOS/Core'
    adcolony.dependency 'AdColony', '4.7.2'
    adcolony.source_files = '**/adnetworks/AdColony/*.{h,m}'
    adcolony.resource = '**/adnetworks/AdColony/*.txt'
  end

  s.subspec 'AdMob' do |admob|
    admob.dependency 'AdfurikunSDK-iOS/Core'
    admob.dependency 'Google-Mobile-Ads-SDK', '8.11.0'
    admob.source_files = '**/adnetworks/AdMob/*.{h,m}'
    admob.resource = '**/adnetworks/AdMob/*.{txt,xib}'
  end

  s.subspec 'AppLovin' do |applovin|
    applovin.dependency 'AdfurikunSDK-iOS/Core'
    applovin.dependency 'AppLovinSDK', '10.3.6'
    applovin.source_files = '**/adnetworks/AppLovin/*.{h,m}'
    applovin.resource = '**/adnetworks/AppLovin/*.txt'
  end

  s.subspec 'FAN' do |fan|
    fan.dependency 'AdfurikunSDK-iOS/Core'
    fan.dependency 'FBAudienceNetwork', '6.7.0'
    fan.source_files = '**/adnetworks/FAN/*.{h,m}'
    fan.resource = '**/adnetworks/FAN/*.txt'
  end

  s.subspec 'Maio' do |maio|
    maio.dependency 'AdfurikunSDK-iOS/Core'
    maio.dependency 'MaioSDK', '1.5.8'
    maio.source_files = '**/adnetworks/Maio/*.{h,m}'
    maio.resource = '**/adnetworks/Maio/*.txt'
  end

  s.subspec 'Five' do |five|
    five.dependency 'AdfurikunSDK-iOS/Core'
    five.dependency 'FiveAd', '2.4.20211004'
    five.source_files = '**/adnetworks/Five/*.{h,m}'
    five.resource = '**/adnetworks/Five/*.txt'
  end

  s.subspec 'NendAd' do |nendad|
    nendad.dependency 'AdfurikunSDK-iOS/Core'
    nendad.dependency 'NendSDK_iOS', '7.0.6'
    nendad.source_files = '**/adnetworks/NendAd/*.{h,m}'
    nendad.resource = '**/adnetworks/NendAd/*.txt'
  end

  s.subspec 'Pangle' do |pangle|
    pangle.dependency 'AdfurikunSDK-iOS/Core'
    pangle.dependency 'Ads-Global', '3.9.0.8'
    pangle.source_files = '**/adnetworks/Pangle/*.{h,m}'
    pangle.resource = '**/adnetworks/Pangle/*.txt'
  end

  s.subspec 'Tapjoy' do |tapjoy|
    tapjoy.dependency 'AdfurikunSDK-iOS/Core'
    tapjoy.dependency 'TapjoySDK', '12.8.1'
    tapjoy.source_files = '**/adnetworks/Tapjoy/*.{h,m}'
    tapjoy.resource = '**/adnetworks/Tapjoy/*.txt'
  end

  s.subspec 'UnityAds' do |unityads|
    unityads.dependency 'AdfurikunSDK-iOS/Core'
    unityads.dependency 'UnityAds', '3.7.5'
    unityads.source_files = '**/adnetworks/UnityAds/*.{h,m}'
    unityads.resource = '**/adnetworks/UnityAds/*.txt'
  end

  s.subspec 'Vungle' do |vungle|
    vungle.dependency 'AdfurikunSDK-iOS/Core'
    vungle.dependency 'VungleSDK-iOS', '6.10.3'
    vungle.source_files = '**/adnetworks/Vungle/*.{h,m}'
    vungle.resource = '**/adnetworks/Vungle/*.txt'
  end
  
  s.subspec 'MoPub' do |mopub|
    mopub.dependency 'AdfurikunSDK-iOS/Core'
    mopub.dependency 'mopub-ios-sdk', '5.16.2'
    mopub.source_files = '**/adnetworks/MoPub/*.{h,m}'
    mopub.resource = '**/adnetworks/MoPub/*.{txt,xib}'
  end

  s.subspec 'All' do |all|
    all.dependency 'AdfurikunSDK-iOS/Core'
    all.dependency 'AdfurikunSDK-iOS/AdColony'
    all.dependency 'AdfurikunSDK-iOS/AdMob'
    all.dependency 'AdfurikunSDK-iOS/AppLovin'
    all.dependency 'AdfurikunSDK-iOS/FAN'
    all.dependency 'AdfurikunSDK-iOS/Maio'
    all.dependency 'AdfurikunSDK-iOS/Five'
    all.dependency 'AdfurikunSDK-iOS/NendAd'
    all.dependency 'AdfurikunSDK-iOS/Pangle'
    all.dependency 'AdfurikunSDK-iOS/Tapjoy'
    all.dependency 'AdfurikunSDK-iOS/UnityAds'
    all.dependency 'AdfurikunSDK-iOS/Vungle'
    all.dependency 'AdfurikunSDK-iOS/MoPub'
  end

end
