//
//  ExtraTargetingDecorator.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 16.10.19.
//

import Foundation

struct ExtraTargetingDecorator: URLDecoratorProtocol {
    
    var configuration = Configuration()
    
    func decorate(_ subject: URL) -> URL {
        guard !configuration.extraTargeting.isEmpty else {
            return subject
        }
        
        return URLComponents(url: subject, resolvingAgainstBaseURL: true)!
            .transformQueryItems { input in
                input + [
                    URLQueryItem(name: "t", value: extraTargeting())
                ]
            }
            .url!
    }
    
    func extraTargeting () -> String {
        URLComponents(string: "")!
            .transformQueryItems { input in
                input + configuration
                    .extraTargeting
                    .sorted(by: { $0.key < $1.key })
                    .map {
                        URLQueryItem(name: $0, value: $1)
                    }
            }
            .query!
    }
    
}
