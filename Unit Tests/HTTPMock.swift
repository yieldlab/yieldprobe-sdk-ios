//
//  HTTPMock.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 01.10.19.
//

import XCTest
@testable import Yieldprobe

class HTTPMock: HTTPClient {
    
    class Call: HTTPRequest {
        
        enum Method {
            case get
        }
        
        enum State {
            case pending(DispatchQueue, CompletionHandler)
            case completed
            case cancelled
        }
        
        static func get(url: URL, queue: DispatchQueue, completionHandler: @escaping CompletionHandler)
            -> Call
        {
            Call(method: .get,
                 url: url,
                 state: .pending(queue, completionHandler))
        }
        
        var method: Method
        
        var url: URL
        
        var state: State
        
        init(method: Method, url: URL, state: State) {
            self.method = method
            self.state = state
            self.url = url
        }
        
        func cancel () {
            guard case .pending = state else {
                return
            }
            state = .cancelled
        }
        
        func process(_ processor: (URL) throws -> URLReply) {
            guard case .pending(let queue, let completionHandler) = state else {
                return
            }
            state = .completed
            
            switch method {
            case .get:
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
        let request = Call.get(url: url, queue: queue, completionHandler: completionHandler)
        calls.append(request)
        return request
    }
    
}
