//
//  BundleIDDecorator.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 22.10.19.
//

import Foundation

struct BundleIDDecorator: URLDecoratorProtocol {
    
    var configuration = Configuration()
    
    func decorate(_ subject: URL) -> URL {
        guard let bundleID = configuration.bundleID else {
            return subject
        }
        
        return URLComponents(url: subject, resolvingAgainstBaseURL: true)!
            .transformQueryItems { input in
                input + [
                    URLQueryItem(name: "pubbundlename", value: bundleID)
                ]
            }
            .url!
    }
    
}
