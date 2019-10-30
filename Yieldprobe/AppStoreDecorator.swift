//
//  AppStoreDecorator.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 30.10.19.
//

import Foundation

struct AppStoreDecorator: URLDecorator {
    
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
