//
//  DefaultConnectivitySourceTests.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 09.10.19.
//

import Network
import XCTest
@testable import Yieldprobe

struct DummyPath: NWPathProtocol {
    
    var status: NWPath.Status
    
    var interfaceType: NWInterface.InterfaceType
    
    func usesInterfaceType(_ type: NWInterface.InterfaceType) -> Bool {
        interfaceType == type
    }
    
}

class SpyMonitor: NWPathMonitorProtocol {
    
    enum State {
        case initialized
        case started
    }
    
    var state = State.initialized
    
    private var _currentPath: DummyPath?
    
    var currentPath: DummyPath {
        _currentPath!
    }
    
    init (currentPath: DummyPath? = nil) {
        _currentPath = currentPath
    }
    
    func start(queue: DispatchQueue) {
        precondition(state == .initialized)
        state = .started
    }
    
}

class DefaultConnectivitySourceTests: XCTestCase {
    
    func testStartsMonitor () {
        // Arrange:
        let monitor = SpyMonitor()
        _ = DefaultConnectivitySource(monitor: monitor)
        
        // Act:
        let state = monitor.state
        
        // Assert:
        XCTAssertEqual(state, .started)
    }
    
    func testNoPath () {
        // Arrange:
        let path = DummyPath(status: .unsatisfied, interfaceType: .other)
        let monitor = SpyMonitor(currentPath: path)
        let sut = DefaultConnectivitySource(monitor: monitor)
        
        // Act:
        let connection = sut.connectionType
        
        // Assert:
        XCTAssertEqual(connection, .unknown)
    }
    
    func testPaths () {
        let tests: [NWInterface.InterfaceType: ConnectionType] = [
            .wiredEthernet: .unknown,
            .wifi: .wifi,
            .cellular: .cellular,
            .other: .unknown,
            .loopback: .unknown,
        ]
        
        for (interfaceType, connectionType) in tests {
            // Arrange:
            let path = DummyPath(status: .satisfied, interfaceType: interfaceType)
            let monitor = SpyMonitor(currentPath: path)
            let sut = DefaultConnectivitySource(monitor: monitor)
            
            // Act:
            let connection = sut.connectionType
            
            // Assert:
            XCTAssertEqual(connection, connectionType, "\(interfaceType)")
        }
    }
    
}
