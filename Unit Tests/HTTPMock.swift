//
//  HTTPMock.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 01.10.19.
//

import XCTest
@testable import Yieldprobe

class HTTPMock: HTTPClient {
    
    enum Call {
        case get(URL, CompletionHandler)
        
        func process(_ processor: (URL) throws -> URLReply) {
            switch self {
            case .get(let url, let completionHandler):
                completionHandler(Result(catching: { try processor(url) }))
            }
        }
    }
    
    var calls = [Call]()
    
    func get(url: URL, completionHandler: @escaping CompletionHandler) {
        calls.append(.get(url, completionHandler))
    }
    
}
