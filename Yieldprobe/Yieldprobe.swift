//
//  Yieldprobe.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 01.10.19.
//

import Foundation

@available(swift, introduced: 5.0)
public class Yieldprobe: NSObject {
    
    // MARK: Class Properties
    
    public static let shared = Yieldprobe()
    
    static let defaultClient: HTTPClient = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration)
    }()
    
    // MARK: Properties
    
    let http: HTTPClient
    
    public var sdkVersion: String {
        Bundle(for: Self.self)
            .object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
    
    init (http: HTTPClient = Yieldprobe.defaultClient) {
        self.http = http
    }
    
    // MARK: Bid Requests
    
    public func probe (slot slotID: Int, completionHandler: @escaping () -> Void) {
        let baseURL = URL(string: "https://ad.yieldlab.net/yp/?content=json&pvid=true")!
        let url = baseURL.appendingPathComponent("\(slotID)")
        http.get(url: url) { result in
            fatalError()
        }
    }
    
}
