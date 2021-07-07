//
//  URLRequestComparable.swift
//
//  Copyright 2018-2021 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import Foundation


/// Provides a common means of deduplicating URL-specific requests rather than `MPURLRequest` as a whole.
@objc(MPURLRequestComparable)
public protocol URLRequestComparable {
    func isRequest(_ urlRequest1: MPURLRequest?, duplicateOf urlRequest2: MPURLRequest?) -> Bool
}


/// Concrete implementation of `URLRequestComparable` for specifically deduplicating instances of `MPURLRequest` that represent consent syncronization requests.
@objc(MPConsentSynchronizationURLCompare)
public class ConsentSynchronizationURLCompare: NSObject, URLRequestComparable {
    /// For the `consentSynchronizationUrl` we use the URL and post data to determine equality. Other properties that are part of the `MPURLRequest` like the cache policy, cookie policy, user agent value, etc. are ignored.
    public func isRequest(_ urlRequest1: MPURLRequest?, duplicateOf urlRequest2: MPURLRequest?) -> Bool {
        // Check that the URLs are identical
        guard urlRequest1?.url?.absoluteString == urlRequest2?.url?.absoluteString else {
            return false
        }
        
        // Get httpBodys to compare
        guard let httpBody1 = urlRequest1?.httpBody, let httpBody2 = urlRequest2?.httpBody else {
            return false
        }
        
        // Get JSON objects
        guard let jsonObject1 = try? JSONSerialization.jsonObject(with: httpBody1, options: []), let jsonObject2 = try? JSONSerialization.jsonObject(with: httpBody2, options: []) else {
            return false
        }
        
        // Cast as [String: String] dictionaries for comparison of postData
        guard let dictionary1 = jsonObject1 as? [String: String], let dictionary2 = jsonObject2 as? [String: String] else {
            return false
        }

        // Determine if postData is equivalent
        return (dictionary1 == dictionary2)
    }
}
