//
//  Bid.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 10.10.19.
//

public class Bid {
    
    var slotID: Int
    
    var _customTargeting: [String: Any]
    
    init (slotID: Int, customTargeting: [String: Any]) {
        self.slotID = slotID
        _customTargeting = customTargeting
    }
    
    func customTargeting () -> [String: Any] {
        _customTargeting
    }
    
}