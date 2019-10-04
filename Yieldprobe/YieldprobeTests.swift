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
    
    // MARK: SDK Version
    
    func testSDKVersion () {
        // Arrange:
        let sut = Yieldprobe.shared
        
        // Act:
        let sdkVersion = sut.sdkVersion
        let infoVersion = Bundle(for: Yieldprobe.self).object(forInfoDictionaryKey: kCFBundleVersionKey as String)
        
        // Assert:
        XCTAssertEqual(sdkVersion, infoVersion as? String)
    }
    
}
