Pod::Spec.new do |s|
  s.name            = "AdfurikunSDK-iOS"
  s.version         = "3.2.2"
  s.summary         = "An iOS SDK for ADFURIKUN Movie Reward Ads"
  s.homepage        = "https://adfurikun.jp/adfurikun/"
  s.license         = { :type => 'Copyright', :text => 'Copyright Glossom Inc. All rights reserved.' }
  s.author          = "Glossom Inc."
  s.platform        = :ios, "9.0"
  s.source          = { :git => "https://github.com/glossom-dev/AdfurikunSDK-iOS", :tag => "#{s.version}" }
  s.default_subspec = 'All'
  s.static_framework = true
  
  s.subspec 'Core' do |core|
    core.vendored_frameworks = '**/ADFMovieReward.framework'
    core.frameworks = 'AdSupport', 'AVFoundation', 'CoreGraphics', 'CoreMedia', 'CoreTelephony', 'MediaPlayer', 'StoreKit', 'SystemConfiguration', 'SafariServices', 'UIKit', 'WebKit'
    core.pod_target_xcconfig = { 'OTHER_LDFLAGS' => ['-ObjC', '-fobjc-arc'] }
  end

  s.subspec 'AdColony' do |adcolony|
    adcolony.dependency 'AdfurikunSDK-iOS/Core'
    adcolony.dependency 'AdColony', '4.1.1'
    adcolony.source_files = '**/adnetworks/AdColony/*.{h,m,txt}'
  end

  s.subspec 'AdMob' do |admob|
    admob.dependency 'AdfurikunSDK-iOS/Core'
    admob.source_files = '**/adnetworks/AdMob/*.{h,m,txt}'
  end

  s.subspec 'AfiO' do |afio|
    afio.dependency 'AdfurikunSDK-iOS/Core'
    afio.dependency 'AMoAd', '5.2.8'
    afio.source_files = '**/adnetworks/Afio/*.{h,m,txt}'
  end

  s.subspec 'AppLovin' do |applovin|
    applovin.dependency 'AdfurikunSDK-iOS/Core'
    applovin.dependency 'AppLovinSDK', '6.10.1'
    applovin.source_files = '**/adnetworks/AppLovin/*.{h,m,txt}'
  end

  s.subspec 'FAN' do |fan|
    fan.dependency 'AdfurikunSDK-iOS/Core'
    fan.source_files = '**/adnetworks/FAN/*.{h,m,txt}'
  end

  s.subspec 'Maio' do |maio|
    maio.dependency 'AdfurikunSDK-iOS/Core'
    maio.dependency 'MaioSDK', '1.4.8'
    maio.source_files = '**/adnetworks/Maio/*.{h,m,txt}'
  end

  s.subspec 'NendAd' do |nendad|
    nendad.dependency 'AdfurikunSDK-iOS/Core'
    nendad.dependency 'NendSDK_iOS', '5.3.0'
    nendad.source_files = '**/adnetworks/NendAd/*.{h,m,txt}'
  end

  s.subspec 'Pangle' do |pangle|
    pangle.dependency 'AdfurikunSDK-iOS/Core'
    pangle.dependency 'Bytedance-UnionAD', '2.5.1.5'
    pangle.source_files = '**/adnetworks/Pangle/*.{h,m,txt}'
  end

  s.subspec 'Tapjoy' do |tapjoy|
    tapjoy.dependency 'AdfurikunSDK-iOS/Core'
    tapjoy.dependency 'TapjoySDK', '12.3.4'
    tapjoy.source_files = '**/adnetworks/Tapjoy/*.{h,m,txt}'
  end

  s.subspec 'UnityAds' do |unityads|
    unityads.dependency 'AdfurikunSDK-iOS/Core'
    unityads.dependency 'UnityAds', '3.4.0'
    unityads.source_files = '**/adnetworks/UnityAds/*.{h,m,txt}'
  end

  s.subspec 'Vungle' do |vungle|
    vungle.dependency 'AdfurikunSDK-iOS/Core'
    vungle.dependency 'VungleSDK-iOS', '6.4.6'
    vungle.source_files = '**/adnetworks/Vungle/*.{h,m,txt}'
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
  end

end
