//
//  Collection+YLD.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 15.10.19.
//


extension Collection {
    
    func compactMap<Wrapped>() -> [Wrapped]
        where Element == Optional<Wrapped>
    {
        compactMap {
            $0
        }
    }
    
}
