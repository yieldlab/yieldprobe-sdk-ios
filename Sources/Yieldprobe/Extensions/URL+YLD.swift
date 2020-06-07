//
//  URL+YLD.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 07.10.19.
//

import Foundation

extension URL {
    
    func decorate (_ decorators: URLDecoratorProtocol...) -> URL {
        decorators.reduce(self) { url, decorator in
            decorator.decorate(url)
        }
    }
    
}
