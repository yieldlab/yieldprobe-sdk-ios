//
//  Set+YLD.swift
//  Unit Tests
//
//  Created by Sven Herzberg on 11.10.19.
//

import Foundation

extension Set {
    
    func randomSubset () -> Set<Element> {
        var generator: RandomNumberGenerator = SystemRandomNumberGenerator()
        return randomSubset(using: &generator)
    }
    
    func randomSubset (using generator: inout RandomNumberGenerator) -> Set<Element> {
        let nextBit: (inout RandomNumberGenerator) -> Bool = {
            var cached = (value: UInt64(0), bits: 0)
            return { (generator: inout RandomNumberGenerator) -> Bool in
                if cached.bits < 1 {
                    cached = (value: generator.next(), bits: 64)
                }
                
                defer {
                    cached = (value: cached.value >> 1,
                              bits: cached.bits - 1)
                }
                
                return cached.value.isMultiple(of: 2)
            }
        }()
        
        return filter { _ in
            nextBit(&generator)
        }
    }
    
}
