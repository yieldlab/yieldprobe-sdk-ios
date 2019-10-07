//
//  LocationDecoratorTests.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 07.10.19.
//

import CoreLocation
import XCTest
@testable import Yieldprobe

struct DummyApplication: Application {
    
    var applicationState: UIApplication.State
    
}

class LocationDecoratorTests: XCTestCase {
    
    static let yieldlabLocation =
        CLLocation(coordinate: CLLocationCoordinate2D(latitude: 53.557038,
                                                      longitude: 9.990018),
                   altitude: 20,
                   horizontalAccuracy: 50,
                   verticalAccuracy: 10,
                   timestamp: Date())
    
    func testDefaultLocationSource () {
        // Arrange:
        let sut = LocationDecorator()
        
        // Act:
        let source = sut.locationSource
        
        // Assert:
        XCTAssert(source.init() is CLLocationManager)
    }
    
    func testLocationServicesDisabled () {
        class DummyLocationSource: LocationSource {
            var location: CLLocation? { fatalError() }
            
            required init () { fatalError() }

            static func authorizationStatus() -> CLAuthorizationStatus {
                fatalError()
            }
            
            static func locationServicesEnabled () -> Bool {
                false
            }
        }
        
        // Arrange:
        let url = URL(string: "https://example.com/")!
        let sut = LocationDecorator(locationSource: DummyLocationSource.self)
        
        // Act:
        let result = sut.decorate(url)
        
        // Assert:
        XCTAssertEqual(result, url)
    }
    
    func testLocationServicesAuthorizedAlways_WithoutLocation () {
        class DummyLocationSource: LocationSource {
            var location: CLLocation? { nil }
            
            static func authorizationStatus() -> CLAuthorizationStatus {
                .authorizedAlways
            }
            
            static func locationServicesEnabled() -> Bool {
                true
            }
            
            required init () { }
        }
        
        // Arrange:
        let url = URL(string: "https://example.com/")!
        let sut = LocationDecorator(locationSource: DummyLocationSource.self)
        
        // Act:
        let result = sut.decorate(url)
        
        // Assert:
        XCTAssertEqual(result, url)
    }
    
    func testLocationServicesAuthorizedAlways_WithLocation () {
        class DummyLocationSource: LocationSource {
            var location: CLLocation? {
                LocationDecoratorTests.yieldlabLocation
            }
            
            static func authorizationStatus() -> CLAuthorizationStatus {
                .authorizedAlways
            }
            
            static func locationServicesEnabled() -> Bool {
                true
            }
            
            required init () { }
        }
        
        // Arrange:
        let url = URL(string: "https://example.com/")!
        let sut = LocationDecorator(locationSource: DummyLocationSource.self)
        
        // Act:
        let result = sut.decorate(url)
        
        // Assert:
        XCTAssertNotEqual(result, url)
        XCTAssertEqual(result.queryValues(for: "lat"), ["53.557038"])
        XCTAssertEqual(result.queryValues(for: "lng"), ["9.990018"])
    }
    
    func testLocationServicesAuthorizedInUse_Background () {
        class DummyLocationSource: LocationSource {
            var location: CLLocation? {
                fatalError()
            }
            
            static func authorizationStatus() -> CLAuthorizationStatus {
                .authorizedWhenInUse
            }
            
            static func locationServicesEnabled() -> Bool {
                true
            }
            
            required init () { }
        }
        
        // Arrange:
        let url = URL(string: "https://example.com/")!
        let sut = LocationDecorator(application: DummyApplication(applicationState: .background),
                                    locationSource: DummyLocationSource.self)
        
        // Act:
        let result = sut.decorate(url)
        
        // Assert:
        XCTAssertEqual(result, url)
    }
    
    func testLocationServicesAuthorizedInUse_Foreground () {
        class DummyLocationSource: LocationSource {
            var location: CLLocation? {
                LocationDecoratorTests.yieldlabLocation
            }
            
            static func authorizationStatus() -> CLAuthorizationStatus {
                .authorizedWhenInUse
            }
            
            static func locationServicesEnabled() -> Bool {
                true
            }
            
            required init () { }
        }
        
        // Arrange:
        let url = URL(string: "https://example.com/")!
        let sut = LocationDecorator(application: DummyApplication(applicationState: .active),
                                    locationSource: DummyLocationSource.self)
        
        // Act:
        let result = sut.decorate(url)
        
        // Assert:
        XCTAssertNotEqual(result, url)
        XCTAssertEqual(result.queryValues(for: "lat"), ["53.557038"])
        XCTAssertEqual(result.queryValues(for: "lng"), ["9.990018"])
    }
    
    func testLocationServicesNotDetermined () {
        class DummyLocationSource: LocationSource {
            var location: CLLocation? {
                fatalError()
            }
            
            static func authorizationStatus() -> CLAuthorizationStatus {
                .notDetermined
            }
            
            static func locationServicesEnabled() -> Bool {
                true
            }
            
            required init () { }
        }
        
        // Arrange:
        let url = URL(string: "https://example.com/")!
        let sut = LocationDecorator(application: DummyApplication(applicationState: .active),
                                    locationSource: DummyLocationSource.self)
        
        // Act:
        let result = sut.decorate(url)
        
        // Assert:
        XCTAssertEqual(result, url)
    }
    
    func testLocationServicesDenied () {
        class DummyLocationSource: LocationSource {
            var location: CLLocation? {
                fatalError()
            }
            
            static func authorizationStatus() -> CLAuthorizationStatus {
                .denied
            }
            
            static func locationServicesEnabled() -> Bool {
                true
            }
            
            required init () { }
        }
        
        // Arrange:
        let url = URL(string: "https://example.com/")!
        let sut = LocationDecorator(application: DummyApplication(applicationState: .active),
                                    locationSource: DummyLocationSource.self)
        
        // Act:
        let result = sut.decorate(url)
        
        // Assert:
        XCTAssertEqual(result, url)
    }
    
    func testLocationServicesRestricted () {
        class DummyLocationSource: LocationSource {
            var location: CLLocation? {
                fatalError()
            }
            
            static func authorizationStatus() -> CLAuthorizationStatus {
                .restricted
            }
            
            static func locationServicesEnabled() -> Bool {
                true
            }
            
            required init () { }
        }
        
        // Arrange:
        let url = URL(string: "https://example.com/")!
        let sut = LocationDecorator(application: DummyApplication(applicationState: .active),
                                    locationSource: DummyLocationSource.self)
        
        // Act:
        let result = sut.decorate(url)
        
        // Assert:
        XCTAssertEqual(result, url)
    }
    
}
