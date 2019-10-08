//
//  UIDevice+YLD.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 08.10.19.
//

import UIKit

#if !targetEnvironment(simulator)
func posixcall<T: SignedInteger> (_ block: @autoclosure () -> T) throws {
    if 0 > block() {
        throw POSIXError(POSIXErrorCode(rawValue: errno)!)
    }
}

func sysctl(named: StaticString) throws -> String {
    var size: size_t = 0
    try posixcall(sysctlbyname("hw.machine", nil, &size, nil, 0))
    
    var buffer = Data(count: size)
    try buffer.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) -> Void in
        try posixcall(sysctlbyname("hw.machine", buffer.baseAddress, &size, nil, 0))
    }
    
    return buffer.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) -> String in
        let cString = buffer.baseAddress?.bindMemory(to: CChar.self,
                                                     capacity: buffer.count)
        return String(cString: cString!, encoding: .utf8)!
    }
}
#endif

extension UIDevice: Device {
    
    var hardwareRevision: String {
        #if targetEnvironment(simulator)
        return "Simulator"
        #else
        return try! sysctl(named: "hw.machine")
        #endif
    }
    
}
