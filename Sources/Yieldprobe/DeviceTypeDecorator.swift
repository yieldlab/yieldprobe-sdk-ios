//
//  DeviceTypeDecorator.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 08.10.19.
//

import Foundation
import UIKit

protocol Device {
    
    var hardwareRevision: String { get }
    
}

@available(iOS, introduced: 8.0) // iOS 8 is the lowest deployment target in Xcode 11
@available(iOSApplicationExtension, unavailable)
@available(macCatalyst, unavailable)
@available(macCatalystApplicationExtension, unavailable)
@available(OSX, unavailable)
@available(OSXApplicationExtension, unavailable)
@available(tvOS, unavailable)
@available(tvOSApplicationExtension, unavailable)
@available(watchOS, unavailable)
@available(watchOSApplicationExtension, unavailable)
struct DeviceTypeDecorator: URLDecoratorProtocol {
    
    var device: Device
    
    init (device: Device? = nil) {
        self.device = device ?? UIDevice.current
    }
    
    func decorate(_ subject: URL) -> URL {
        #if os(iOS)
        return URLComponents(url: subject, resolvingAgainstBaseURL: true)!
            .transformQueryItems { input in
                input + [
                    URLQueryItem(name: "yl_rtb_devicetype",
                                 value: self.device.hardwareRevision.hasPrefix("iPad") ? "5" : "4")
                ]
            }.url!
        #else
        #error("Unsupported platform.")
        #endif
    }
    
}
