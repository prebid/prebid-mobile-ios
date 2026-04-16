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
    
    private static var gamVersionChecker = PrebidGAMVersionChecker()
    
    static func initializeSDK(_ completion: PrebidInitializationCallback? = nil) {
        let _ = UserAgentService.shared
        let _ = PrebidServerConnection.shared
        let _ = LocationManager.shared
        let _ = UserConsentDataManager.shared
        
        PrebidJSLibraryManager.shared.downloadLibraries()
        
        Prebid.registerPluginRenderer(PrebidRenderer())

        serverStatusRequester.requestStatus { completion?($0, $1) }
    }
    
    // check for deprecated `MobileAds.sdkVersion`
    static func checkGMAVersion(gadObject: AnyObject?) {
        guard let gadObject = gadObject else {
            Log.error("GoogleMobileAds object is not provided.")
            return
        }
        
        guard gadObject.responds(to: NSSelectorFromString("sdkVersion")) else {
            if gadObject.responds(to: NSSelectorFromString("versionNumber")) {
                Log.error("Starting with GMA SDK 10.7.0, the 'sdkVersion' property has been removed. Please use Prebid.initializeSDK(serverURL:gadMobileAdsVersion:completion:) and pass the version string from GADMobileAds.sharedInstance().versionNumber")
            } else {
                Log.error("There is no sdkVersion property in GoogleMobileAds object.")
            }
            return
        }
        
        guard let sdkVersion = gadObject.value(forKey: "sdkVersion") as? String else {
            return
        }
        
        gamVersionChecker.checkGMAVersionDeprecated(sdkVersion)
    }
    
    // check for `GADGetStringFromVersionNumber(MobileAds.shared.versionNumber)`
    static func checkGMAVersion(gadVersion: String?) {
        guard let gadVersion = gadVersion else {
            Log.error("GADMobileAds version string is not provided.")
            return
        }
        
        gamVersionChecker.checkGMAVersion(gadVersion)
    }
    
    static func setCustomStatusEndpoint(_ endpoint: String?) {
        serverStatusRequester.setCustomStatusEndpoint(endpoint)
    }
    
    static func logInitializerWarningIfNeeded() {
        // GAM SDK version when `sdkVersion` property started being deprecated
        let gamVersion = (10, 7, 0)
        
        guard let currentGAMVersion = gamVersionChecker.currentGMAVersion else {
            Log.error("Current GMA SDK version has not been extracted yet.")
            return
        }
        
        if currentGAMVersion.0 >= gamVersion.0 || currentGAMVersion.1 >= gamVersion.1 || currentGAMVersion.2 >= gamVersion.2 {
            Log.warn("Please, use `initializeSDK(gadMobileAdsVersion:, _ completion:)` method in order to initialize Prebid SDK.")
        }
    }
}
