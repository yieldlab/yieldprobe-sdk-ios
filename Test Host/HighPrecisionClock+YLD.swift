//
//  HighPrecisionClock+YLD.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 16.10.19.
//

import Foundation
@testable import Yieldprobe

extension HighPrecisionClock {
    
    func timeInterval(from start: Time, to end: Time) -> TimeInterval {
        TimeInterval(end.ticks - start.ticks) * TimeInterval(type(of: self).scale.numer) / TimeInterval(type(of: self).scale.denom) / 1_000_000_000
    }

    private static let scale: mach_timebase_info_data_t = {
        var scale = mach_timebase_info_data_t()
        precondition(KERN_SUCCESS == mach_timebase_info(&scale))
        return scale
    }()
    
}
