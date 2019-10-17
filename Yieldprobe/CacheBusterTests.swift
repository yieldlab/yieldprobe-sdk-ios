//
//  CacheBusterTests.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 15.10.19.
//

import XCTest
@testable import Yieldprobe

class CacheBusterTests: XCTestCase {
    
    func testParameterFormat () {
        // Arrange:
        let formatter = NumberFormatter()
        let sut = CacheBuster()
        let url = URL.example
        
        // Act:
        let result = sut.decorate(url)
        
        // Assert:
        XCTAssertNotEqual(result, url)
        let stringValue = result.queryValues(for: "ts").compactMap().first
        XCTAssertNotNil(stringValue.flatMap { formatter.number(from: $0)?.uint64Value },
                        "Unexpected query value: \(stringValue as Any)")
    }
    
}
