//
//  AdnetworkConfigure6010.swift
//  MovieRewardTestApp
//

import Foundation
import AMoAd
import ADFMovieReward

@objc(AdnetworkConfigure6010)

class AdnetworkConfigure6010: ADFmyAdnetworkConfigure {
    private static var instance = AdnetworkConfigure6010()
    
    // Self()を利用する為にrequired initが必要
    required override init() {
        super.init()
    }
    
    override class func sharedInstance() -> Self {
        if let instance = instance as? Self {
            return instance
        }
        print("AdnetworkConfigure6010: sharedInstance return: Self()")
        return Self()
    }
    
    override class func adnetworkName() -> String {
        return "Afio"
    }
    
    override func initAdnetworkSDK() {
        if ADFMovieOptions.getTestMode() {
            AMoAdLogger.logLevel = .info
        }
        
        if let param = param as? AdnetworkParam6010, let sourceAppId = param.sourceAppId {
            print("AdnetworkConfigure6010: set source app id: \(sourceAppId)")
            AMoAdSKAdSetting.shared.setSourceAppId(sourceAppId: sourceAppId)
        }
        
        initSuccess()
    }
}
