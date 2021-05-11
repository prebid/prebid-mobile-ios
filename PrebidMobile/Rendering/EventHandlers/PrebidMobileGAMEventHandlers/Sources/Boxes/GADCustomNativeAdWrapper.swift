//
//  GADCustomNativeAdWrapper.swift
//  PrebidMobileGAMEventHandlers
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import GoogleMobileAds

class GADCustomNativeAdWrapper {
    
    // MARK: - Private Properties
    
    public static var classesFound = GADCustomNativeAdWrapper.findClasses()
    
    // MARK: - Public Properties
    
    let customNativeAd: GADCustomNativeAd
    
    // MARK: - Public Methods
    
    init?(customNativeAd: GADCustomNativeAd) {
        if !Self.classesFound {
            GAMUtils.log(error: GAMEventHandlerError.gamClassesNotFound)
            return nil
        }
        
        self.customNativeAd = customNativeAd
    }
    
    // MARK: - Public Wrappers (Methods)

    public func string(forKey: String) -> String? {
        customNativeAd.string(forKey: forKey)
    }

    // MARK: - Private Methods
    
    static func findClasses() -> Bool {
        guard let _ = NSClassFromString("GADCustomNativeAd") else {
            return false;
        }
        
        let testClass = GADCustomNativeAd.self
        
        let selectors = [
            #selector(GADCustomNativeAd.string(forKey:)),
        ]
        
        for selector in selectors {
            if testClass.instancesRespond(to: selector) == false {
                return false
            }
        }
        
        return true
    }
}
