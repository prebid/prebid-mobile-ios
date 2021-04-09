//
//  APIEndpoints.swift
//
//  Copyright 2018-2020 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation


@objc(MPAPIEndpoints)
public final class APIEndpoints: NSObject {
    
    // MARK: - MoPub ads URL
    enum Path: String {
        /// URL path for ad request. To be used with the MoPub ads URL.
        case adRequest = "/m/ad"
        
        ///  URL path for native ad positioning request. To be used with the MoPub ads URL.
        case nativePositioning = "/m/pos"
        
        ///  URL path for open request. To be used with the MoPub ads URL.
        case open = "/m/open"
        
        ///  URL path for the GDPR consent dialog. To be used with the MoPub ads URL.
        case consentDialog = "/m/gdpr_consent_dialog"
        
        /// URL path for GDPR sync request. To be used with the MoPub ads URL.
        case consentSync = "/m/gdpr_sync"
    }
    
    // Exposing to Obj-C
    
    @objc public static var adRequestURLComponents: URLComponents { baseURLComponents(with: .adRequest) }
    @objc public static var nativePositioningURLComponents: URLComponents { baseURLComponents(with: .nativePositioning) }
    @objc public static var openURLComponents: URLComponents { baseURLComponents(with: .open) }
    @objc public static var consentDialogURLComponents: URLComponents { baseURLComponents(with: .consentDialog) }
    @objc public static var consentSyncURLComponents: URLComponents { baseURLComponents(with: .consentSync) }
    
    // Base URL constant
    static let defaultBaseHostname = "ads.mopub.com"
    
    
    /// Returns the base hostname string for the MoPub ads URL.
    @objc public static var baseHostname: String = defaultBaseHostname {
        didSet {
            if baseHostname.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
                baseHostname = defaultBaseHostname
            }
        }
    }
    
    
    /// Returns a URL containing the base hostname string for the MoPub ads URL.
    @objc public static var baseURL: URL? {
        urlComponents(with: baseHostname).url
    }
    
    /// Returns an `NSURLComponents` instance with the ads URL base hostname string and the given
    /// path.
    ///
    /// - Parameters:
    ///     - path: The path component of the URL
    /// - Returns: The `NSURLComponents` instance with the given path
    static func baseURLComponents(with path: Path) -> URLComponents {
        urlComponents(with: baseHostname, path: path.rawValue)
    }
    
    // MARK: - MoPub callback URL
    enum CallbackPath: String {
        /// URL path for SKAdNetwork synchronization. To be used with the MoPub callback URL.
        case skAdNetworkSync = "/supported_ad_partners"
    }
    
    // Exposing to Obj-C
    
    @objc public static var skAdNetworkSyncURLComponents: URLComponents { callbackBaseURLComponents(with: .skAdNetworkSync) }
    
    /// The base hostname string for the MoPub callback URL.
    private static let callbackBaseHostname = "cb.mopub.com"
    
    /// Returns an `NSURLComponents` instance with the callback URL base hostname string and the
    /// given path.
    ///
    /// - Parameters:
    ///     - path: The path component of the URL
    /// - Returns: The `NSURLComponents` instance with the given path
    static func callbackBaseURLComponents(with path: CallbackPath) -> URLComponents {
        urlComponents(with: callbackBaseHostname, path: path.rawValue)
    }
}

// MARK: - Helpers
private extension APIEndpoints {
    static let httpsScheme = "https"
    
    static func urlComponents(with hostname: String, path: String? = nil) -> URLComponents {
        var components = URLComponents()
        components.scheme = httpsScheme
        components.host = hostname
        
        if let path = path {
            components.path = path
        }
        
        return components
    }
}
