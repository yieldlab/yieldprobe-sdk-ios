//
//  NWPathMonitor+YLD.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 09.10.19.
//

import Network

extension NWPath: NWPathProtocol { }

extension NWPathMonitor: NWPathMonitorProtocol {
    
    typealias Path = NWPath
    
}
