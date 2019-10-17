//
//  URL+YLD.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 04.10.19.
//

import Foundation

extension URL: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: StaticString) {
        self.init(string: String(describing: value))!
    }
    
}

extension URL {
    
    /// The URL representation of `https://example.com/`.
    static let example: URL = "https://example.com/"

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
