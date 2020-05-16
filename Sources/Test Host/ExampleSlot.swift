//
//  ExampleSlot.swift
//  Test Host
//
//  Created by Sven Herzberg on 14.10.19.
//

import Foundation

enum ExampleSlot: RawRepresentable, CaseIterable, Equatable {
    
    case video
    
    case banner728x90
    
    case banner300x250
    
    case custom(Int)
    
    init(rawValue: Int) {
        switch rawValue {
        case ExampleSlot.video.rawValue:
            self = .video
        case ExampleSlot.banner300x250.rawValue:
            self = .banner300x250
        case ExampleSlot.banner728x90.rawValue:
            self = .banner728x90
        default:
            self = .custom(rawValue)
        }
    }
    
    var rawValue: Int {
        switch self {
        case .video:
            return 5220339
        case .banner728x90:
            return 5220336
        case .banner300x250:
            return 6846238
        case .custom(let id):
            return id
        }
    }
    
    static var allCases: [ExampleSlot] {
        [
            .banner300x250,
            .banner728x90,
            .video
        ]
    }
    
}
