//
//  DefaultConnectivitySource.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 09.10.19.
//

import Network

protocol NWPathProtocol {
    
    var status: NWPath.Status { get }
    
    func usesInterfaceType(_ type: NWInterface.InterfaceType) -> Bool
    
}

protocol NWPathMonitorProtocol {
    
    associatedtype Path: NWPathProtocol
    
    var currentPath: Path { get }
    
    func start(queue: DispatchQueue)
    
}

struct DefaultConnectivitySource<PathMonitor>: ConnectivitySource
    where PathMonitor: NWPathMonitorProtocol
{
    
    var connectionType: ConnectionType {
        let path = monitor.currentPath
        
        if path.status == .satisfied {
            let types: [(NWInterface.InterfaceType, ConnectionType)] = [
                // (.wiredEthernet, .unknown),
                (.wifi, .wifi),
                (.cellular, .cellular),
                // (.loopback, .unknown),
                // (.other, .unknown),
            ]
            for (type, result) in types {
                if path.usesInterfaceType(type) {
                    return result
                }
            }
        }
        
        return .unknown
    }
    
    let monitor: PathMonitor
    
    init (monitor: PathMonitor) {
        self.monitor = monitor
        self.monitor.start(queue: .global())
    }
    
}

extension DefaultConnectivitySource where PathMonitor == NWPathMonitor {
    
    init () {
        self.init(monitor: NWPathMonitor())
    }
        
}
