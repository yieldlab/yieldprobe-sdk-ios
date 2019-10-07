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

extension UserDefaults: ConsentSource {
    
    static var iabConsentStringKey: String {
        "IABConsent_ConsentString"
    }
    
    var consent: String? {
        string(forKey: type(of: self).iabConsentStringKey)
    }
    
}

/// Decorate a URL to include a parameter `consent` containing the [IAB Consent String](https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/Mobile%20In-App%20Consent%20APIs%20v1.0%20Final.md#cmp-internal-structure-defined-api-).
struct ConsentDecorator {
    
    static let base64URLCharacters: CharacterSet = {
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
    
    init (consentSource: ConsentSource = UserDefaults.standard) {
        self.consentSource = consentSource
    }
    
    func decorate (_ subject: URL) -> URL {
        return URLComponents(url: subject, resolvingAgainstBaseURL: true)!
            .transformQueryItems { input in
                guard let consentString = consentSource.consent else {
                    return input
                }
                
                // Remove trailing `=` padding.
                var trimmed = consentString[consentString.startIndex...]
                while trimmed.hasSuffix("=") {
                    trimmed = trimmed.dropLast()
                }
                
                if trimmed.isEmpty || trimmed.rangeOfCharacter(from: type(of: self).base64URLCharacters.inverted) != nil {
                    return input
                }
                
                return input + [URLQueryItem(name: "consent", value: String(trimmed))]
            }.url!
    }
    
}
