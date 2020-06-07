//
//  PIIDDecoratorFilter.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 10.10.19.
//

import Foundation

/// Disables the wrapped `URLDecorator` if ad personalization is not permitted. This will protect
/// personally identifyable information data from leaking out of the device even though it should not.
struct PIIDDecoratorFilter<Wrapped: URLDecoratorProtocol>: URLDecoratorProtocol {
    
    var configuration: Configuration
    
    var wrapped: Wrapped
    
    init (configuration: Configuration, wrapped: Wrapped) {
        self.configuration = configuration
        self.wrapped = wrapped
    }
    
    func decorate(_ subject: URL) -> URL {
        guard configuration.personalizeAds else {
            return subject
        }
        
        return wrapped.decorate(subject)
    }
    
}

extension URLDecorators {
    
    static func privacyFilter<Wrapped: URLDecoratorProtocol> (
        with configuration: Configuration,
        decorator: Wrapped
    ) -> URLDecorator {
        PIIDDecoratorFilter(configuration: configuration, wrapped: decorator).decorate(_:)
    }
    
}
