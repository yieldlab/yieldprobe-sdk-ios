//
//  AppStoreDecoratorTests.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 30.10.19.
//

import XCTest
@testable import Yieldprobe

class AppStoreDecoratorTests: XCTestCase {
    
    func testWithoutURL () {
        // Arrange:
        let input = URL.example
        let sut = AppStoreDecorator()
        
        // Act:
        let output = sut.decorate(input)
        
        // Assert:
        XCTAssertEqual(input, output)
        XCTAssertEqual(output.queryValues(for: "pubstoreurl"), [])
    }
    
    func testWithURL () {
        // Arrange:
        let storeURL = URL.example
        let configuration = Configuration(storeURL: storeURL)
        let input = URL.example
        var sut = AppStoreDecorator()
        sut.configuration = configuration
        
        // Act:
        let output = sut.decorate(input)
        
        // Assert:
        XCTAssertNotEqual(input, output)
        XCTAssertEqual(output.queryValues(for: "pubstoreurl"), [storeURL.absoluteString])
    }
    
}
