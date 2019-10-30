//
//  Bid.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 10.10.19.
//

import Foundation

@objc(YLDBid)
public class Bid: NSObject {
    
    var slotID: Int
    
    var _customTargeting: [String: Any]
    
    init (slotID: Int, customTargeting: [String: Any]) {
        self.slotID = slotID
        _customTargeting = customTargeting
    }
    
    @objc(customTargetingWithError:)
    public func customTargeting () throws -> [String: Any] {
        _customTargeting
    }
    
}
