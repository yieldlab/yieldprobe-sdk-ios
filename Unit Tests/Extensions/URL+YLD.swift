//
//  URL+YLD.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 04.10.19.
//

import Foundation

extension URL {
    
    var queryItems: [URLQueryItem]? {
        URLComponents(url: self, resolvingAgainstBaseURL: false)?.queryItems
    }
    
    func queryValues (for name: String) -> [String?] {
        (queryItems ?? []).filter {
            $0.name == name
        }.map {
            $0.value
        }
    }
    
}
