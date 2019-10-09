//
//  ConnectivityDecoratorTests.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 08.10.19.
//

import XCTest
@testable import Yieldprobe

struct DummyConnectivitySource: ConnectivitySource {
    
    var connectionType: ConnectionType
    
}

class ConnectivityDecoratorTests: XCTestCase {
    
    func testCellular () {
        // Arrange:
        let source = DummyConnectivitySource(connectionType: .cellular)
        let input = URL(string: "https://example.com/")!
        let sut = ConnectivityDecorator(source: source)
        
        // Act:
        let output = sut.decorate(input)
        
        // Assert:
        XCTAssertNotEqual(output, input)
        XCTAssertEqual(output.queryValues(for: "yl_rtb_connectiontype"), ["3"])
    }
    
    func testUnknown () {
        // Arrange:
        let source = DummyConnectivitySource(connectionType: .unknown)
        let input = URL(string: "https://example.com/")!
        let sut = ConnectivityDecorator(source: source)
        
        // Act:
        let output = sut.decorate(input)
        
        // Assert:
        XCTAssertNotEqual(output, input)
        XCTAssertEqual(output.queryValues(for: "yl_rtb_connectiontype"), ["0"])
    }
    
    func testWifi () {
        // Arrange:
        let source = DummyConnectivitySource(connectionType: .wifi)
        let input = URL(string: "https://example.com/")!
        let sut = ConnectivityDecorator(source: source)
        
        // Act:
        let output = sut.decorate(input)
        
        // Assert:
        XCTAssertNotEqual(output, input)
        XCTAssertEqual(output.queryValues(for: "yl_rtb_connectiontype"), ["2"])
    }

}
