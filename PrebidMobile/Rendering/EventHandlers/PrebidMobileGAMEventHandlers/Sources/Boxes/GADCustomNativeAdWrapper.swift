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
