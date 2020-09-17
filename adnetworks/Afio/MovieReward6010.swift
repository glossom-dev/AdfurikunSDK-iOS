//
//  MovieReward6010.swift
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/05/20.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

import Foundation
import AMoAd

@objc(MovieReward6010)

class MovieReward6010: ADFmyMovieRewardInterface {
    var amoadInterstitialVideo: AMoAdInterstitialVideo?
    
    private var sid: String?
    private var tag: String = ""

    private var didLoad = false

    override class func getAdapterVersion() -> String! {
        return "6.0.4.1"
    }
    
    override func setData(_ data: [AnyHashable : Any]!) {
        super.setData(data)

        if let sid = data["sid"] as? String {
            self.sid = sid
        }
        if let tag = data["tag"] as? String {
            self.tag = tag
        }
    }

    override func initAdnetworkIfNeeded() {
        guard amoadInterstitialVideo == nil, let sid = sid else {
            return
        }
        amoadInterstitialVideo = AMoAdInterstitialVideo.shared(sid: sid, tag: tag)
        amoadInterstitialVideo?.delegate = self
        setCancellable()
    }

    override func startAd() {
        if amoadInterstitialVideo?.isLoaded == false {
            amoadInterstitialVideo?.load()
            didLoad = true
        }
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
        print("MovieReward6010: amoadInterstitialVideoDidLoadAd")
        if result == .success {
            print("AMoAdResultSuccess")
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
