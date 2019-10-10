//
//  PIIDDecoratorFilter.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 10.10.19.
//

import Foundation

/// Disables the wrapped `URLDecorator` if ad personalization is not permitted. This will protect
/// personally identifyable information data from leaking out of the device even though it should not.
struct PIIDDecoratorFilter: URLDecorator {
    
    var configuration: Configuration
    
    var wrapped: URLDecorator
    
    func decorate(_ subject: URL) -> URL {
        guard configuration.adPersonalization else {
            return subject
        }
        
        return wrapped.decorate(subject)
    }
    
}
