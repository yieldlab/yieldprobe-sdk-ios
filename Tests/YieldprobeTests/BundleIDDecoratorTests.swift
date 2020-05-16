//
//  BundleIDDecoratorTests.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 22.10.19.
//

import XCTest
@testable import Yieldprobe

class BundleIDDecoratorTests: XCTestCase {
    
    func testNoBundleID () {
        // Arrange:
        let configuration = Configuration(bundleID: nil)
        var sut = BundleIDDecorator()
        sut.configuration = configuration
        
        // Act:
        let result = sut.decorate(.example)
        
        // Assert:
        XCTAssertEqual(result, .example)
    }
    
    func testBundleID () {
        // Arrange:
        let configuration = Configuration(bundleID: "com.example.some-test")
        var sut = BundleIDDecorator()
        sut.configuration = configuration
        
        // Act:
        let result = sut.decorate(.example)
        
        // Assert:
        XCTAssertNotEqual(result, .example)
        XCTAssertEqual(result.queryValues(for: "pubbundlename"), ["com.example.some-test"])
    }
    
}
