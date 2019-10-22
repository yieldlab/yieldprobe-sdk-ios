//
//  YieldprobeTests.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 01.10.19.
//

import CoreLocation
import Foundation
@testable import Test_Host
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
        XCTAssertEqual(url.queryValues(for: "sdk"), ["1"])
    }
    
    func testTooManySlots () {
        // Arrange:
        var caught: Error?
        var expectation: Optional = self.expectation(description: "async call")
        let sut = Yieldprobe()
        
        // Act:
        sut.probe(slots: [0,1,2,3,4,5,6,7,8,9,10]) { result in
            do {
                _ = try result.get()
                XCTFail("Should not be called")
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
        XCTAssertNotNil(caught)
        XCTAssertEqual(caught as? Yieldprobe.Error, .tooManySlots)
    }
    
    // MARK: Bid Request Parameters
    
    func testAppName () {
        // Arrange:
        let configuration = Configuration(appName: "Amazing App")
        let http = HTTPMock()
        let sut = Yieldprobe(http: http)
        sut.configure(using: configuration)
        
        // Act:
        sut.probe(slot: 1234) { _ in }
        
        // Assert:
        XCTAssertEqual(http.calls.count, 1)
        http.calls.first?.process { url in
            XCTAssertEqual(url.queryValues(for: "pubappname"), ["Amazing App"])
            
            throw URLError(.notConnectedToInternet)
        }
    }
    
    func testBundleID () {
        // Arrange:
        let configuration = Configuration(bundleID: "com.example.some-test")
        let http = HTTPMock()
        let sut = Yieldprobe(http: http)
        sut.configure(using: configuration)
        
        // Act:
        sut.probe(slot: 1234) { _ in }
        
        // Assert:
        XCTAssertEqual(http.calls.count, 1)
        http.calls.first?.process { url in
            XCTAssertEqual(url.queryValues(for: "pubbundlename"), ["com.example.some-test"])
            
            throw URLError(.notConnectedToInternet)
        }
    }
    
    func testCacheBusting () {
        // Arrange:
        let http = HTTPMock()
        let sut = Yieldprobe(http: http)
        
        // Act:
        for _ in 1...3 {
            sut.probe(slot: 1234) { _ in
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
        sut.probe(slot: 1234) { _ in
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
        sut.probe(slot: 1234) { _ in
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
        sut.probe(slot: 1234) { _ in
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
    
    func testExtraTargeting () {
        // Arrange:
        let configuration = Configuration(extraTargeting: ["key" : "value"])
        let http = HTTPMock()
        let sut = Yieldprobe(http: http)
        sut.configure(using: configuration)
        
        // Act:
        sut.probe(slot: 1234) { _ in }
        
        // Assert:
        XCTAssertEqual(http.calls.count, 1)
        http.calls.first?.process { url in
            XCTAssertEqual(url.queryValues(for: "t"), ["key=value"])
            
            throw Yieldprobe.Error.noFill
        }
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
        sut.probe(slot: 1234) { _ in
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
        sut.probe(slot: 1234) { _ in
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
    
    // MARK: Personal Information
    
    func testNPADisablesConnectionType () {
        // Arrange:
        let connection = DummyConnectivitySource(connectionType: .cellular)
        let http = HTTPMock()
        let sut = Yieldprobe(http: http, connectivitySource: connection)
        sut.configure(using: Configuration(personalizeAds: false))
        
        // Act:
        sut.probe(slot: 1234) { _ in
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
        sut.configure(using: Configuration(personalizeAds: false))
        
        // Act:
        sut.probe(slot: 1234) { _ in
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
        sut.configure(using: Configuration(personalizeAds: false))
        
        // Act:
        sut.probe(slot: 1234) { _ in
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
        sut.configure(using: Configuration(personalizeAds: false))
        
        // Act:
        sut.probe(slot: 1234) { _ in
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
    
    // MARK: Response Handling
    
    func testResponseNetworkError () {
        // Arrange:
        var expectation: Optional = self.expectation(description: "Async HTTP Call")
        let http = HTTPMock()
        var result: Result<Bid,Error>?
        let sut = Yieldprobe(http: http)
        sut.probe(slot: 1234) { _result in
            XCTAssertNil(result)
            result = _result
            
            expectation?.fulfill()
            expectation = nil
        }
        
        // Act:
        http.calls.first?.process { _ in
            throw URLError(.notConnectedToInternet)
        }
        
        // Assert:
        wait(for: [expectation!], timeout: 0.1)
        expectation = nil
        XCTAssertNotNil(result)
        XCTAssertThrowsError(try result?.get()) { error in
            XCTAssertEqual(error as? URLError, URLError(.notConnectedToInternet))
        }
    }
    
    func testResponseHTTPError () {
        // Arrange:
        var expectation: Optional = self.expectation(description: "Async HTTP Call")
        let http = HTTPMock()
        var result: Result<Bid,Error>?
        let sut = Yieldprobe(http: http)
        sut.probe(slot: 1234) { _result in
            XCTAssertNil(result)
            result = _result
            
            expectation?.fulfill()
            expectation = nil
        }
        
        // Act:
        http.calls.first?.process { url in
            try URLReply(text: "<!DOCTYPE html><html><title>404</title>",
                         response: HTTPURLResponse(url: url,
                                                   statusCode: 404,
                                                   httpVersion: nil,
                                                   headerFields: nil)!)
        }
        
        // Assert:
        wait(for: [expectation!], timeout: 0.1)
        expectation = nil
        XCTAssertNotNil(result)
        XCTAssertThrowsError(try result?.get()) { error in
            XCTAssertEqual(error as? Yieldprobe.Error,
                           .httpError(statusCode: 404, localizedMessage: "not found"))
        }
    }
    
    func testNonJSONContentType () {
        // Arrange:
        var expectation: Optional = self.expectation(description: "Async HTTP Call")
        let javascript = """
        var yl=yl||{};yl.YpResult=yl.YpResult||function(){var a={};return{add:function(b){a[b.id]=b},get:function(b) {return a[b]},getAll:function(){return a}}}(); yl.YpResult.add({'id':3418,'advertiser':'werbung. de','curl':'https://www.werbung.de'}); yl.YpResult.add({'id':3419,'advertiser':'werbung.de','curl':'https://www.werbung.de'});
        """ // from the API documentation
        let http = HTTPMock()
        var result: Result<Bid,Error>?
        let sut = Yieldprobe(http: http)
        sut.probe(slot: 1234) { _result in
            XCTAssertNil(result)
            result = _result
            
            expectation?.fulfill()
            expectation = nil
        }
        
        // Act:
        http.calls.first?.process { url in
            try URLReply(text: javascript,
                         response: HTTPURLResponse(url: url,
                                                   statusCode: 200,
                                                   httpVersion: nil,
                                                   headerFields: ["Content-Type" : "text/javascript;charset=UTF-8"])!)
        }
        
        // Assert:
        wait(for: [expectation!], timeout: 0.1)
        expectation = nil
        XCTAssertNotNil(result)
        XCTAssertThrowsError(try result?.get()) { error in
            XCTAssertEqual(error as? Yieldprobe.Error,
                           .unsupportedContentType("text/javascript;charset=UTF-8"))
        }
    }
    
    func testUnsupportedFormat () {
        // Arrange:
        var expectation: Optional = self.expectation(description: "Async HTTP Call")
        let http = HTTPMock()
        var result: Result<Bid,Error>?
        let sut = Yieldprobe(http: http)
        sut.probe(slot: 1234) { _result in
            XCTAssertNil(result)
            result = _result
            
            expectation?.fulfill()
            expectation = nil
        }
        
        // Act:
        http.calls.first?.process { url in
            try URLReply(text: "{}",
                         response: HTTPURLResponse(url: url,
                                                   statusCode: 200,
                                                   httpVersion: nil,
                                                   headerFields: ["Content-Type" : "application/json;charset=UTF-8"])!)
        }
        
        // Assert:
        wait(for: [expectation!], timeout: 0.1)
        expectation = nil
        XCTAssertNotNil(result)
        XCTAssertThrowsError(try result?.get()) { error in
            XCTAssertEqual(error as? Yieldprobe.Error, .unsupportedFormat)
        }
    }
    
    struct TestResponse: Encodable {
        var id: Int
        var price = 340
        var advertiser = "yieldlab"
        var adsize = "300x250"
        var pid = 6846242
        var did = 5209027
        var pvid = "130048b6-6443-418f-9c30-1db968e3cdf2"
    }
    
    func testNoFill () {
        // Arrange:
        var expectation: Optional = self.expectation(description: "Async HTTP Call")
        let http = HTTPMock()
        var result: Result<Bid,Error>?
        let sut = Yieldprobe(http: http)
        sut.probe(slot: 1234) { _result in
            XCTAssertNil(result)
            result = _result
            
            expectation?.fulfill()
            expectation = nil
        }
        
        // Act:
        http.calls.first?.process { url in
            try URLReply([TestResponse](),
                         response: HTTPURLResponse(url: url,
                                                   statusCode: 200,
                                                   httpVersion: nil,
                                                   headerFields: ["Content-Type": "application/json;charset=UTF-8"])!)
        }
        
        // Assert:
        wait(for: [expectation!], timeout: 0.1)
        expectation = nil
        XCTAssertNotNil(result)
        XCTAssertThrowsError(try result?.get()) { error in
            XCTAssertEqual(error as? Yieldprobe.Error, .noFill)
        }
    }
    
    func testResponse () {
        // Arrange:
        var bid: Bid?
        var expectation: Optional = self.expectation(description: "Async HTTP Call")
        let http = HTTPMock()
        let sut = Yieldprobe(http: http)
        
        // Act:
        sut.probe(slot: ExampleSlot.banner300x250.rawValue) { result in
            do {
                XCTAssertNil(bid)
                bid = try result.get()
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
            
            expectation?.fulfill()
            expectation = nil
        }
        http.calls.first?.process { url in
            try URLReply([TestResponse(id: ExampleSlot.banner300x250.rawValue)],
                         response: HTTPURLResponse(url: url,
                                                   statusCode: 200,
                                                   httpVersion: nil,
                                                   headerFields: [
                                                    "Content-Type": "application/json;charset=UTF-8",
                         ])!)
        }
        
        // Assert:
        wait(for: [expectation!], timeout: 0.1)
        expectation = nil
        XCTAssertEqual(bid?.slotID, ExampleSlot.banner300x250.rawValue)
        let customTargeting = bid?.customTargeting()
        XCTAssertEqual(customTargeting?["id"] as? Int, bid?.slotID)
        XCTAssertEqual(customTargeting?["price"] as? Int, 340)
        XCTAssertEqual(customTargeting?["advertiser"] as? String, "yieldlab")
        XCTAssertEqual(customTargeting?["adsize"] as? String, "300x250")
        XCTAssertEqual(customTargeting?["pid"] as? Int, 6846242)
        XCTAssertEqual(customTargeting?["did"] as? Int, 5209027)
        XCTAssertEqual(customTargeting?["pvid"] as? String,
                       "130048b6-6443-418f-9c30-1db968e3cdf2")
    }
    
}
