//
//  ExtraTargetingDecoratorTests.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 16.10.19.
//

import XCTest
@testable import Yieldprobe

class ExtraTargetingDecoratorTests: XCTestCase {
    
    func testNoExtraTargeting () {
        // Arrange:
        let sut = ExtraTargetingDecorator()
        
        // Act:
        let result = sut.decorate(.example)
        
        // Assert:
        XCTAssertEqual(result, .example)
        XCTAssertEqual(result.queryValues(for: "t"), [])
    }
    
    func testExtraTargeting () {
        // Arrange:
        let configuration = Configuration(extraTargeting: ["key1": "value",
                                                           "key2": "valueA,valueB"])
        var sut = ExtraTargetingDecorator()
        sut.configuration = configuration
        
        // Act:
        let result = sut.decorate(.example)
        
        // Assert:
        XCTAssertNotEqual(result, .example)
        XCTAssertEqual(result.queryValues(for: "t"),
                       ["key1=value&key2=valueA,valueB"])
    }
    
}
