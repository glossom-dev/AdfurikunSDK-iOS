//
//  MovieReward6010.swift
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/05/20.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

import Foundation
import AMoAd
import ADFMovieReward

@objc(MovieReward6010)

class MovieReward6010: ADFmyMovieRewardInterface {
    var amoadInterstitialVideo: AMoAdInterstitialVideo?
    
    private var sid: String?
    private var tag: String = ""
    private var sourceAppId: String?
    
    private var didLoad = false

    override class func getAdapterRevisionVersion() -> String {
        return "5"
    }
    
    override class func adnetworkClassName() -> String {
        return "AMoAd.AMoAdInterstitialVideo"
    }
    
    override class func adnetworkName() -> String {
        return "Afio"
    }
    
    override func setData(_ data: [AnyHashable : Any]) {
        super.setData(data)

        if let sid = data["sid"] as? String {
            self.sid = sid
        }
        if let tag = data["tag"] as? String {
            self.tag = tag
        }
        if let app_id = data["app_id"] as? String, app_id.count > 0 {
            self.sourceAppId = app_id
        }
        self.adParam = ADFAdnetworkParam.init(param: [:])
    }

    override func initAdnetworkIfNeeded() -> Bool {
        guard amoadInterstitialVideo == nil, let sid = sid else {
            return false
        }
        guard needsToInit() == true else {
            return false
        }

        if ADFMovieOptions.getTestMode() {
            AMoAdLogger.logLevel = .info
        }

        if let sourceAppId = sourceAppId {
            print("MovieReward6010: set source app id: \(sourceAppId)")
            AMoAdSKAdSetting.shared.setSourceAppId(sourceAppId: sourceAppId)
        }

        amoadInterstitialVideo = AMoAdInterstitialVideo.shared(sid: sid, tag: tag)
        amoadInterstitialVideo?.delegate = self
        setCancellable()
        initCompleteAndRetryStartAdIfNeeded()
        return true
    }

    override func startAd() -> Bool {
        guard super.startAd() else {
            return false
        }
        if amoadInterstitialVideo?.isLoaded == false {
            amoadInterstitialVideo?.load()
            didLoad = true
        }
        return true
    }

    override func isPrepared() -> Bool {
        guard let amoadInterstitialVideo = amoadInterstitialVideo else {
            return false
        }
        return (didLoad && delegate != nil && amoadInterstitialVideo.isLoaded)
    }

    override func showAd() {
        super.showAd()

        if isPrepared() {
            amoadInterstitialVideo?.show()
            didLoad = false
        } else {
            setCallbackStatus(MovieRewardCallbackPlayFail)
        }
    }

    override func showAd(withPresenting viewController: UIViewController!) {
        showAd()
    }

    override func isClassReference() -> Bool {
        return true
    }

    func setCancellable() {
        amoadInterstitialVideo?.isCancellable = false
    }
}

extension MovieReward6010: AMoAdInterstitialVideoDelegate {
    func amoadInterstitialVideoDidLoadAd(amoadInterstitialVideo: AMoAdInterstitialVideo, result: AMoAdResult) {
        print("MovieReward6010: amoadInterstitialVideoDidLoadAd, result : \(result)")
        if result == .success {
            print("MovieReward6010: AMoAdResultSuccess")
            setCallbackStatus(MovieRewardCallbackFetchComplete)
        } else {
            setCallbackStatus(MovieRewardCallbackFetchFail)
        }
    }

    func amoadInterstitialVideoDidStart(amoadInterstitialVideo: AMoAdInterstitialVideo) {
        print("MovieReward6010: amoadInterstitialVideoDidStart")
        setCallbackStatus(MovieRewardCallbackPlayStart)
    }

    func amoadInterstitialVideoDidComplete(amoadInterstitialVideo: AMoAdInterstitialVideo) {
        print("MovieReward6010: amoadInterstitialVideoDidComplete")
        setCallbackStatus(MovieRewardCallbackPlayComplete)
    }

    func amoadInterstitialVideoDidFailToPlay(amoadInterstitialVideo: AMoAdInterstitialVideo) {
        print("MovieReward6010: amoadInterstitialVideoDidFailToPlay")
        setCallbackStatus(MovieRewardCallbackPlayFail)
    }

    func amoadInterstitialVideoDidShow(amoadInterstitialVideo: AMoAdInterstitialVideo) {
        print("MovieReward6010: amoadInterstitialVideoDidShow")
        setCallbackStatus(MovieRewardCallbackPlayStart)
    }

    func amoadInterstitialVideoWillDismiss(amoadInterstitialVideo: AMoAdInterstitialVideo) {
        print("MovieReward6010: amoadInterstitialVideoWillDismiss")
        setCallbackStatus(MovieRewardCallbackClose)
    }

    func amoadInterstitialVideoDidClickAd(amoadInterstitialVideo: AMoAdInterstitialVideo) {
        print("MovieReward6010: amoadInterstitialVideoDidClickAd")
    }
}

@objc(MovieReward6180)
class MovieReward6180: MovieReward6010 {
}

@objc(MovieReward6181)
class MovieReward6181: MovieReward6010 {
}

@objc(MovieReward6182)
class MovieReward6182: MovieReward6010 {
}

@objc(MovieReward6183)
class MovieReward6183: MovieReward6010 {
}

@objc(MovieReward6184)
class MovieReward6184: MovieReward6010 {
}
