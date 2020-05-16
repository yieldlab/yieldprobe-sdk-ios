//
//  ConsentDecoratorTests.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 07.10.19.
//

import XCTest
@testable import Yieldprobe

struct DummyConsentSource: ConsentSource {
    
    let consent: String?
    
}

class ConsentDecoratorTests: XCTestCase {
    
    let url = URL(string: "https://example.com/")!
    
    // From: https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/Consent%20string%20and%20vendor%20list%20formats%20v1.1%20Final.md#building-the-base64-representation
    let consentStringExample = "BOEFEAyOEFEAyAHABDENAI4AAAB9vABAASA"
    
    func testWithoutConsent () {
        // Arrange:
        let consentSource = DummyConsentSource(consent: nil)
        let sut = ConsentDecorator(consentSource: consentSource)
        
        // Act:
        let url = sut.decorate(self.url)
        
        // Assert:
        XCTAssertEqual(url.queryValues(for: "consent"), [])
    }
    
    func testWithConsent () {
        // Arrange:
        let consentSource = DummyConsentSource(consent: consentStringExample)
        let sut = ConsentDecorator(consentSource: consentSource)
        
        // Act:
        let url = sut.decorate(self.url)
        
        // Assert:
        XCTAssertEqual(url.queryValues(for: "consent"), [consentStringExample])
    }
    
    // Consent strings should not have padding, but they can be padded.
    func testWithPaddedConsent () {
        // Arrange:
        let consentSource = DummyConsentSource(consent: consentStringExample + "====")
        let sut = ConsentDecorator(consentSource: consentSource)
        
        // Act:
        let url = sut.decorate(self.url)
        
        // Assert:
        XCTAssertNotEqual(consentSource.consent, consentStringExample)
        XCTAssertEqual(url.queryValues(for: "consent"), [consentStringExample])
    }
    
    func testWithBrokenConsent () {
        // Arrange:
        let consentSource = DummyConsentSource(consent: "This is not a valid consent string.")
        let sut = ConsentDecorator(consentSource: consentSource)
        
        // Act:
        let url = sut.decorate(self.url)
        
        // Assert:
        XCTAssertEqual(url.queryValues(for: "consent"), [])
    }
    
}
