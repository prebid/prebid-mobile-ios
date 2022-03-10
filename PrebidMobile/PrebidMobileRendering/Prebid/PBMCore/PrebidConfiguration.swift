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
import OMSDK_Prebidorg

fileprivate let defaultTimeoutMillis = 2000

@objcMembers
public class PrebidConfiguration: NSObject {
  
    // MARK: - Public Properties (SDK)
    
    public static let bidderNameAppNexus = "appnexus"
    public static let bidderNameRubiconProject = "rubicon"
    
    public var timeoutUpdated: Bool = false
    
    public var prebidServerAccountId = ""
    
    public var pbsDebug = false

    public var customHeaders: [String: String] = [:]
    
    public var storedBidResponses: [String: String] = [:]
    
    /**
    * This property is set by the developer when he is willing to assign the assetID for Native ad.
    **/
    public var shouldAssignNativeAssetID : Bool = false
    
    /**
    * This property is set by the developer when he is willing to share the location for better ad targeting
    **/
    public var shareGeoLocation = false
    
    /**
     * Set the desidered verbosity of the logs
     */
    public var logLevel: LogLevel {
        get { Log.logLevel }
        set { Log.logLevel = newValue }
    }
    
    /**
     * Array  containing objects that hold External UserId parameters.
     */
    public var externalUserIdArray = [ExternalUserId]()
    
    public static let shared = PrebidConfiguration()
    
    public var version: String {
        PBMFunctions.sdkVersion()
    }
    
    public var omsdkVersion: String {
        OMIDPrebidorgSDK.versionString()
    }
    
    // MARK: - Public Properties (Prebid)
    
    public var prebidServerHost: PrebidHost = .Custom {
        didSet {
            bidRequestTimeoutDynamic = NSNumber(value: bidRequestTimeoutMillis)
            timeoutUpdated = false
        }
    }
    
    public var accountID: String
    
    public var bidRequestTimeoutMillis: Int {
        didSet {
            bidRequestTimeoutDynamic = NSNumber(value: bidRequestTimeoutMillis)
        }
    }
    public var bidRequestTimeoutDynamic: NSNumber?
    
    public var storedAuctionResponse: String?


    // MARK: - Public Properties (SDK)
    
    //Controls how long each creative has to load before it is considered a failure.
    public var creativeFactoryTimeout: TimeInterval = 6.0

    //If preRenderContent flag is set, controls how long the creative has to completely pre-render before it is considered a failure.
    //Useful for video interstitials.
    public var creativeFactoryTimeoutPreRenderContent: TimeInterval = 30.0

    //Controls whether to use PrebidMobile's in-app browser or the Safari App for displaying ad clickthrough content.
    public var useExternalClickthroughBrowser = false

    //If set to true, the output of PrebidMobile's internal logger is written to a text file. This can be helpful for debugging. Defaults to false.
    public var debugLogFileEnabled: Bool {
        get { PBMLog.shared.logToFile }
        set { PBMLog.shared.logToFile = newValue }
    }

    //If true, the SDK will periodically try to listen for location updates in order to request location-based ads.
    public var locationUpdatesEnabled: Bool {
        get { PBMLocationManager.shared.locationUpdatesEnabled }
        set { PBMLocationManager.shared.locationUpdatesEnabled = newValue }
    }
    
    // MARK: - Public Methods
    
    public func setCustomPrebidServer(url: String) throws {
        prebidServerHost = .Custom
        try Host.shared.setCustomHostURL(url)
    }
    
    // Objective C API for logLevel
    public func setLogLevel(_ logLevel: LogLevel_) {
        self.logLevel = logLevel.getPrimary()
    }
    
    // MARK: - Stored Bid Response
    
    public func addStoredBidResponse(bidder: String, responseId: String) {
        storedBidResponses[bidder] = responseId
    }
    
    public func clearStoredBidResponses() {
        storedBidResponses.removeAll()
    }
    
    // MARK: - Custom Headers
    
    public func addCustomHeader(name: String, value: String) {
        customHeaders[name] = value
    }

    public func clearCustomHeaders() {
        customHeaders.removeAll()
    }
    
    public static func initializeRenderingModule() {
        let _ = PBMServerConnection.shared
        let _ = PBMLocationManager.shared
        let _ = PBMUserConsentDataManager.shared
        PBMOpenMeasurementWrapper.shared.initializeJSLib(with: PBMFunctions.bundleForSDK())
        
        PBMLog.info("prebid-mobile-sdk \(PBMFunctions.sdkVersion()) Initialized")
    }
    
    // MARK: - Private Methods
    
    override init() {
        accountID  = ""
        
        bidRequestTimeoutMillis = defaultTimeoutMillis
    }
}
