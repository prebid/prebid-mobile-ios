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

fileprivate let defaultTimeoutMillis = 2000

public class PrebidRenderingConfig : NSObject {
    
    // MARK: - Public Properties (SDK)
    
    @objc static public let shared = PrebidRenderingConfig()
    
    @objc public var version: String {
        PBMFunctions.sdkVersion()
    }
    
    // MARK: - Public Properties (Prebid)
    
    @objc public var prebidServerHost: PrebidHost = .custom {
        didSet {
            bidRequestTimeoutDynamic = nil
        }
    }
    @objc public var accountID: String
    
    @objc public var bidRequestTimeoutMillis: Int
    @objc public var bidRequestTimeoutDynamic: NSNumber?


    // MARK: - Public Properties (SDK)
    
    //Controls how long each creative has to load before it is considered a failure.
    @objc public var creativeFactoryTimeout: TimeInterval = 6.0

    //If preRenderContent flag is set, controls how long the creative has to completely pre-render before it is considered a failure.
    //Useful for video interstitials.
    @objc public var creativeFactoryTimeoutPreRenderContent: TimeInterval = 30.0

    //Controls whether to use PrebidMobileRendering's in-app browser or the Safari App for displaying ad clickthrough content.
    @objc public var useExternalClickthroughBrowser = false

    //Controls the verbosity of PrebidMobileRendering's internal logger. Options are (from most to least noisy) .info, .warn, .error and .none. Defaults to .info.
    @objc public var logLevel: PBMLogLevel {
        get { PBMLog.shared.logLevel }
        set { PBMLog.shared.logLevel = newValue }
    }

    //If set to true, the output of PrebidMobileRendering's internal logger is written to a text file. This can be helpful for debugging. Defaults to false.
    @objc public var debugLogFileEnabled: Bool {
        get { PBMLog.shared.logToFile }
        set { PBMLog.shared.logToFile = newValue }
    }

    //If true, the SDK will periodically try to listen for location updates in order to request location-based ads.
    @objc public var locationUpdatesEnabled: Bool {
        get { PBMLocationManager.shared.locationUpdatesEnabled }
        set { PBMLocationManager.shared.locationUpdatesEnabled = newValue }
    }
    
    // MARK: - Public Methods
    
    @objc public func setCustomPrebidServer(url: String) throws {
        guard let customHostURL = URL(string: url) else {
            throw PBMError.prebidServerURLInvalid(url)
        }
        
        prebidServerHost = .custom
        Host.shared.setCustomHostURL(customHostURL)
    }
    
    @objc public static func initializeRenderingModule() {
        let _ = PBMServerConnection.shared
        let _ = PBMLocationManager.shared
        let _ = PBMUserConsentDataManager.shared
        PBMOpenMeasurementWrapper.shared.initializeJSLib(with: PBMFunctions.bundleForSDK())
        
        PBMLog.info("prebid-mobile-sdk-rendering \(PBMFunctions.sdkVersion()) Initialized")
    }
    
    // MARK: - Private Methods
    
    override init() {
        accountID  = ""
        
        bidRequestTimeoutMillis = defaultTimeoutMillis
    }
}
