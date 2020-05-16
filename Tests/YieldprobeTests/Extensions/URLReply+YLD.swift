//
//  URLReply+YLD.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 11.10.19.
//

import Foundation
@testable import Yieldprobe

struct UTF8Error: Error {}

extension URLReply {
    
    init (text: String, response: URLResponse) throws {
        guard let data = text.data(using: .utf8) else {
            throw UTF8Error()
        }
        
        self.init(data: data, response: response)
    }
    
    init<T: Encodable> (_ subject: T,
                        using encoder: JSONEncoder = JSONEncoder(),
                        response: URLResponse)
        throws
    {
        self.init(data: try encoder.encode(subject),
                  response: response)
    }
    
}
