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
    
    // MARK: Bid Requests
    
    func testProbeRequest () {
        // Arrange:
        let http = HTTPMock()
        let sut = Yieldprobe(http: http)
        let slotID = [1234, 5678].randomElement()!
        
        // Act:
        sut.probe(slot: slotID) {
            XCTFail("Should not be called.")
        }
        
        // Assert:
        XCTAssertEqual(http.calls.count, 1)
        guard let call = http.calls.first else {
            return
        }
        guard case .get(let url, _) = call else {
            return XCTFail("Unexpected call: \(call)")
        }
        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.host, "ad.yieldlab.net")
        XCTAssertEqual(url.pathComponents, ["/", "yp", "\(slotID)"])
        XCTAssertEqual(url.queryValues(for: "content"), ["json"])
        XCTAssertEqual(url.queryValues(for: "pvid"), ["true"])
    }
    
}
