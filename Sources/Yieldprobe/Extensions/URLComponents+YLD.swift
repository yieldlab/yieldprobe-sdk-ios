//
//  URLComponents+YLD.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 07.10.19.
//

import Foundation

extension URLComponents {
    
    func transformQueryItems (_ transform: ([URLQueryItem]) -> [URLQueryItem])
        -> URLComponents
    {
        var result = self
        result.queryItems = transform(result.queryItems ?? [])
        return result
    }
    
}
