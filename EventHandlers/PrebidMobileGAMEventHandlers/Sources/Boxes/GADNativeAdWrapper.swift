/*   Copyright 2018-2021 Prebid.org, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation
import GoogleMobileAds

class GADNativeAdWrapper {
    
    // MARK: - Private Properties
    
    public static var classesFound = GADNativeAdWrapper.findClasses()

    // MARK: - Public Properties
    
    let nativeAd: GoogleMobileAds.NativeAd
           
    // MARK: - Public Wrappers (Properties)

    public var headline: String? {
        nativeAd.headline
    }
    
    public var callToAction: String? {
        nativeAd.callToAction
    }
    
    public var body: String? {
        nativeAd.body
    }
    
    public var starRating: NSDecimalNumber? {
        nativeAd.starRating
    }
    
    public var store: String? {
        nativeAd.store
    }
    
    public var price: String? {
        nativeAd.price
    }
    
    public var advertiser: String? {
        nativeAd.advertiser
    }
    
    // MARK: - Public Wrappers (Methods)

    init?(nativeAd: GoogleMobileAds.NativeAd) {
        if !Self.classesFound {
            GAMUtils.log(error: GAMEventHandlerError.gamClassesNotFound)
            return nil
        }
        
        self.nativeAd = nativeAd
    }

    // MARK: - Private Methods
    
    static func findClasses() -> Bool {
        guard let _ = NSClassFromString("GADNativeAd") else {
            return false
        }
        
        let testClass = GoogleMobileAds.NativeAd.self
        
        let selectors = [
            #selector(getter: GoogleMobileAds.NativeAd.headline),
            #selector(getter: GoogleMobileAds.NativeAd.callToAction),
            #selector(getter: GoogleMobileAds.NativeAd.body),
            #selector(getter: GoogleMobileAds.NativeAd.starRating),
            #selector(getter: GoogleMobileAds.NativeAd.store),
            #selector(getter: GoogleMobileAds.NativeAd.price),
            #selector(getter: GoogleMobileAds.NativeAd.advertiser)
        ]
        
        for selector in selectors {
            if testClass.instancesRespond(to: selector) == false {
                return false
            }
        }
        
        return true
    }
}
