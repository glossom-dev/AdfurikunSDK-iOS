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
    private var didLoad = false
    
    override init() {
        super.init()
        configure = AdnetworkConfigure6010.sharedInstance()
    }

    override class func getAdapterRevisionVersion() -> String {
        return "8"
    }
    
    override class func adnetworkClassName() -> String {
        return "AMoAd.AMoAdInterstitialVideo"
    }
    
    override class func adnetworkName() -> String {
        return AdnetworkConfigure6010.adnetworkName()
    }
    
    override func setData(_ data: [AnyHashable : Any]) {
        print("MovieReward6010: setData")
        super.setData(data)
        
        adParam = AdnetworkParam6010.init(param: data)
        configure.param = adParam
    }

    override func initAdnetworkIfNeeded() -> Bool {
        guard super.initAdnetworkIfNeeded() == true else {
            return false
        }
        
        weak var weakSelf = self
        configure.initAdnetworkSDK { result in
            guard let strongSelf = weakSelf else {
                return
            }
            guard strongSelf.amoadInterstitialVideo == nil, let param = strongSelf.adParam as? AdnetworkParam6010, let sid = param.sid else {
                print("MovieReward6010: param error")
                return
            }
            print("MovieReward6010: initAdnetworkSDK")
            strongSelf.amoadInterstitialVideo = AMoAdInterstitialVideo.shared(sid: sid, tag: param.tag)
            strongSelf.amoadInterstitialVideo?.delegate = self
            strongSelf.setCancellable()
            strongSelf.initCompleteAndRetryStartAdIfNeeded()
        }
        
        return true
    }

    override func startAd() -> Bool {
        guard super.startAd() else {
            return false
        }
        
        requireToAsyncRequestAd()

        print("MovieReward6010: startAd")
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
            setPlayFailCallback(PlayFailCallbackReasonIsPreparedFalse, exception: nil)
        }
    }

    override func showAd(withPresenting viewController: UIViewController!) {
        showAd()
    }

    override class func isClassReference() -> Bool {
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
        isRewarded = true
        setCallbackStatus(MovieRewardCallbackPlayComplete)
    }

    func amoadInterstitialVideoDidFailToPlay(amoadInterstitialVideo: AMoAdInterstitialVideo) {
        print("MovieReward6010: amoadInterstitialVideoDidFailToPlay")
        setErrorWithMessage("amoadInterstitialVideoDidFailToPlay", code: 0)
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
