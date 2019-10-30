//
//  Bid.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 10.10.19.
//

import Foundation

/// A successful bid for an ad slot.
@objc(YLDBid)
public class Bid: NSObject {
    
    var slotID: Int
    
    var _customTargeting: [String: Any]
    
    init (slotID: Int, customTargeting: [String: Any]) {
        self.slotID = slotID
        _customTargeting = customTargeting
    }
    
    /// Get the targeting information for this bid.
    ///
    /// Use thid method to request a dictionary that you can pass on to your ad server SDK.
    @objc(customTargetingWithError:)
    public func customTargeting () throws -> [String: Any] {
        _customTargeting
    }
    
}
