//
//  AppNameDecoratorTests.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 22.10.19.
//

import XCTest
@testable import Yieldprobe

class AppNameDecoratorTests: XCTestCase {
    
    func testNoAppName () {
        // Arrange:
        let sut = AppNameDecorator()
        
        // Act:
        let result = sut.decorate(.example)
        
        // Assert:
        XCTAssertEqual(result, .example)
    }
    
    func testAppName () {
        // Arrange:
        let configuration = Configuration(appName: "My Fancy Shmancy App")
        var sut = AppNameDecorator()
        sut.configuration = configuration
        
        // Act:
        let result = sut.decorate(.example)
        
        // Assert:
        XCTAssertNotEqual(result, .example)
        XCTAssertEqual(result.queryValues(for: "pubappname"), ["My Fancy Shmancy App"])
    }
    
}
