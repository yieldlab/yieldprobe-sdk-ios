//
//  HighPrecisionClock.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 07.10.19.
//

import Foundation

class HighPrecisionClock {
    
    typealias Time = UInt64
    private let scale: mach_timebase_info_data_t
    
    init() {
        var info = mach_timebase_info_data_t()
        precondition(KERN_SUCCESS == mach_timebase_info(&info))
        scale = info
    }
    
    func now () -> Time {
        return mach_absolute_time()
    }
    
    func timeInterval(from start: Time, to end: Time) -> TimeInterval {
        return TimeInterval(end - start) * TimeInterval(scale.numer) / TimeInterval(scale.denom) / 1_000_000_000
    }
    
}
