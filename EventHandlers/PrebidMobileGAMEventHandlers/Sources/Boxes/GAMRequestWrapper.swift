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
