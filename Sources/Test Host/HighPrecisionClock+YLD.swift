//
//  HighPrecisionClock+YLD.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 16.10.19.
//

import Foundation

extension HighPrecisionClock.Time {
    
    fileprivate static let scale: mach_timebase_info_data_t = {
        assert((MemoryLayout<HighPrecisionClock.Time>.alignment, MemoryLayout<HighPrecisionClock.Time>.size, MemoryLayout<HighPrecisionClock.Time>.stride) == (MemoryLayout<UInt64>.alignment, MemoryLayout<UInt64>.size, MemoryLayout<UInt64>.stride),
               "unexpected overhead caused by opaque struct")
        
        var scale = mach_timebase_info_data_t()
        precondition(KERN_SUCCESS == mach_timebase_info(&scale))
        return scale
    }()
    
    private static let nanosecondsPerTick: Double = {
        TimeInterval(scale.numer) / TimeInterval(scale.denom)
    }()
    
    private static let secondsPerTick: Double = {
        nanosecondsPerTick / TimeInterval(NSEC_PER_SEC)
    }()
    
    var timeInterval: TimeInterval {
        TimeInterval(ticks) * type(of: self).secondsPerTick
    }
    
    @available(*, unavailable,
               message: "Only Subtraction with Overflow (&-) is available.")
    static func -(left: HighPrecisionClock.Time, right: HighPrecisionClock.Time)
        -> TimeInterval
    {
        fatalError("Only Subtraction with Overflow (&-) is available.")
    }
    
    static func &-(left: HighPrecisionClock.Time, right: HighPrecisionClock.Time)
        -> TimeInterval
    {
        HighPrecisionClock.Time(ticks: left.ticks &- right.ticks).timeInterval
    }

}
