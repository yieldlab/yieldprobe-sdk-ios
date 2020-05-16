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
    
    func get (url: URL, queue: DispatchQueue, completionHandler: @escaping CompletionHandler) -> HTTPRequest
    
}

extension HTTPClient {
    
    static private var defaultQueue: DispatchQueue {
        .global()
    }
    
    func get (url: URL, completionHandler: @escaping CompletionHandler) -> HTTPRequest {
        get(url: url, queue: Self.defaultQueue, completionHandler: completionHandler)
    }
    
}

fileprivate let timeoutQueue = DispatchQueue(label: "com.yieldlab.yielprobe.http.timeout")

extension HTTPClient {
    
    func get (url: URL,
              timeout: TimeInterval,
              completionHandler: @escaping CompletionHandler)
    {
        get(url: url, timeout: timeout, queue: Self.defaultQueue, completionHandler: completionHandler)
    }
    
    func get (url: URL,
              timeout: TimeInterval,
              queue: DispatchQueue,
              completionHandler: @escaping CompletionHandler)
    {
        var completion: CompletionHandler? = completionHandler
        var request: HTTPRequest?
        
        var timer: DispatchSourceTimer?
        if timeout > 0 {
            let source = DispatchSource.makeTimerSource(queue: timeoutQueue)
            source.setEventHandler {
                #if DEBUG
                dispatchPrecondition(condition: .onQueue(timeoutQueue))
                #endif
                
                if let completionHandler = completion {
                    completion = nil
                    queue.async {
                        completionHandler(.failure(URLError(.timedOut)))
                    }
                }
                
                request?.cancel()
            }
            source.schedule(deadline: .now() + timeout)
            source.activate()
            timer = source
        }
        
        request = get(url: url, queue: timeoutQueue) { result in
            #if DEBUG
            dispatchPrecondition(condition: .onQueue(timeoutQueue))
            #endif
            
            if let completionHandler = completion {
                completion = nil
                queue.async {
                    completionHandler(result)
                }
            }
            
            timer?.cancel()
        }
    }
    
}

protocol HTTPRequest {
    
    func cancel()
    
}
