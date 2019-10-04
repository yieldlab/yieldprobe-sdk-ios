//
//  URLSession+YLD.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 01.10.19.
//

import Foundation

extension URLSession: HTTPClient {
    
    func get(url: URL, completionHandler: @escaping CompletionHandler) {
        dataTask(with: url, completionHandler: { data, response, error in
            completionHandler(Result(catching: { () -> (data: Data, response: URLResponse) in
                guard let data = data, let response = response else {
                    throw error!
                }
                
                return (data: data, response: response)
            }))
        }).resume()
    }
    
}
