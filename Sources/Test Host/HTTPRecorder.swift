//
//  HTTPRecorder.swift
//  Test Host
//
//  Created by Sven Herzberg on 23.10.19.
//

import Foundation
@testable import Yieldprobe

class HTTPRecorder<T: HTTPClient> {
    
    var onRequest: (URL) -> Void = { _ in }
    
    private let wrapped: T
    
    init(_ wrapped: T) {
        self.wrapped = wrapped
    }
    
}

extension HTTPRecorder: HTTPClient {
    
    func get(url: URL, queue: DispatchQueue, completionHandler: @escaping CompletionHandler) -> HTTPRequest {
        let request = wrapped.get(url: url, queue: queue, completionHandler: completionHandler)
        onRequest(url)
        return request
    }
    
}
