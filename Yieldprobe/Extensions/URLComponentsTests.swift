//
//  URLComponentsTests.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 07.10.19.
//

import XCTest
@testable import Yieldprobe

class URLComponentsTests: XCTestCase {
    
    func testEmptyQuery () {
        // Arrange:
        let url = URL.example
        let sut = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        // Act:
        let modified = sut.transformQueryItems {
            return $0 + [
                URLQueryItem(name: "foo", value: "bar")
            ]
        }
        
        // Assert:
        XCTAssertEqual(modified.url?.query, "foo=bar")
    }
    
    func testDisjunctQuery () {
        // Arrange:
        let url: URL = "https://example.com/?baz"
        let sut = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        // Act:
        let modified = sut.transformQueryItems { input in
            return input + [
                URLQueryItem(name: "foo", value: "bar")
            ]
        }
        
        // Assert:
        XCTAssertEqual(modified.url?.query, "baz&foo=bar")
    }
    
    func testConjunctQuery () {
        // Arrange:
        let url: URL = "https://example.com/?foo"
        let sut = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        // Act:
        let modified = sut.transformQueryItems { input in
            return input + [
                URLQueryItem(name: "foo", value: "bar")
            ]
        }
        
        // Assert:
        XCTAssertEqual(modified.url?.query, "foo&foo=bar")
    }
    
}
