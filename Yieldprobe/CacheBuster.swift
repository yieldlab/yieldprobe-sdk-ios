//
//  CacheBuster.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 07.10.19.
//

import Foundation

struct CacheBuster {
    
    let clock = HighResolutionClock()
    
    func decorate(_ subject: URL) -> URL {
        var builder = URLComponents(url: subject, resolvingAgainstBaseURL: true)!
        var queryItems = builder.queryItems ?? []
        queryItems.append(URLQueryItem(name: "ts", value: "\(clock.now())"))
        builder.queryItems = queryItems
        return builder.url!
    }
    
}
