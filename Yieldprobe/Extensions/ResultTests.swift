//
//  ResultTests.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 11.10.19.
//

import XCTest
@testable import Yieldprobe

class ResultTests: XCTestCase {
    
    func testTryMapSuccess () {
        // Arrange:
        let sut = Result<[String],Error>.success(["Hello", "World!"])
        
        // Act:
        let result = sut.tryMap {
            $0.joined(separator: " ")
        }
        
        // Assert:
        XCTAssertEqual(try result.get(), "Hello World!")
    }
    
    func testTryMapSuccessThrows () {
        // Arrange:
        let sut = Result<[String],Error>.success(["Hello", "World!"])
        
        // Act:
        let result = sut.tryMap { _ in
            throw Yieldprobe.Error.unsupportedFormat
        }
        
        // Assert:
        XCTAssertThrowsError(try result.get()) { error in
            XCTAssertEqual(error as? Yieldprobe.Error, .unsupportedFormat)
        }
    }
    
    func testTryMapFailure () {
        // Arrange:
        let sut = Result<[String],Error>.failure(Yieldprobe.Error.noFill)
        
        // Act:
        let result = sut.tryMap { _ in
            throw Yieldprobe.Error.unsupportedFormat
        }
        
        // Assert:
        XCTAssertThrowsError(try result.get()) { error in
            XCTAssertEqual(error as? Yieldprobe.Error, .noFill)
        }
    }
    
    func testTryMapFailureThrows () {
        // Arrange:
        let sut = Result<[String],Error>.failure(Yieldprobe.Error.noFill)
        
        // Act:
        let result = sut.tryMap {
            $0.joined(separator: " ")
        }
        
        // Assert:
        XCTAssertThrowsError(try result.get()) { error in
            XCTAssertEqual(error as? Yieldprobe.Error, .noFill)
        }
    }
    
}
