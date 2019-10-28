//
//  Dispatch+YLD.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 29.10.19.
//

import Foundation

func +(left: DispatchTime, right: TimeInterval) -> DispatchTime {
    var seconds: TimeInterval = 0
    let fraction: TimeInterval = modf(right, &seconds)
    return left +
        DispatchTimeInterval.seconds(Int(seconds)) +
        DispatchTimeInterval.nanoseconds(Int(fraction * TimeInterval(NSEC_PER_SEC)))
}
