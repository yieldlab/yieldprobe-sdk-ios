//
//  URLDecorator.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 07.10.19.
//

import Foundation

protocol URLDecorator {
    
    func decorate (_ subject: URL) -> URL
    
}
