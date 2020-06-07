//
//  PIIDDecoratorFilter.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 10.10.19.
//

extension URLDecorators {
    
    static func personalize (if condition: Bool, _ decorator: @escaping URLDecorator)
        -> URLDecorator
    {
        condition
            ? decorator
            : { $0 }
    }
    
}
