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

import UIKit
import CoreLocation
import GoogleMobileAds
import AppLovinSDK

import PrebidMobile
import PrebidMobileAdMobAdapters
import PrebidMobileGAMEventHandlers
import PrebidMobileMAXAdapters

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
	
    private(set) var isUITesting = false
    var clLocationManager:CLLocationManager!
    
    let consentHelper = IABConsentHelper()
	
	func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let processArgumentsParser = ProcessArgumentsParser()
        
        consentHelper.eraseIrrelevantUserDefaults()
        processArgumentsParser.addOption("IABConsent_Settings", paramsCount: 1, fireOnce: true) { [consentHelper] params in
            consentHelper.parseAndApply(consentSettingsString: params[0])
        }
        
        Prebid.shared.shouldDisableStatusCheck = true
                
        //Set up SDK.
        let swiftVersionString = string(for: MobileAds.shared.versionNumber)

        try? Prebid.initializeSDK(serverURL: "https://prebid-server-test-j.prebid.org/openrtb2/auction", gadMobileAdsVersion: swiftVersionString) { status, error in
            switch status {
            case .succeeded:
                print("Prebid successfully initialized")
            case .failed:
                if let error = error {
                    print("An error occurred during Prebid initialization: \(error.localizedDescription)")
                }
            case .serverStatusWarning:
                if let error = error {
                    print("Prebid Server status checking failed: \(error.localizedDescription)")
                }
            case .serverStatusSkipped:
                print("Prebid status check skipped")

            default:
                break
            }            
        }
        
        processArgumentsParser.addOption("AD_POSITION", paramsCount: 1, fireOnce: true) { params in
            if let adPositionInt = Int(params[0]), let adPosition = AdPosition(rawValue: adPositionInt) {
                AppConfiguration.shared.adPosition = adPosition
            }
        }
    
        processArgumentsParser.addOption("VIDEO_PLACEMENT_TYPE", paramsCount: 1, fireOnce: true) { params in
            if let placementTypeInt = Int(params[0]), let placementType = Signals.Placement.getPlacementByRawValue(placementTypeInt) {
                AppConfiguration.shared.videoPlacementType = placementType
            }
        }
        
        processArgumentsParser.addOption("-keyUITests", fireOnce: true) { params in
            //Speed up UI tests by disabling animation
            UIView.setAnimationsEnabled(false)
            self.isUITesting = true
        }
        
        processArgumentsParser.addOption("BIDDER_ACCESS_CONTROL_LIST", acceptedParamsRange: (min: 1, max: nil)) { params in
            params.forEach(Targeting.shared.addBidderToAccessControlList(_:))
        }
        
        processArgumentsParser.addOption("ADD_ADUNIT_CONTEXT", paramsCount: 2) { params in
            let appConfig = AppConfiguration.shared
            appConfig.adUnitContext = (appConfig.adUnitContext ?? []) + [(key: params[0], value: params[1])]
        }
        
        processArgumentsParser.addOption("ADD_ADUNIT_KEYWORD", paramsCount: 1) { params in
            let appConfig = AppConfiguration.shared
            appConfig.adUnitContextKeywords.append(params[0])
        }
        
        processArgumentsParser.addOption("ADD_USER_DATA_EXT", paramsCount: 2) { params in
            let appConfig = AppConfiguration.shared
            appConfig.userData = (appConfig.userData ?? []) + [(key: params[0], value: params[1])]
        }
        
        processArgumentsParser.addOption("ADD_USER_KEYWORD", paramsCount: 1) { params in
            Targeting.shared.addUserKeyword(params[0])
        }
        
        processArgumentsParser.addOption("ADD_APP_CONTENT_DATA_EXT", paramsCount: 2) { params in
            let appConfig = AppConfiguration.shared
            appConfig.appContentData = (appConfig.appContentData ?? []) + [(key: params[0], value: params[1])]
        }
        
        processArgumentsParser.addOption("GPP_HDR_STRING", paramsCount: 1) { params in
            UserDefaults.standard.set(params.first, forKey: "IABGPP_HDR_GppString")
        }
        
        processArgumentsParser.addOption("GPP_SID", paramsCount: 1) { params in
            UserDefaults.standard.set(params.first, forKey: "IABGPP_GppSID")
        }
        
        processArgumentsParser.parseProcessArguments(ProcessInfo.processInfo.arguments)
       
        // AdMob
        MobileAds.shared.start { (status) in
            //Registered so that DownloadHelper gets covered by this
            GlobalVars.reactiveGAMInitFlag.markSdkInitialized()
        }
        
        GAMUtils.shared.initializeGAM()
        
        AdMobUtils.initializeGAD()
        
        let config = ALSdkInitializationConfiguration(
            sdkKey: "1tLUnP4cVQqpHuHH2yMtfdESvvUhTB05NdbCoDTceDDNVnhd_T8kwIzXDN9iwbdULTboByF-TtNaiTmsoVbxZw"
        )
        
        ALSdk.shared().initialize(with: config)
        
        // Prebid Rendering Configs
        Prebid.shared.logLevel = .info
        Prebid.shared.debugLogFileEnabled = true
        
        // Ads may include Open Measurement scripts that sometime require additional time for loading.
        Prebid.shared.creativeFactoryTimeout = 20;
        
        Prebid.shared.locationUpdatesEnabled = false
        
        // Original Prebid Configs
        Prebid.shared.shareGeoLocation = true
        
		return true
	}
	
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
