//
//  GAMRequestWrapper.swift
//  PrebidMobileGAMEventHandlers
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import GoogleMobileAds

class GAMRequestWrapper {
    
    // MARK: Private Properties
        
    private static let classesFound = GAMRequestWrapper.findClasses()
    
    // MARK: - Public Properties
    
    let request: GAMRequest
    
    // MARK: - Public Methods
    
    init?() {
        if !GAMRequestWrapper.classesFound {
            GAMUtils.log(error: GAMEventHandlerError.gamClassesNotFound)
            return nil
        }
        
        request = GAMRequest()
    }
    
    init?(request: GAMRequest) {
        if !Self.classesFound {
            GAMUtils.log(error: GAMEventHandlerError.gamClassesNotFound)
            return nil
        }
        
        self.request = request
    }
    
    // MARK: - Public Wrappers (Properties)

    var customTargeting: [String : String]? {
        get { request.customTargeting }
        set { request.customTargeting = newValue }
    }
 
    // MARK: - Private Methods
    
    static func findClasses() -> Bool {
        guard let _ = NSClassFromString("GAMRequest") else {
            return false;
        }
        
        let testClass = GAMRequest.self
        
        let selectors = [
            #selector(getter: GAMRequest.customTargeting),
            #selector(setter: GAMRequest.customTargeting),
        ]
        
        for selector in selectors {
            if testClass.instancesRespond(to: selector) == false {
                return false
            }
        }
        
        return true
    }
}
