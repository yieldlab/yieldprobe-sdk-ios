//
//  DeviceTypeDecoratorTests.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 08.10.19.
//

import XCTest
@testable import Yieldprobe

struct DummyDevice: Device {
    
    /// The iPod Touch from 2012. It featured the 4" screen from the iPhone 5.
    static let iPodTouch5G = DummyDevice(hardwareRevision: "iPod7,1")
    
    /// The large iPhone from 2016.
    static let iPhone7Plus = DummyDevice(hardwareRevision: "iPhone9,4")
    
    /// The smaller iPad Pro from 2018.
    static let iPadPro11Inch = DummyDevice(hardwareRevision: "iPad8,3")
    
    var hardwareRevision: String
    
}

class DeviceTypeDecoratorTests: XCTestCase {
    
    func testDeviceType_iPad () {
        // Arrange:
        let input = URL(string: "https://example.com/")!
        let device = DummyDevice.iPadPro11Inch
        let sut = DeviceTypeDecorator(device: device)
        
        // Act:
        let output = sut.decorate(input)
        
        // Assert:
        XCTAssertNotEqual(output, input)
        XCTAssertEqual(output.queryValues(for: "yl_rtb_devicetype"), ["5"])
    }
    
    func testDeviceType_iPhone () {
        // Arrange:
        let input = URL(string: "https://example.com/")!
        let device = DummyDevice.iPhone7Plus
        let sut = DeviceTypeDecorator(device: device)
        
        // Act:
        let output = sut.decorate(input)
        
        // Assert:
        XCTAssertNotEqual(output, input)
        XCTAssertEqual(output.queryValues(for: "yl_rtb_devicetype"), ["4"])
    }
    
    func testDeviceType_iPod () {
        // Arrange:
        let input = URL(string: "https://example.com/")!
        let device = DummyDevice.iPodTouch5G
        let sut = DeviceTypeDecorator(device: device)
        
        // Act:
        let output = sut.decorate(input)
        
        // Assert:
        XCTAssertNotEqual(output, input)
        XCTAssertEqual(output.queryValues(for: "yl_rtb_devicetype"), ["4"])
    }

}
