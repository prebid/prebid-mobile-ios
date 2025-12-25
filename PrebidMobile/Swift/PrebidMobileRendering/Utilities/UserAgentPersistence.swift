/*   Copyright 2018-2024 Prebid.org, Inc.
 
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
import UIKit

/**
 A protocol that defines the interface for user agent persistence.
 */
protocol UserAgentPersistence {
    /// The user agent string.
    var userAgent: String? { get set }
    
    /// Initializes a new instance of a class conforming to `UserAgentPersistence`.
    init(osVersion: String?)
}

/**
 A class that handles persistence of the user agent string in UserDefaults.
 */
class UserAgentDefaults: UserAgentPersistence {
    /// The key used to store the user agent dictionary in UserDefaults.
    private let key: String = "PBMUserAgentService_UserAgentStore"
    
    /// Get the current OS version.
    private let osVersion: String
    
    /**
     Get the contents of the user agent dictionary from UserDefaults.
     */
    var contents: [String: String]? {
        UserDefaults.standard.dictionary(forKey: key) as? [String: String]
    }
    
    /// Shadow variable to save processing by preventing the casting of UserDefaults to an array on all requests
    private lazy var _userAgent: String? = contents?[osVersion]
    
    /**
     Get and set the user agent for the current OS version in UserDefaults.
     */
    var userAgent: String? {
        get {
            return _userAgent
        }
        set {
            var userAgentDictionary: [String: String] = [:]
            userAgentDictionary[osVersion] = newValue
            // Overwrites any previous value in UserDefaults.
            UserDefaults.standard.set(userAgentDictionary, forKey: key)
            _userAgent = newValue
        }
    }

    /**
     Initializes a new instance of `UserAgentDefaults` with a specified OS version.
     
     - Parameter osVersion: The OS version to use for the user agent persistence.
     */
    required init(osVersion: String? = nil) {
        self.osVersion = osVersion ?? UIDevice.current.systemVersion
    }
    
    /**
     Resets the user agent defaults by removing the stored user agent dictionary from UserDefaults.
     */
    func reset() {
        _userAgent = nil
        UserDefaults.standard.removeObject(forKey: key)
    }
}
