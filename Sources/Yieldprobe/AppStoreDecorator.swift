//
//  AppStoreDecorator.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 30.10.19.
//

import Foundation

struct AppStoreDecorator: URLDecoratorProtocol {
    
    var configuration = Configuration()
    
    func decorate(_ subject: URL) -> URL {
        guard let storeURL = configuration.storeURL else {
            return subject
        }
        
        return URLComponents(url: subject, resolvingAgainstBaseURL: true)!
            .transformQueryItems { input in
                input + [
                    URLQueryItem(name: "pubstoreurl", value: storeURL.absoluteString)
                ]
            }
            .url!
    }
    
}

extension URLDecorators {
    
    static func appStoreURL (from configuration: Configuration) -> URLDecorator {
        AppStoreDecorator(configuration: configuration).decorate(_:)
    }
    
}
