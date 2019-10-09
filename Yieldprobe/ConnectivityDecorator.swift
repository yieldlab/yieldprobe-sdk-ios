//
//  ConnectivityDecorator.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 08.10.19.
//

import Foundation

enum ConnectionType {
    case unknown
    case wifi
    case cellular
    
    var queryItem: URLQueryItem {
        let value: String
        switch self {
        case .unknown:
            value = "0"
        case .wifi:
            value = "2"
        case .cellular:
            value = "3"
        }
        return URLQueryItem(name: "yl_rtb_connectiontype", value: value)
    }
}

protocol ConnectivitySource {
    
    var connectionType: ConnectionType { get }
    
}

struct ConnectivityDecorator: URLDecorator {
    
    var connectivitySource: ConnectivitySource
    
    init (source: ConnectivitySource? = nil) {
        connectivitySource = source ?? DefaultConnectivitySource()
    }
    
    func decorate(_ subject: URL) -> URL {
        URLComponents(url: subject, resolvingAgainstBaseURL: true)!
            .transformQueryItems { input in
                input + [
                    connectivitySource.connectionType.queryItem
                ]
            }
            .url!
    }
    
}
