//
//  AppNameDecorator.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 22.10.19.
//

import Foundation

struct AppNameDecorator: URLDecoratorProtocol {
    
    var configuration = Configuration()
    
    func decorate(_ subject: URL) -> URL {
        guard let appName = configuration.appName else {
            return subject
        }
        
        return URLComponents(url: subject, resolvingAgainstBaseURL: true)!
            .transformQueryItems { input in
                input + [
                    URLQueryItem(name: "pubappname", value: appName)
                ]
            }
            .url!
    }
    
}

extension URLDecorators {

    static func appName (from configuration: Configuration) -> URLDecorator {
        AppNameDecorator(configuration: configuration).decorate(_:)
    }

}
