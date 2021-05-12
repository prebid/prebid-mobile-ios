//
//  ConversionTrackingError.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation

/// Type of conversion tracking error.
enum ConversionTrackingError: Error {
    /// Failed to generate a conversion tracking URL. It is likely that the
    /// application ID is malformed.
    case failedToGenerateTrackerURL
    
    
    /// Failed to track conversion due to a network failure.
    case networkFailure(statusCode: Int)
    
    /// The application ID used for conversion tracking has not been specified,
    /// or contains only newline and whitespace characters.
    case noApplicationIdSpecified
}

extension ConversionTrackingError: LocalizedError {
    // MARK: - LocalizedError
    
    var errorDescription: String? {
        switch self {
        case .failedToGenerateTrackerURL: return "Failed to generate conversion tracking URL."
        case .networkFailure(let statusCode): return "Failed to track conversion due to network failure. Status code: \(statusCode)"
        case .noApplicationIdSpecified: return "No application ID has been specified, or the application ID contains only newline and whitespace characters."
        }
    }
}
