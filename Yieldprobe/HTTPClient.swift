//
//  HTTPClient.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 01.10.19.
//

import Foundation

protocol HTTPClient {
    
    typealias CompletionHandler = (Result<(data: Data, response: URLResponse),Error>) -> Void
    
    func get (url: URL, completionHandler: @escaping CompletionHandler)
    
}
