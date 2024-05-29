//
//  MovieInterstitial6010.swift
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/05/20.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

import Foundation
import ADFMovieReward

@objc(MovieInterstitial6010)

class MovieInterstitial6010: MovieReward6010 {
    override init() {
        super.init()
        setCancellable()
    }

    override func setCancellable() {
        amoadInterstitialVideo?.isCancellable = true
    }
}

@objc(MovieInterstitial6180)
class MovieInterstitial6180: MovieInterstitial6010 {
}

@objc(MovieInterstitial6181)
class MovieInterstitial6181: MovieInterstitial6010 {
}

@objc(MovieInterstitial6182)
class MovieInterstitial6182: MovieInterstitial6010 {
}

@objc(MovieInterstitial6183)
class MovieInterstitial6183: MovieInterstitial6010 {
}

@objc(MovieInterstitial6184)
class MovieInterstitial6184: MovieInterstitial6010 {
}
