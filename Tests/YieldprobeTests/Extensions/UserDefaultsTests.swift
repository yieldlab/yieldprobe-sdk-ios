//
//  UserDefaultsTests.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 07.10.19.
//

import XCTest
@testable import Yieldprobe

class MockUserDefaults: UserDefaultsProtocol {
    
    func string(forKey key: String) -> String? {
        key
    }
    
}

class UserDefaultsTests: XCTestCase {
    
    func testUserDefaultsKey () {
        // Arrange:
        let userDefaults = MockUserDefaults()
        
        // Act:
        let consent = userDefaults.consent
        
        // Assert:
        XCTAssertEqual(consent, "IABConsent_ConsentString")
    }
    
}
