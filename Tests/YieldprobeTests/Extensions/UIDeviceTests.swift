//
//  UIDeviceTests.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 08.10.19.
//

import XCTest
@testable import Yieldprobe

#if !targetEnvironment(simulator)
class UIDeviceTests: XCTestCase {
    
    func testPosixCallThrows () {
        // Arrange:
        var caught: Error?
        var char: Int8 = 101 // 'A'
        
        // Act:
        do {
            try posixcall(write(STDIN_FILENO, &char, 1))
            XCTFail("Should not be called.")
        } catch {
            caught = error
        }
        
        // Assert:
        XCTAssertEqual(caught as? POSIXError, POSIXError(.EBADF))
    }
    
}
#endif
