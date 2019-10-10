//
//  YieldprobeTests.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 01.10.19.
//

import CoreLocation
import Foundation
import XCTest
@testable import Yieldprobe

extension Set {
    
    func randomSubset () -> Set<Element> {
        var generator: RandomNumberGenerator = SystemRandomNumberGenerator()
        return randomSubset(using: &generator)
    }
    
    func randomSubset (using generator: inout RandomNumberGenerator) -> Set<Element> {
        filter { _ in
            // This is a bit wasteful but only used for testing anyway.
            generator.next().isMultiple(of: 2)
        }
    }
    
}

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
    
    // MARK: Bid Request URL
    
    func testEmptyProbeRequest () {
        // Arrange:
        var caught: Error?
        var expectation: Optional = self.expectation(description: "async call")
        let sut = Yieldprobe()
        
        // Act:
        sut.probe(slots: []) { result in
            do {
                _ = try result.get()
                XCTFail("Should not be called.")
            } catch {
                XCTAssertNil(caught)
                caught = error
            }
            
            expectation?.fulfill()
            expectation = nil
        }
        
        wait(for: [expectation!], timeout: 0.1)
        expectation = nil
        
        // Assert:
        XCTAssertEqual(caught as? Yieldprobe.Error, .noSlot)
    }
    
    func testProbeRequest () {
        // Arrange:
        let http = HTTPMock()
        let sut = Yieldprobe(http: http)
        let slotIDs: Set = [
            2110,
            2212,
            2312,
            2345,
            2550,
            2001,
            2010,
            2061,
            3001,
        ]
        let selectedSlots = slotIDs.randomSubset().union([2052])
        let formatter = NumberFormatter()
        
        // Act:
        sut.probe(slots: selectedSlots) { _ in
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
        XCTAssertEqual(url.pathComponents.count, 3)
        XCTAssertEqual(url.pathComponents.prefix(upTo: 2), ["/", "yp"])
        XCTAssertEqual(Set(url.lastPathComponent
                           .split(separator: ",")
                           .map(String.init(_:))
                           .compactMap({ formatter.number(from: $0)?.intValue })),
                       selectedSlots)
        XCTAssertEqual(url.queryValues(for: "content"), ["json"])
        XCTAssertEqual(url.queryValues(for: "pvid"), ["true"])
    }
    
    // MARK: Bid Request Parameters
    
    func testCacheBusting () {
        // Arrange:
        let http = HTTPMock()
        let sut = Yieldprobe(http: http)
        
        // Act:
        for _ in 1...3 {
            sut.probe(slot: 1234) {
                XCTFail("Should not be called")
            }
        }
        
        // Assert:
        XCTAssertEqual(http.calls.count, 3)
        for (i, call) in http.calls.enumerated() {
            guard case .get(let url, _) = call else {
                XCTFail("unexpected call: \(call)")
                continue
            }
            let ts = url.queryValues(for: "ts")
            XCTAssert(!ts.isEmpty)
            for call in http.calls[(i + 1)...] {
                guard case .get(let url, _) = call else {
                    XCTFail("unexpected call: \(call)")
                    continue
                }
                
                XCTAssert(!ts.isEmpty)
                XCTAssert(!url.queryValues(for: "ts").isEmpty)
                XCTAssertNotEqual(url.queryValues(for: "ts"), ts)
            }
        }
    }
    
    func testConnectionType () {
        // Arrange:
        let connectivitySource = DummyConnectivitySource(connectionType: .wifi)
        let http = HTTPMock()
        let sut = Yieldprobe(http: http, connectivitySource: connectivitySource)
        
        // Act:
        sut.probe(slot: 1234) {
            XCTFail("Should not be called.")
        }
        
        // Assert:
        XCTAssertEqual(http.calls.count, 1)
        guard case .some(.get(let url, _)) = http.calls.first else {
            return XCTFail("Unexpected call: \(http.calls.first as Any)")
        }
        XCTAssertEqual(url.queryValues(for: "yl_rtb_connectiontype"), ["2"])
    }
    
    func testConsentString () {
        // Arrange:
        let consentString = ConsentDecoratorTests().consentStringExample
        let consentSource = DummyConsentSource(consent: consentString)
        let http = HTTPMock()
        let sut = Yieldprobe(http: http, consentSource: consentSource)
        
        // Act:
        sut.probe(slot: 1234) {
            XCTFail("Should not be called.")
        }
        
        // Assert:
        XCTAssertEqual(http.calls.count, 1)
        guard case .some(.get(let url, _)) = http.calls.first else {
            return XCTFail("Unexpected call: \(http.calls.first as Any)")
        }
        XCTAssertEqual(url.queryValues(for: "consent"), [consentString])
    }
    
    func testDeviceType () {
        // Arrange:
        let http = HTTPMock()
        let sut = Yieldprobe(http: http)
        
        // Act:
        sut.probe(slot: 1234) {
            XCTFail("Should not be called.")
        }
        
        // Assert:
        XCTAssertEqual(http.calls.count, 1)
        guard case .some(.get(let url, _)) = http.calls.first else {
            return XCTFail("Unexpected call: \(http.calls.first as Any)")
        }
        let deviceType = url.queryValues(for: "yl_rtb_devicetype")
        XCTAssertTrue(deviceType == ["4"] || deviceType == ["5"],
                      "Unexpected device type: \(deviceType)")
    }
    
    func testGeolocation () {
        struct DummyLocationSource: LocationSource {
            
            var location: CLLocation? {
                LocationDecoratorTests.yieldlabLocation
            }
            
            static func authorizationStatus() -> CLAuthorizationStatus {
                .authorizedAlways
            }
            
            static func locationServicesEnabled() -> Bool {
                true
            }
            
        }
        
        // Arrange:
        let http = HTTPMock()
        let sut = Yieldprobe(http: http, locationSource: DummyLocationSource.self)
        
        // Act:
        sut.probe(slot: 1234) {
            XCTFail("Should not be called.")
        }
        
        // Assert:
        XCTAssertEqual(http.calls.count, 1)
        guard case .some(.get(let url, _)) = http.calls.first else {
            return XCTFail("Unexpected call: \(http.calls.first as Any)")
        }
        XCTAssertEqual(url.queryValues(for: "lat"), ["53.557038"])
        XCTAssertEqual(url.queryValues(for: "lng"), ["9.990018"])
    }
    
    func testIDFA () {
        // Arrange:
        let idfaSource = DummyIDFASource(idfa: UUID())
        let http = HTTPMock()
        let sut = Yieldprobe(http: http, idfa: idfaSource)
        
        // Act:
        sut.probe(slot: 1234) {
            XCTFail("Should not be called.")
        }
        
        // Assert:
        XCTAssertEqual(http.calls.count, 1)
        guard case .some(.get(let url, _)) = http.calls.first else {
            return XCTFail("Unexpected call: \(http.calls.first as Any)")
        }
        XCTAssertEqual(url.queryValues(for: "yl_rtb_ifa"),
                       [idfaSource.advertisingIdentifier.uuidString])
    }
    
    // MARK: Tests for Personal Information
    
    func testNPADisablesConnectionType () {
        // Arrange:
        let connection = DummyConnectivitySource(connectionType: .cellular)
        let http = HTTPMock()
        let sut = Yieldprobe(http: http, connectivitySource: connection)
        sut.configure(using: Configuration(adPersonalization: false))
        
        // Act:
        sut.probe(slot: 1234) {
            XCTFail("Should not be called")
        }
        
        // Assert:
        XCTAssertEqual(http.calls.count, 1)
        guard let call = http.calls.first, case .get(let url, _) = call else {
            return XCTFail("Unexpected call: \(http.calls.first as Any)")
        }
        XCTAssertEqual(url.queryValues(for: "yl_rtb_connectiontype"), [])
    }
    
    func testNPADisablesDeviceType () {
        // Arrange:
        let http = HTTPMock()
        let sut = Yieldprobe(http: http, device: DummyDevice.iPhone7Plus)
        sut.configure(using: Configuration(adPersonalization: false))
        
        // Act:
        sut.probe(slot: 1234) {
            XCTFail("Should not be called.")
        }
        
        // Assert:
        XCTAssertEqual(http.calls.count, 1)
        guard let call = http.calls.first, case .get(let url, _) = call else {
            return XCTFail("Unexpected call: \(http.calls.first as Any)")
        }
        XCTAssertEqual(url.queryValues(for: "yl_rtb_devicetype"), [])
    }
    
    func testNPADisablesIDFA () {
        // Arrange:
        let http = HTTPMock()
        let idfa = UUID()
        let sut = Yieldprobe(http: http,
                             idfa: DummyIDFASource(idfa: idfa))
        sut.configure(using: Configuration(adPersonalization: false))
        
        // Act:
        sut.probe(slot: 1234) {
            XCTFail("Should not be called.")
        }
        
        // Assert:
        XCTAssertEqual(http.calls.count, 1)
        guard let call = http.calls.first, case .get(let url, _) = call else {
            return XCTFail("Unexpected call: \(http.calls.first as Any)")
        }
        XCTAssertEqual(url.queryValues(for: "yl_rtb_ifa"), [])
    }
    
    func testNPADisablesLocation () {
        struct DummyLocationSource: LocationSource {
            var location: CLLocation? {
                LocationDecoratorTests.yieldlabLocation
            }
            
            static func authorizationStatus() -> CLAuthorizationStatus {
                .authorizedAlways
            }
            
            static func locationServicesEnabled() -> Bool {
                true
            }
        }
        
        // Arrange:
        let http = HTTPMock()
        let locationSource = DummyLocationSource.self
        let sut = Yieldprobe(http: http, locationSource: locationSource)
        sut.configure(using: Configuration(adPersonalization: false))
        
        // Act:
        sut.probe(slot: 1234) {
            XCTFail("Should not be called")
        }
        
        // Assert:
        XCTAssertEqual(http.calls.count, 1)
        guard let call = http.calls.first, case .get(let url, _) = call else {
            return XCTFail("Unexpected call: \(http.calls.first as Any)")
        }
        XCTAssertEqual(url.queryValues(for: "lat"), [])
        XCTAssertEqual(url.queryValues(for: "lng"), [])
    }
    
}
