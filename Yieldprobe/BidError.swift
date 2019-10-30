//
//  BidError.swift
//  Yieldprobe
//
//  Created by Sven Herzberg on 30.10.19.
//

import Foundation

public enum BidError: Swift.Error, Equatable {
    /// The app did not request a single advertising slot.
    case noSlot
    
    /// The app requested more than 10 ad slots.
    case tooManySlots
    
    /// An HTTP error occurred.
    case httpError(statusCode: Int, localizedMessage: String)
    
    /// An unexpected value was encountered in the `Content-Type` header.
    case unsupportedContentType(String?)
    
    /// The format of the reponse could not be parsed.
    case unsupportedFormat
    
    /// No ad is available for this ad slot.
    case noFill
}

extension BidError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .httpError(let statusCode, let localizedMessage):
            return "Server returned \(statusCode): \(localizedMessage)"
        case .noFill:
            return "No Bid available. Please try again later."
        case .noSlot:
            return "No ad slot provided."
        case .tooManySlots:
            return "Too many ad slots provided."
        case .unsupportedContentType:
            return "Server returned unexpected data format."
        case .unsupportedFormat:
            return "Server returned invalid data."
        }
    }
    
}
