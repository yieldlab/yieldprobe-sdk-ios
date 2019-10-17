//
//  HighPrecisionClock.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 07.10.19.
//

import Foundation

extension UInt64 {
    
    init(ticks: UInt64) {
        self.init(ticks)
    }
    
    var ticks: UInt64 {
        self
    }
    
}

class HighPrecisionClock {
    
    typealias Time = UInt64
    private let scale: mach_timebase_info_data_t
    
    init() {
        var info = mach_timebase_info_data_t()
        precondition(KERN_SUCCESS == mach_timebase_info(&info))
        scale = info
    }
    
    func now () -> Time {
        Time(ticks: mach_absolute_time())
    }
    
    func timeInterval(from start: Time, to end: Time) -> TimeInterval {
        TimeInterval(end.ticks - start.ticks) * TimeInterval(scale.numer) / TimeInterval(scale.denom) / 1_000_000_000
    }
    
}
