/*   Copyright 2018-2023 Prebid.org, Inc.
 
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

class PrebidSDKInitializer {
    
    private static let serverStatusRequester = PrebidServerStatusRequester()
    
    static func initializeSDK(_ completion: PrebidInitializationCallback? = nil) {
        let _ = PrebidServerConnection.shared
        let _ = PBMLocationManager.shared
        let _ = UserConsentDataManager.shared
        
        PrebidJSLibraryManager.shared.downloadLibraries()
        
        serverStatusRequester.requestStatus { completion?($0, $1) }
    }
    
    // check for deprecated `GADMobileAds.sdkVersion`
    static func checkGMAVersion(gadObject: AnyObject?) {
        guard let gadObject = gadObject else {
            Log.error("GADMobileAds object is not provided.")
            return
        }
        
        guard gadObject.responds(to: NSSelectorFromString("sdkVersion")) else {
            Log.error("There is no sdkVersion property in GADMobileAds object.")
            return
        }
        
        guard let sdkVersion = gadObject.value(forKey: "sdkVersion") as? String else {
            return
        }
        
        Utils.shared.checkDeprecatedGMAVersion(sdkVersion)
    }
    
    // check for `GADGetStringFromVersionNumber(GADMobileAds.sharedInstance().versionNumber)`
    static func checkGMAVersion(gadVersion: String?) {
        guard let gadVersion = gadVersion else {
            Log.error("GADMobileAds version string is not provided.")
            return
        }
        
        Utils.shared.checkGMAVersion(gadVersion)
    }
    
    static func setCustomStatusEndpoint(_ endpoint: String?) {
        serverStatusRequester.setCustomStatusEndpoint(endpoint)
    }
}
