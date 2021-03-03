//
//  UserDefaults+YLD.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 07.10.19.
//

import Foundation

let iabConsentStringKey = "IABTCF_TCString"

protocol UserDefaultsProtocol: ConsentSource {
    
    func string (forKey key: String) -> String?
    
}

extension UserDefaultsProtocol {
    
    var consent: String? {
        string(forKey: iabConsentStringKey)
    }
    
}

extension UserDefaults: UserDefaultsProtocol { }
