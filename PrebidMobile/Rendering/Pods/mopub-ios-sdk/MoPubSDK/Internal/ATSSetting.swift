//
//  ATSSetting.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation

struct ATSSetting: OptionSet {
    let rawValue: Int
    
    static let enabled                          = ATSSetting([])
    static let allowsArbitraryLoads             = ATSSetting(rawValue: 1 << 0)
    static let allowsArbitraryLoadsForMedia     = ATSSetting(rawValue: 1 << 1)
    static let allowsArbitraryLoadsInWebContent = ATSSetting(rawValue: 1 << 2)
    static let requiresCertificateTransparency  = ATSSetting(rawValue: 1 << 3)
    static let allowsLocalNetworking            = ATSSetting(rawValue: 1 << 4)
    
    /// Converts an ATS dictionary into `ATSSetting`.
    /// - Parameter atsDictionary: An ATS dictionary read from the application's Info.plist
    /// - Returns: An `ATSSetting` created from the dictionary.
    static func setting(from atsDictionary: [String: Any]) -> ATSSetting {
        var result = ATSSetting.enabled
        
        // Check if ATS is entirely disabled, and if so, add that to the setting value
        if atsDictionary[Constants.allowsArbitraryLoadsKey] as? Bool == true {
            result.insert(.allowsArbitraryLoads)
        }
        
        // In iOS 10, NSAllowsArbitraryLoads gets ignored if ANY keys of NSAllowsArbitraryLoadsForMedia,
        // NSAllowsArbitraryLoadsInWebContent, or NSAllowsLocalNetworking are PRESENT (i.e., they can be set to `false`)
        // See: https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW34
        // If needed, flip NSAllowsArbitraryLoads back to 0 if any of these keys are present.
        if atsDictionary[Constants.allowsArbitraryLoadsForMediaKey] != nil
                || atsDictionary[Constants.allowsArbitraryLoadsInWebContentKey] != nil
                || atsDictionary[Constants.allowsLocalNetworkingKey] != nil {
            result.remove(.allowsArbitraryLoads)
        }
        
        if atsDictionary[Constants.allowsArbitraryLoadsForMediaKey] as? Bool == true {
            result.insert(.allowsArbitraryLoadsForMedia)
        }
        if atsDictionary[Constants.allowsArbitraryLoadsInWebContentKey] as? Bool == true {
            result.insert(.allowsArbitraryLoadsInWebContent)
        }
        if atsDictionary[Constants.requiresCertificateTransparencyKey] as? Bool == true {
            result.insert(.requiresCertificateTransparency)
        }
        if atsDictionary[Constants.allowsLocalNetworkingKey] as? Bool == true {
            result.insert(.allowsLocalNetworking)
        }
        
        return result
    }
}

// MARK: - Private
private extension ATSSetting {
    struct Constants {
        static let allowsArbitraryLoadsKey = "NSAllowsArbitraryLoads"
        static let allowsArbitraryLoadsForMediaKey = "NSAllowsArbitraryLoadsForMedia"
        static let allowsArbitraryLoadsInWebContentKey = "NSAllowsArbitraryLoadsInWebContent"
        static let allowsLocalNetworkingKey = "NSAllowsLocalNetworking"
        static let requiresCertificateTransparencyKey = "NSRequiresCertificateTransparency"
    }
}
