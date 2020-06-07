//
//  PIIDDecoratorFilter.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 10.10.19.
//

extension URLDecorators {
    
    static func privacyFilter (with configuration: Configuration,
                               decorator: @escaping URLDecorator) -> URLDecorator
    {
        personalize(if: configuration.personalizeAds, decorator)
    }
    
    static func personalize (if condition: Bool, _ decorator: @escaping URLDecorator)
        -> URLDecorator
    {
        condition
            ? decorator
            : { $0 }
    }
    
}
