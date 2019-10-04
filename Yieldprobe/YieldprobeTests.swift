//
//  YieldprobeTests.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 01.10.19.
//

import Foundation
import XCTest
@testable import Yieldprobe

class YieldprobeTests: XCTestCase {
    
    // MARK: SDK Singleton
    
    func testSingleton () {
        // Arrange:
        let sut1 = Yieldprobe.shared
        let sut2 = Yieldprobe.shared
        
        // Act:
        
        // Assert:
        XCTAssertTrue(sut1 === sut2)
    }
    
}
