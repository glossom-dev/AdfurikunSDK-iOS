//
//  MovieInterstitial6010.swift
//  MovieRewardTestApp
//
//  Created by Sungil Kim on 2020/05/20.
//  Copyright © 2020 Glossom, Inc. All rights reserved.
//

import Foundation

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
