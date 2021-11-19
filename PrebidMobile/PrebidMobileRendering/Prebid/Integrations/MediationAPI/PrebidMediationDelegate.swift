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

// This protocol is dedicated to manage the work with Mediation SDKs.
@objc
public protocol PrebidMediationDelegate {
    /**
     Checks that a passed object is correct in the context of Mediation SDK.
     @return YES if the passed object is correct, FALSE otherwise
     */
    func isCorrectAdObject(_ adObject: NSObject) -> Bool
    /**
     Removes an bid info from ad object's localExtra
     and prebid-specific keywords from ad object's keywords
     */
    func cleanUpAdObject(_ adObject: NSObject)
    /**
     Puts to ad object's localExtra the ad object (winning bid or native ad) and configId
     and populates adObject's keywords by targeting info
     @return YES on success and NO otherwise (when the passed ad has wrong type)
     */
    func setUpAdObject(_ adObject: NSObject,
                       configID: String,
                       targetingInfo: [String : String],
                       extraObject: Any?,
                       forKey:String) -> Bool
}
