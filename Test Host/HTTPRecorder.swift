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
    
    func get(url: URL, completionHandler: @escaping CompletionHandler) {
        wrapped.get(url: url, completionHandler: completionHandler)
        
        onRequest(url)
    }
    
}
