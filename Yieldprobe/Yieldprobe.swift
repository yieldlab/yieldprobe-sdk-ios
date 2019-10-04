//
//  Yieldprobe.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 01.10.19.
//

import Foundation

@available(swift, introduced: 5.0)
public class Yieldprobe: NSObject {
    
    public static let shared = Yieldprobe()
    
    var sdkVersion: String {
        Bundle(for: Self.self)
            .object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
    
}
