//
//  BidTests.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 11.10.19.
//

import XCTest
@testable import Yieldprobe

class BidTests: XCTestCase {

    func testCustomTargeting () throws {
        // Arrange:
        let expectedTargeting = ["key" : "value"]
        let sut = Bid(slotID: 1234, customTargeting: expectedTargeting)
        
        // Act:
        let id = sut.slotID
        let customTargeting = try sut.customTargeting()
        
        // Assert:
        XCTAssertEqual(id, 1234)
        XCTAssertEqual(customTargeting as? [String: String], expectedTargeting)
    }
    
}
