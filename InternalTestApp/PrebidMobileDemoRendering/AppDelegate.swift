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
import MoPubSDK
import GoogleMobileAds

import PrebidMobile
import PrebidMobileMoPubAdapters

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
    var clLocationManager:CLLocationManager!
    
    let consentHelper = IABConsentHelper()
	
	func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        
        let processArgumentsParser = ProcessArgumentsParser()
        
        consentHelper.eraseIrrelevantUserDefaults()
        processArgumentsParser.addOption("IABConsent_Settings", paramsCount: 1, fireOnce: true) { [consentHelper] params in
            consentHelper.parseAndApply(consentSettingsString: params[0])
        }

        //Set up SDK.
        PrebidRenderingConfig.initializeRenderingModule()
                
        // Set up MockServer
        processArgumentsParser.addOption("useMockServer", fireOnce: true) { params in
            AppConfiguration.shared.useMockServer = true
        }
        
        processArgumentsParser.addOption("EXTRA_NATIVE", paramsCount: 1, fireOnce: true) { params in
            if let nativeConfigData = params[0].data(using: .utf8),
               let nativeConfigObj = try? JSONSerialization.jsonObject(with: nativeConfigData, options: []) as? [String: Any],
               let nativeAdConfig = NativeAdConfiguration(json: nativeConfigObj)
            {
                // TODO: Add error alert(?)
                AppConfiguration.shared.nativeAdConfig = nativeAdConfig
            }
        }
        
        processArgumentsParser.addOption("AD_POSITION", paramsCount: 1, fireOnce: true) { params in
            if let adPositionInt = Int(params[0]), let adPosition = AdPosition(rawValue: adPositionInt) {
                AppConfiguration.shared.adPosition = adPosition
            }
        }
        
        processArgumentsParser.addOption("VIDEO_PLACEMENT_TYPE", paramsCount: 1, fireOnce: true) { params in
            if let placementTypeInt = Int(params[0]), let placementType = VideoPlacementType(rawValue: placementTypeInt) {
                AppConfiguration.shared.videoPlacementType = placementType
            }
        }
        
        processArgumentsParser.addOption("-keyUITests", fireOnce: true) { params in
            //Speed up UI tests by disabling animation
            UIView.setAnimationsEnabled(false)
            UIApplication.shared.keyWindow?.layer.speed = 200
        }
        
        processArgumentsParser.addOption("ADD_USER_DATA", paramsCount: 2) { params in
            PrebidRenderingTargeting.shared.addUserData(params[1], forKey: params[0])
        }
        processArgumentsParser.addOption("ADD_APP_CONTEXT", paramsCount: 2) { params in
            PrebidRenderingTargeting.shared.addContextData(params[1], forKey: params[0])
        }
        processArgumentsParser.addOption("BIDDER_ACCESS_CONTROL_LIST", acceptedParamsRange: (min: 1, max: nil)) { params in
            params.forEach(PrebidRenderingTargeting.shared.addBidder(toAccessControlList:))
        }
        processArgumentsParser.addOption("ADD_ADUNIT_CONTEXT", paramsCount: 2) { params in
            let appConfig = AppConfiguration.shared
            appConfig.adUnitContext = (appConfig.adUnitContext ?? []) + [(key: params[0], value: params[1])]
        }
        
        processArgumentsParser.parseProcessArguments(ProcessInfo.processInfo.arguments)
       
        // MoPub
        let mopubConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: "0cde6f47aa6842e49c8575492cf9ee3f")
        mopubConfig.loggingLevel = .info
        mopubConfig.additionalNetworks = [PrebidMoPubAdapterConfiguration.self]
        MoPub.sharedInstance().initializeSdk(with: mopubConfig, completion: GlobalVars.reactiveMoPubInitFlag.markSdkInitialized)

        // AdMob
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [kGADSimulatorID as! String]
        GADMobileAds.sharedInstance().start { (status) in
            //Registered so that DownloadHelper gets covered by this
            GlobalVars.reactiveGAMInitFlag.markSdkInitialized()
        };
        
        PrebidRenderingConfig.shared.logLevel = PBMLogLevel.info
        PrebidRenderingConfig.shared.debugLogFileEnabled = true
        
        // Ads may include Open Measurement scripts that sometime require additional time for loading.
        PrebidRenderingConfig.shared.creativeFactoryTimeout = 20;
        
        PrebidRenderingConfig.shared.locationUpdatesEnabled = false
        
		return true
	}
	
	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}
	
	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
}
