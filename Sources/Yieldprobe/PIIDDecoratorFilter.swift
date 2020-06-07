//
//  PIIDDecoratorFilter.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 10.10.19.
//

import Foundation

/// Disables the wrapped `URLDecorator` if ad personalization is not permitted. This will protect
/// personally identifyable information data from leaking out of the device even though it should not.
struct PIIDDecoratorFilter: URLDecoratorProtocol {
    
    var configuration: Configuration
    
    var wrapped: URLDecorator
    
    init (configuration: Configuration, wrapped: @escaping URLDecorator) {
        self.configuration = configuration
        self.wrapped = wrapped
    }
    
    func decorate(_ subject: URL) -> URL {
        guard configuration.personalizeAds else {
            return subject
        }
        
        return wrapped(subject)
    }
    
}

extension URLDecorators {
    
    static func privacyFilter (with configuration: Configuration,
                               decorator: @escaping URLDecorator) -> URLDecorator
    {
        PIIDDecoratorFilter(configuration: configuration, wrapped: decorator).decorate(_:)
    }
    
}
