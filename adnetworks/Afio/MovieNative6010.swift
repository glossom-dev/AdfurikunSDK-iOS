//
//  MovieNative6010.swift
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/05/21.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

import Foundation
import AMoAd
import ADFMovieReward

@objc(MovieNative6010)

class MovieNative6010: ADFmyMovieNativeInterface {

    private var amoadView: UIView!
    private var adView: UIView!
    private var videoView: AMoAdNativeMainVideoView!
    private var shortTitleLabel: UILabel!
    private var longTitleLabel: UILabel!

    private let viewSize = CGRect(x: 0.0, y: 0.0, width: 160.0, height: 90.0)

    override init() {
        super.init()
        configure = AdnetworkConfigure6010.sharedInstance()
    }
    
    deinit {
        if let param = adParam as? AdnetworkParam6010, let sid = param.sid {
            AMoAdNativeViewManager.shared.clearAd(sid: sid)
        }
    }

    override class func getAdapterRevisionVersion() -> String {
        return "7"
    }

    override class func adnetworkClassName() -> String {
        return "AMoAd.AMoAdNativeViewManager"
    }
    
    override class func adnetworkName() -> String {
        return AdnetworkConfigure6010.adnetworkName()
    }
    
    override func setData(_ data: [AnyHashable : Any]) {
        print("MovieNative6010: setData")
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
            strongSelf.initCompleteAndRetryStartAdIfNeeded()
        }
        
        return true
    }

    override func startAd() -> Bool {
        guard super.startAd() else {
            return false
        }

        guard let param = adParam as? AdnetworkParam6010, let sid = param.sid else {
            return false
        }
        
        requireToAsyncRequestAd()
        
        print("MovieNative6010: startAd")
        AMoAdNativeViewManager.shared.prepareAd(sid: sid, iconPreloading: true, imagePreloading: true)

        amoadView?.removeFromSuperview()
        adView?.removeFromSuperview()

        amoadView = UIView(frame: viewSize)

        adView = UIView(frame: viewSize)
        adView.isUserInteractionEnabled = true
        adView.tag = 6
        amoadView.addSubview(adView)

        videoView = AMoAdNativeMainVideoView(frame: viewSize)
        videoView.tag = 7
        videoView.delegate = self
        adView.addSubview(videoView)

        videoView.translatesAutoresizingMaskIntoConstraints = false
        adView.addConstraints([
            NSLayoutConstraint(
                item: videoView,
                attribute: .top,
                relatedBy: .equal,
                toItem: adView,
                attribute: .top,
                multiplier: 1.0,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: videoView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: adView,
                attribute: .bottom,
                multiplier: 1.0,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: videoView,
                attribute: .left,
                relatedBy: .equal,
                toItem: adView,
                attribute: .left,
                multiplier: 1.0,
                constant: 0.0
            ),
            NSLayoutConstraint(
                item: videoView,
                attribute: .right,
                relatedBy: .equal,
                toItem: adView,
                attribute: .right,
                multiplier: 1.0,
                constant: 0.0
            )
        ])

        shortTitleLabel = UILabel(frame: viewSize)
        shortTitleLabel.tag = 3
        amoadView.addSubview(shortTitleLabel)

        longTitleLabel = UILabel(frame: viewSize)
        longTitleLabel.tag = 4
        amoadView.addSubview(longTitleLabel)

        AMoAdNativeViewManager.shared.renderAd(sid: sid, tag: param.tag, view: amoadView, delegate: self)
        
        return true
    }

    override class func isClassReference() -> Bool {
        return true;
    }
}

extension MovieNative6010: AMoAdNativeVideoAppDelegate {
    func amoadNativeVideoDidStart(view amoadNativeMainVideoView: UIView) {
        print("MovieNative6010: amoadNativeVideoDidStart")
        setCallbackStatus(NativeAdCallbackPlayStart)
    }

    func amoadNativeVideoDidComplete(view amoadNativeMainVideoView: UIView) {
        print("MovieNative6010: amoadNativeVideoDidComplete")
        setCallbackStatus(NativeAdCallbackPlayFinish)
    }

    func amoadNativeVideoDidFailToPlay(view amoadNativeMainVideoView: UIView) {
        print("MovieNative6010: amoadNativeVideoDidFailToPlay")
        setCallbackStatus(NativeAdCallbackPlayFail)
    }
}

extension MovieNative6010: AMoAdNativeAppDelegate {
    func amoadNativeDidReceive(sid: String, tag: String, view: UIView, state: AMoAdResult) {
        if state == .success {
            print("MovieNative6010: amoadNativeDidReceive")
            DispatchQueue.main.async { [weak self] in // このCallback内ではテキスト取得ができないため、Callback関数が終わった後取得するように
                guard let `self` = self else { return }

                self.adInfo = MovieNativeAdInfo6010(videoUrl: nil,
                                                    title: self.shortTitleLabel.text ?? "",
                                                    description: self.longTitleLabel.text ?? "",
                                                    adnetworkKey: self.adnetworkKey)
                self.adInfo.mediaType = .movie
                self.adInfo.setupMediaView(self.adView)
                self.adInfo.adapter = self

                self.setCallbackStatus(NativeAdCallbackLoadFinish)
            }
        }
    }

    func amoadNativeIconDidReceive(sid: String, tag: String, view: UIView, state: AMoAdResult) {
        print("MovieNative6010: amoadNativeIconDidReceive")
    }

    func amoadNativeImageDidReceive(sid: String, tag: String, view: UIView, state: AMoAdResult) {
        print("MovieNative6010: amoadNativeImageDidReceive")
    }

    func amoadNativeDidClick(sid: String, tag: String, view: UIView) {
        print("MovieNative6010: amoadNativeDidClick")
        setCallbackStatus(NativeAdCallbackClick)
    }
}

class MovieNativeAdInfo6010: ADFNativeAdInfo {
    override func registerInteractionViews(_ views: [UIView]) {
        print("[ADF] [SEVERE] AfiOはregisterInteractionViewsをサポートしません。")
    }
}

@objc(MovieNative6180)
class MovieNative6180: MovieNative6010 {
}

@objc(MovieNative6181)
class MovieNative6181: MovieNative6010 {
}

@objc(MovieNative6182)
class MovieNative6182: MovieNative6010 {
}

@objc(MovieNative6183)
class MovieNative6183: MovieNative6010 {
}

@objc(MovieNative6184)
class MovieNative6184: MovieNative6010 {
}
