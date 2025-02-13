//
//  AdnetworkParam6010.swift
//  MovieRewardTestApp
//

import Foundation
import ADFMovieReward

@objc(AdnetworkParam6010)

class AdnetworkParam6010: ADFAdnetworkParam {
    var sid: String?
    var tag: String = ""
    var sourceAppId: String?
 
    override init(param: [AnyHashable : Any]) {
        super.init(param: param)
        
        if let sid = param["sid"] as? String {
            self.sid = sid
        }
        if let tag = param["tag"] as? String {
            self.tag = tag
        }
        if let app_id = param["app_id"] as? String, app_id.count > 0 {
            self.sourceAppId = app_id
        }
    }
    
    override func isValid() -> Bool {
        return sid != nil
    }
}
