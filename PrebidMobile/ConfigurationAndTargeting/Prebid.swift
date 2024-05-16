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

public typealias PrebidInitializationCallback = ((PrebidInitializationStatus, Error?) -> Void)

@objcMembers
public class Prebid: NSObject {
    
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
    
    public static let shared = Prebid()
    
    public var version: String {
        PBMFunctions.sdkVersion()
    }
    
    public var omsdkVersion: String {
        OMSDKVersionProvider.omSDKVersionString
    }
    
    // MARK: - Public Properties (Prebid)
    
    public var prebidServerHost: PrebidHost = .Custom {
        didSet {
            timeoutMillisDynamic = NSNumber(value: timeoutMillis)
            timeoutUpdated = false
        }
    }
    
    public var customStatusEndpoint: String? {
        didSet {
            PrebidSDKInitializer.setCustomStatusEndpoint(customStatusEndpoint)
        }
    }
    
    public var timeoutMillis: Int {
        didSet {
            timeoutMillisDynamic = NSNumber(value: timeoutMillis)
        }
    }
    
    public var timeoutMillisDynamic: NSNumber?
    
    public var storedAuctionResponse: String?
    
    // MARK: - Public Properties (SDK)

    //Indicates whether the PBS should cache the bid for the rendering API.
    //If the value is true the SDK will make the cache request in order to report
    //the impression event respectively to the legacy analytic setup.
    public var useCacheForReportingWithRenderingAPI = false
    
    //Controls how long each creative has to load before it is considered a failure.
    public var creativeFactoryTimeout: TimeInterval = 6.0
    
    //Controls how long video and interstitial creatives have to load before it is considered a failure.
    public var creativeFactoryTimeoutPreRenderContent: TimeInterval = 30.0
    
    //Controls whether to use PrebidMobile's in-app browser or the Safari App for displaying ad clickthrough content.
    public var useExternalClickthroughBrowser = false
    
    //Indicates the type of browser opened upon clicking the creative in an app, where embedded = 0, native = 1.
    //Describes an [OpenRTB](https://www.iab.com/wp-content/uploads/2016/03/OpenRTB-API-Specification-Version-2-5-FINAL.pdf) imp.clickbrowser attribute.
    public var impClickbrowserType: ClickbrowserType = .native
    
    //If set to true, the output of PrebidMobile's internal logger is written to a text file. This can be helpful for debugging. Defaults to false.
    public var debugLogFileEnabled: Bool {
        get { Log.logToFile }
        set { Log.logToFile = newValue }
    }
    
    //If true, the SDK will periodically try to listen for location updates in order to request location-based ads.
    public var locationUpdatesEnabled: Bool {
        get { PBMLocationManager.shared.locationUpdatesEnabled }
        set { PBMLocationManager.shared.locationUpdatesEnabled = newValue }
    }

    //If true, the sdk will add `includewinners` flag inside the targeting object described in [PBS Documentation](https://docs.prebid.org/prebid-server/endpoints/openrtb2/pbs-endpoint-auction.html#targeting)
    public var includeWinners = false

    //If true, the sdk will add `includebidderkeys` flag inside the targeting object described in [PBS Documentation](https://docs.prebid.org/prebid-server/endpoints/openrtb2/pbs-endpoint-auction.html#targeting)
    public var includeBidderKeys = false
    
    // MARK: - Public Methods
    
    public func setCustomPrebidServer(url: String) throws {
        prebidServerHost = .Custom
        try Host.shared.setCustomHostURL(url)
    }
    
    // MARK: - Stored Bid Response
    
    public func addStoredBidResponse(bidder: String, responseId: String) {
        storedBidResponses[bidder] = responseId
    }
    
    public func clearStoredBidResponses() {
        storedBidResponses.removeAll()
    }
    
    public func getStoredBidResponses() -> [[String: String]]? {
        var storedBidResponses: [[String: String]] = []
        
        for(bidder, responseId) in Prebid.shared.storedBidResponses {
            var storedBidResponse: [String: String] = [:]
            storedBidResponse["bidder"] = bidder
            storedBidResponse["id"] = responseId
            storedBidResponses.append(storedBidResponse)
        }
        return storedBidResponses.isEmpty ? nil : storedBidResponses
    }
    
    // MARK: - Custom Headers
    
    public func addCustomHeader(name: String, value: String) {
        customHeaders[name] = value
    }
    
    public func clearCustomHeaders() {
        customHeaders.removeAll()
    }
    
    /// Initializes PrebidMobile SDK.
    ///
    /// Checks the status of Prebid Server. The `customStatusEndpoint` property is used as server status endpoint.
    /// If `customStatusEndpoint` property is not provided, the SDK will use default endpoint - `host` + `/status`.
    /// The `host` value is obtained from `Prebid.shared.prebidServerHost`.
    ///
    /// Checks the version of GMA SDK. If the version is not supported - logs warning.
    ///
    /// Use this SDK initializer if you're using PrebidMobile with GMA SDK.
    /// - Parameters:
    ///   - gadMobileAdsObject: GADMobileAds object
    ///   - completion: returns initialization status and optional error
    public static func initializeSDK(_ gadMobileAdsObject: AnyObject? = nil, _ completion: PrebidInitializationCallback? = nil) {
        PrebidSDKInitializer.initializeSDK(completion)
        PrebidSDKInitializer.checkGMAVersion(gadObject: gadMobileAdsObject)
        PrebidSDKInitializer.logInitializerWarningIfNeeded()
    }
    
    /// Initializes PrebidMobile SDK.
    ///
    /// Checks the status of Prebid Server. The `customStatusEndpoint` property is used as server status endpoint.
    /// If `customStatusEndpoint` property is not provided, the SDK will use default endpoint - `host` + `/status`.
    /// The `host` value is obtained from `Prebid.shared.prebidServerHost`.
    ///
    /// Checks the version of GMA SDK. If the version is not supported - logs warning.
    ///
    /// Use this SDK initializer if you're using PrebidMobile with GMA SDK.
    /// - Parameters:
    ///   - gadMobileAdsVersion: GADMobileAds version string, use `GADGetStringFromVersionNumber(GADMobileAds.sharedInstance().versionNumber)` to get it
    ///   - completion: returns initialization status and optional error
    public static func initializeSDK(gadMobileAdsVersion: String? = nil, _ completion: PrebidInitializationCallback? = nil) {
        PrebidSDKInitializer.initializeSDK(completion)
        PrebidSDKInitializer.checkGMAVersion(gadVersion: gadMobileAdsVersion)
    }
    
    /// Initializes PrebidMobile SDK.
    ///
    /// Checks the status of Prebid Server. The `customStatusEndpoint` property is used as server status endpoint.
    /// If `customStatusEndpoint` property is not provided, the SDK will use default endpoint - `host` + `/status`.
    /// The `host` value is obtained from `Prebid.shared.prebidServerHost`.
    ///
    /// Use this SDK initializer if you're using PrebidMobile without GMA SDK.
    /// - Parameters:
    ///   - completion: returns initialization status and optional error
    public static func initializeSDK(_ completion: PrebidInitializationCallback? = nil) {
        PrebidSDKInitializer.initializeSDK(completion)
    }
    
    // MARK: - Private Methods
    
    override init() {
        timeoutMillis = defaultTimeoutMillis
    }
    
    public static func registerPluginRenderer(_ prebidMobilePluginRenderer: PrebidMobilePluginRenderer) {
        PrebidMobilePluginRegister.shared.registerPlugin(prebidMobilePluginRenderer);
    }
    
    public static func unregisterPluginRenderer(_ prebidMobilePluginRenderer: PrebidMobilePluginRenderer) {
        PrebidMobilePluginRegister.shared.unregisterPlugin(prebidMobilePluginRenderer);
    }
    
    public static func containsPluginRenderer(_ prebidMobilePluginRenderer: PrebidMobilePluginRenderer) {
        PrebidMobilePluginRegister.shared.containsPlugin(prebidMobilePluginRenderer);
    }
}
