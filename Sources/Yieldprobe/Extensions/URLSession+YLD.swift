//
//  URLSession+YLD.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 01.10.19.
//

import Foundation

protocol DataTaskProtocol: HTTPRequest {
    
    func resume()
    
}

protocol URLSessionProtocol: HTTPClient {
    
    associatedtype DataTask: DataTaskProtocol
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> DataTask
    
}

extension URLSessionProtocol {
    
    func get(url: URL, queue: DispatchQueue, completionHandler: @escaping HTTPClient.CompletionHandler) -> HTTPRequest {
        let task = dataTask(with: url, completionHandler: { data, response, error in
            let result = Result { () -> URLReply in
                guard let data = data, let response = response else {
                    throw error!
                }
                
                return URLReply(data: data, response: response)
            }
            
            queue.async {
                completionHandler(result)
            }
        })
        task.resume()
        return task
    }
    
}

extension URLSession: URLSessionProtocol {
    
    typealias DataTask = URLSessionDataTask
    
}

extension URLSessionDataTask: DataTaskProtocol { }
