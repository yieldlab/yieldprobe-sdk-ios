//
//  HighPrecisionClock.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 07.10.19.
//

import Foundation

class HighPrecisionClock {
    
    struct Time {
        
        let ticks: UInt64
        
    }
    
    func now () -> Time {
        Time(ticks: mach_absolute_time())
    }
    
}
