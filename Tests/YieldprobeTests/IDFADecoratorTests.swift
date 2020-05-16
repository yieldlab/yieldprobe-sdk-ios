//
//  IDFADecoratorTests.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 07.10.19.
//

import XCTest
@testable import Yieldprobe

struct DummyIDFASource: IDFASource {
    
    var idfa: UUID?
    
    var advertisingIdentifier: UUID {
        idfa!
    }
    
    var isAdvertisingTrackingEnabled: Bool {
        idfa != nil
    }
    
    init(idfa: UUID?) {
        self.idfa = idfa
    }
    
}

class IDFADecoratorTests: XCTestCase {
    
    func testTrackingDisabled () {
        // Arrange:
        let sut = IDFADecorator(source: DummyIDFASource(idfa: nil))
        let input = URL(string: "https://example.com/")!
        
        // Act:
        let output = sut.decorate(input)
        
        // Assert:
        XCTAssertEqual(input, output)
    }
    
    func testTrackingEnabled () {
        // Arrange:
        let source = DummyIDFASource(idfa: UUID())
        let sut = IDFADecorator(source: source)
        let input = URL(string: "https://example.com/")!

        // Act:
        let output = sut.decorate(input)
        
        // Assert:
        XCTAssertNotEqual(output, input)
        XCTAssertEqual(output.queryValues(for: "yl_rtb_ifa"),
                       [source.idfa!.uuidString])
    }
    
}
