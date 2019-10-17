//
//  HighPrecisionClock.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 07.10.19.
//

import Foundation

class HighPrecisionClock {
    
    private let scale: mach_timebase_info_data_t
    
    init() {
        var info = mach_timebase_info_data_t()
        precondition(KERN_SUCCESS == mach_timebase_info(&info))
        scale = info
    }
    
    func now () -> UInt64 {
        return mach_absolute_time()
    }
    
    func timeInterval(from start: UInt64, to end: UInt64) -> TimeInterval {
        return TimeInterval(end - start) * TimeInterval(scale.numer) / TimeInterval(scale.denom) / 1_000_000_000
    }
    
}
