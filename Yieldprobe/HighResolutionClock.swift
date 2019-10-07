//
//  HighResolutionClock.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 07.10.19.
//

import Foundation

class HighResolutionClock {

    func now () -> UInt64 {
        return mach_absolute_time()
    }

}
