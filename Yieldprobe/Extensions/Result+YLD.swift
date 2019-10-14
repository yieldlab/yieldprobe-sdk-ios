//
//  Result+YLD.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 11.10.19.
//

extension Result {
    
    // Mimick Combine.Publisher.tryMap()
    func tryMap<T> (_ transform: (Success) throws -> T) -> Result<T,Error> {
        Result<T,Error> {
            try transform(self.get())
        }
    }
    
}
