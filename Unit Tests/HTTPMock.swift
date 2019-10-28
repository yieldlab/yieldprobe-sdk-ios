//
//  HTTPMock.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 01.10.19.
//

import XCTest
@testable import Yieldprobe

class HTTPMock: HTTPClient {
    
    enum Call: HTTPRequest {
        
        case get(URL, DispatchQueue, CompletionHandler)
        
        var url: URL {
            switch self {
            case .get(let url, _, _):
                return url
            }
        }
        
        func cancel () {
            fatalError()
        }
        
        func process(_ processor: (URL) throws -> URLReply) {
            switch self {
            case .get(let url, let queue, let completionHandler):
                let result = Result {
                    try processor(url)
                }
                
                queue.async {
                    completionHandler(result)
                }
            }
        }
    }
    
    var calls = [Call]()
    
    func get(url: URL, queue: DispatchQueue, completionHandler: @escaping CompletionHandler) -> HTTPRequest {
        let request = Call.get(url, queue, completionHandler)
        calls.append(request)
        return request
    }
    
}
