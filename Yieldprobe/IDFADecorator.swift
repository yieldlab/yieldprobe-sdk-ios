//
//  IDFADecorator.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 07.10.19.
//

import AdSupport
import Foundation

protocol IDFASource {
    
    var advertisingIdentifier: UUID { get }
    
    var isAdvertisingTrackingEnabled: Bool { get }
    
}

struct IDFADecorator: URLDecorator {
    
    var source: IDFASource
    
    init(source: IDFASource? = nil) {
        self.source = source ?? ASIdentifierManager.shared()
    }
    
    func decorate(_ subject: URL) -> URL {
        if !source.isAdvertisingTrackingEnabled {
            return subject
        }
        
        return URLComponents(url: subject, resolvingAgainstBaseURL: true)!
            .transformQueryItems { input in
                input + [
                    URLQueryItem(name: "yl_rtb_ifa",
                                 value: self.source.advertisingIdentifier.uuidString)
                ]
            }.url!
    }
    
}
