//
//  ConsentDecorator.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 07.10.19.
//

import Foundation

protocol ConsentSource {
    
    var consent: String? { get }
    
}

/// Decorate a URL to include a parameter `consent` containing the [IAB Consent String](https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/Mobile%20In-App%20Consent%20APIs%20v1.0%20Final.md#cmp-internal-structure-defined-api-).
struct ConsentDecorator: URLDecoratorProtocol {
    
    static let base64URLCharacters: CharacterSet = {
        // Reference: https://tools.ietf.org/html/rfc4648#section-5
        let lowercaseASCII = CharacterSet(charactersIn: "a"..."z")
        let uppercaseASCII = CharacterSet(charactersIn: "A"..."Z")
        let digitsASCII = CharacterSet(charactersIn: "0"..."9")
        let validSymbols = CharacterSet(charactersIn: "-_")
        
        return lowercaseASCII
            .union(uppercaseASCII)
            .union(digitsASCII)
            .union(validSymbols)
    }()
    
    let consentSource: ConsentSource
    
    init (consentSource: ConsentSource? = nil) {
        self.consentSource = consentSource ?? UserDefaults.standard
    }
    
    func decorate (_ subject: URL) -> URL {
        guard let consentString = consentSource.consent else {
            return subject
        }
        
        // Remove trailing `=` padding.
        var trimmed = consentString[consentString.startIndex...]
        while trimmed.hasSuffix("=") {
            trimmed = trimmed.dropLast()
        }
        
        if trimmed.isEmpty ||
            trimmed.rangeOfCharacter(from: type(of: self).base64URLCharacters.inverted) != nil
        {
            return subject
        }
        
        return URLComponents(url: subject, resolvingAgainstBaseURL: true)!
            .transformQueryItems { input in
                input + [
                    URLQueryItem(name: "consent", value: String(trimmed))
                ]
            }.url!
    }
    
}
