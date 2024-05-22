/*   Copyright 2019-2022 Prebid.org, Inc.
 
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

import UIKit

import GoogleMobileAds
import AppLovinSDK

import PrebidMobile
import PrebidMobileGAMEventHandlers
import PrebidMobileAdMobAdapters
import PrebidMobileMAXAdapters

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // ===== INIT: Prebid
        if CommandLine.arguments.contains("-uiTesting") {
            UIApplication.shared.getKeyWindow()?.layer.speed = 2
            UIView.setAnimationsEnabled(false)
        }
        // Set account id and custom Prebid server URL
        Prebid.shared.prebidServerAccountId = "0689a263-318d-448b-a3d4-b02e8a709d9d"
        try! Prebid.shared.setCustomPrebidServer(url: "https://prebid-server-test-j.prebid.org/openrtb2/auction")
        
        // Initialize Prebid SDK
        Prebid.initializeSDK(gadMobileAdsVersion: GADGetStringFromVersionNumber(GADMobileAds.sharedInstance().versionNumber)) { status, error in
            if let error = error {
                print("Initialization Error: \(error.localizedDescription)")
                return
            }
        }
        
        // ===== CONFIGURE: Prebid
        
        Targeting.shared.sourceapp = "PrebidDemoSwift"
        
        // ===== INIT: Ad Server SDK
        
        // Initialize GoogleMobileAds SDK
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers =  [ GADSimulatorID, "fa7ff8af558fb08a04c94453647e54a1"]
        GADMobileAds.sharedInstance().start()

        AdMobUtils.initializeGAD()
        GAMUtils.shared.initializeGAM()
        
        // Initialize AppLovin MAX SDK
        ALSdk.shared().mediationProvider = ALMediationProviderMAX
        ALSdk.shared().userIdentifier = "USER_ID"
        ALSdk.shared().initializeSdk()
        
        
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}

