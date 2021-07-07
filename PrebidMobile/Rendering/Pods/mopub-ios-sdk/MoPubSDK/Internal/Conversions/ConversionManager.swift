//
//  ConversionManager.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation


/// Manages conversion tracking for the MoPub SDK.
@objc(MPConversionManager)
public final class ConversionManager: NSObject {
    // MARK: - UserDefaults Backed Properties
    
    /// Application ID specified by the publisher that is used for the conversion tracker.
    @UserDefaultsBacked(key: "com.mopub.conversion.appId", defaultValue: nil)
    private static var appId: String?
    
    /// Flag indicating that the conversion tracking event has already been sent for this installation.
    @UserDefaultsBacked(key: "com.mopub.conversion", defaultValue: false)
    private static var isConversionAlreadyTracked: Bool
    
    // MARK: - Tracking
    
    /// Sets the application identifier used for conversion tracking purposes.
    /// - Parameter applicationId: The iTunes ID for the application.
    @objc public static func setConversionAppId(_ applicationId: String) {
        appId = applicationId
    }
    
    
    /// Tracks the app conversion.
    /// If the conversion has already been tracked, this method will return immediately.
    /// - Note: The conversion tracking event is considered PII and it is the caller's responsibility to check
    /// that PII is allowed to be sent before calling this method.
    @objc public static func trackConversion() {
        trackConversion { _ in
            // no-op to differentiate the call to the underlying method.
        }
    }
    
    /// Tracks the app conversion.
    /// If the conversion has already been tracked, this method will return immediately without calling the completion closure.
    /// - Parameter complete: Optional closure invoked upon completion or error.
    /// - Note: The conversion tracking event is considered PII and it is the caller's responsibility to check
    /// that PII is allowed to be sent before calling this method.
    static func trackConversion(_ complete: ((Result<Void, Error>) -> Void)? = nil) {
        // Validate that the conversion has not already been tracked.
        // It is likely that conversion tracking is called at every app launch,
        // but only the first successful tracking is valid.
        guard !isConversionAlreadyTracked else {
            return
        }
        
        // Validate that the `appId` is not `nil` or empty before attempting to track the conversion.
        guard let applicationId = appId?.trimmingCharacters(in: .whitespacesAndNewlines), applicationId.count > 0 else {
            complete?(.failure(ConversionTrackingError.noApplicationIdSpecified))
            return
        }
        
        // Retrieve the conversion tracking URL for the given application ID.
        guard let url = MPAdServerURLBuilder.conversionTrackingURL(forAppID: applicationId) else {
            complete?(.failure(ConversionTrackingError.failedToGenerateTrackerURL))
            return
        }
        
        // Send the conversion tracking request.
        let request = MPURLRequest(url: url as URL)
        MPHTTPNetworkSession.startTask(withHttpRequest: request as URLRequest) { (_, response) in
            // Networking error
            guard response.statusCode == 200 else {
                complete?(.failure(ConversionTrackingError.networkFailure(statusCode: response.statusCode)))
                return
            }
            
            // Conversion tracking was successful.
            isConversionAlreadyTracked = true
            complete?(.success(Void()))
        }
    }
}
