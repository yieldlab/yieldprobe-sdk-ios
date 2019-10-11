//
//  URLSession+YLD.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 01.10.19.
//

import Foundation

protocol DataTaskProtocol {
    
    func resume()
    
}

protocol URLSessionProtocol: HTTPClient {
    
    associatedtype DataTask: DataTaskProtocol
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> DataTask
    
}

extension URLSessionProtocol {
    
    func get(url: URL, completionHandler: @escaping HTTPClient.CompletionHandler) {
        dataTask(with: url, completionHandler: { data, response, error in
            completionHandler(Result(catching: { () -> URLReply in
                guard let data = data, let response = response else {
                    throw error!
                }
                
                return URLReply(data: data, response: response)
            }))
        }).resume()
    }
    
}

extension URLSession: URLSessionProtocol {
    
    typealias DataTask = URLSessionDataTask
    
}

extension URLSessionDataTask: DataTaskProtocol { }
