// swift-tools-version:5.9
// Adnetwork SDK(SPM対応分)のバージョンをまとめて管理するファイル。
//
// - ここでピン留めしたバージョンが update_sdk.sh 実行時に各ADNWフォルダへ配置されます。
// - バージョンを上げる/下げる場合は、このファイルの `exact:` の値だけを変更してください。
import PackageDescription

let package = Package(
    name: "AdnetworkSDKs",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "AdnetworkSDKs", targets: ["AdnetworkSDKs"])
    ],
    dependencies: [
        // AdMob
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", exact: "13.7.0"),
        // AdMob (GoogleMobileAdsが依存として要求するUMP。GoogleMobileAds側のPackage.swiftは
        // バージョン範囲でしか指定していないため、ここで明示的にピン留めしないと
        // 上位互換のないメジャーバージョンに勝手に上がってしまうことがある。
        // 例: 2.x -> 3.x で `UMPConsentInformation` が `ConsentInformation` にリネームされ、
        // CocoaPodsで使っていた 2.6.0 のコードがそのままではビルドできなくなる)
        .package(url: "https://github.com/googleads/swift-package-manager-google-user-messaging-platform.git", exact: "2.6.0"),
        // AfiO (AMoAd)
        .package(url: "https://github.com/amoad/amoad-ios-sdk", exact: "6.3.0"),
        // AppLovin
        .package(url: "https://github.com/AppLovin/AppLovin-MAX-Swift-Package.git", exact: "13.6.4"),
        // FiveAd
        .package(url: "https://github.com/ly-ads-network/swift-package-manager-fivead", exact: "3.1.1"),
        // Fyber
        .package(url: "https://github.com/inner-active/DTExchangeSDK-iOS-SPM.git", exact: "8.4.10"),
        // InMobi
        .package(url: "https://github.com/InMobi/InMobiSDK-Swift-Package.git", exact: "11.4.1"),
        // Maio
        .package(url: "https://github.com/imobile/MaioSDK-v2-iOS", exact: "2.2.2"),
        // Mintegral
        .package(url: "https://github.com/Mintegral-official/MintegralAdSDK-Swift-Package.git", exact: "8.1.7"),
        // Pangle
        .package(url: "https://github.com/bytedance/AdsGlobalPackage.git", exact: "8.2.1-release.2"),
        // UnityAds
        .package(url: "https://github.com/Unity-Technologies/Unity-Ads-Swift-Package.git", exact: "4.20.0"),
        // Vungle
        .package(url: "https://github.com/Vungle/VungleAdsSDK-SwiftPackageManager.git", exact: "7.7.7"),
    ],
    targets: [
        // このターゲット自体はビルドされません。update_sdk.sh が
        // `swift package resolve` でこの依存グラフを解決し、
        // .build/artifacts (または .build/checkouts) 配下にダウンロードされた
        // xcframework を各ADNWフォルダにコピーします。
        .target(
            name: "AdnetworkSDKs",
            dependencies: [
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
                .product(name: "GoogleUserMessagingPlatform", package: "swift-package-manager-google-user-messaging-platform"),
                .product(name: "AMoAd", package: "amoad-ios-sdk"),
                .product(name: "AppLovinSDK", package: "AppLovin-MAX-Swift-Package"),
                .product(name: "FiveAd", package: "swift-package-manager-fivead"),
                .product(name: "DTExchangeSDK", package: "DTExchangeSDK-iOS-SPM"),
                .product(name: "InMobiSDK", package: "InMobiSDK-Swift-Package"),
                .product(name: "MaioSDK", package: "MaioSDK-v2-iOS"),
                .product(name: "MintegralAdSDK", package: "MintegralAdSDK-Swift-Package"),
                .product(name: "TikTokBusinessSDK", package: "AdsGlobalPackage"),
                .product(name: "UnityAds", package: "Unity-Ads-Swift-Package"),
                .product(name: "VungleAdsSDK", package: "VungleAdsSDK-SwiftPackageManager"),
            ]
        )
    ]
)
