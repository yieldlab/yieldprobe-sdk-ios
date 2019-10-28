//
//  HTTPClient.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 01.10.19.
//

import Foundation

struct URLReply {
    
    var data: Data
    
    var response: URLResponse
    
}

protocol HTTPClient {
    
    typealias CompletionHandler = (Result<URLReply,Error>) -> Void
    
    func get (url: URL, completionHandler: @escaping CompletionHandler) -> HTTPRequest
    
}

protocol HTTPRequest {}
