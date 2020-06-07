//
//  CacheBuster.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 07.10.19.
//

import Foundation

struct CacheBuster: URLDecoratorProtocol {
    
    let clock = HighPrecisionClock()
    
    func decorate(_ subject: URL) -> URL {
        return URLComponents(url: subject, resolvingAgainstBaseURL: true)!
            .transformQueryItems { before in
                return before + [
                    URLQueryItem(name: "ts", value: "\(clock.now().ticks)")
                ]
            }.url!
    }
    
}

extension URLDecorators {
    
    static func cacheBuster () -> URLDecorator {
        CacheBuster().decorate(_:)
    }
    
}
