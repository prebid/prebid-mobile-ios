/*   Copyright 2018-2019 Prebid.org, Inc.
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
import ObjectiveC.runtime

/// Base class for ad units built for original type of integration.
@objcMembers
public class AdUnit: NSObject, DispatcherDelegate {
    
    /// ORTB: imp[].ext.data.adslot
    public var pbAdSlot: String? {
        get { adUnitConfig.getPbAdSlot()}
        set { adUnitConfig.setPbAdSlot(newValue) }
    }
    
    /// The position of the ad on the screen.
    public var adPosition: AdPosition {
        get { adUnitConfig.adPosition }
        set { adUnitConfig.adPosition = newValue }
    }
    
    var adSizes: [CGSize] {
        get { [adUnitConfig.adSize] + (adUnitConfig.additionalSizes ?? []) }
    }
    
    private static let PB_MIN_RefreshTime = 30000.0
    
    private(set) var dispatcher: Dispatcher?
    
    private(set) var adUnitConfig: AdUnitConfig
    
    private var bidRequester: PBMBidRequesterProtocol
    
    /// This flag is set to check if the refresh needs to be made though the user has not invoked the fetch demand after initialization
    private var isInitialFetchDemandCallMade = false
    
    private var adServerObject: AnyObject?
    private var lastFetchDemandCompletion: ((_ bidInfo: BidInfo) -> Void)?
    
    /// notification flag set to check if the prebid response is received within the specified time
    private var didReceiveResponse = false
    
    /// notification flag set to determine if delegate call needs to be made after timeout delegate is sent
    private var timeOutSignalSent = false
    
    
    /// Initializes a new `AdUnit` instance with the specified configuration ID, size, and ad formats.
    ///
    /// - Parameters:
    ///   - configId: The configuration ID for the ad unit.
    ///   - size: The primary size of the ad. If `nil`, a default size of `.zero` is used.
    ///   - adFormats: A set of ad formats supported by the ad unit.
    public init(configId: String, size: CGSize?, adFormats: Set<AdFormat>) {
        adUnitConfig = AdUnitConfig(configId: configId, size: size ?? CGSize.zero)
        adUnitConfig.adConfiguration.isOriginalAPI = true
        adUnitConfig.adFormats = adFormats
        
        bidRequester = PBMBidRequester(connection: PrebidServerConnection.shared, sdkConfiguration: Prebid.shared,
                                       targeting: Targeting.shared, adUnitConfiguration: adUnitConfig)
        
        super.init()
        
        // PBS should cache the bid for original api.
        Prebid.shared.useCacheForReportingWithRenderingAPI = true
    }
    
    // Internal only!
    convenience init(bidRequester: PBMBidRequesterProtocol, configId: String, size: CGSize?, adFormats: Set<AdFormat>) {
        self.init(configId: configId, size: size, adFormats: adFormats)
        self.bidRequester = bidRequester
    }
    
    deinit {
        dispatcher?.invalidate()
    }
    
    //TODO: dynamic is used by tests
    
    /// Makes bid request and provides the result as a dictionary of key-value pairs.
    ///
    /// - Parameter completion: A closure called with the result code and an optional dictionary of targeting keywords.
    ///   - result: The result code indicating the outcome of the demand fetch.
    ///   - kvResultDict: A dictionary containing key-value pairs, or `nil` if no demand was fetched.
    @available(*, deprecated, message: "Deprecated. Use fetchDemand(completion: @escaping (_ bidInfo: BidInfo) -> Void) instead.")
    dynamic public func fetchDemand(completion: @escaping(_ result: ResultCode, _ kvResultDict: [String : String]?) -> Void) {
        let dictContainer = DictionaryContainer<String, String>()
        
        fetchDemand(adObject: dictContainer) { resultCode in
            let dict = dictContainer.dict
            
            DispatchQueue.main.async {
                completion(resultCode, dict.count > 0 ? dict : nil)
            }
        }
    }
    
    /// Makes bid request  and provides the result as a `BidInfo` object.
    ///
    /// - Parameter completionBidInfo: A closure called with a `BidInfo` object representing the fetched demand.
    dynamic public func fetchDemand(completionBidInfo: @escaping (_ bidInfo: BidInfo) -> Void) {
        baseFetchDemand(completion: completionBidInfo)
    }
    
    /// Makes bid request for a specific ad object and provides the result code. Setups targeting keywords into the adObject.
    ///
    /// - Parameters:
    ///   - adObject: The ad object for which demand is being fetched.
    ///   - completion: A closure called with the result code indicating the outcome of the demand fetch.
    dynamic public func fetchDemand(adObject: AnyObject, completion: @escaping(_ result: ResultCode) -> Void) {
        baseFetchDemand(adObject: adObject) { bidInfo in
            DispatchQueue.main.async {
                completion(bidInfo.resultCode)
            }
        }
    }
    
    // SDK internal
    func baseFetchDemand(adObject: AnyObject? = nil, completion: @escaping (_ bidInfo: BidInfo) -> Void) {
        if !(self is NativeRequest) {
            if adSizes.contains(where: { $0.width < 0 || $0.height < 0 }) {
                completion(BidInfo(resultCode: .prebidInvalidSize))
                return
            }
        }
        
        if let adObject {
            Utils.shared.removeHBKeywords(adObject: adObject)
        }
        
        if adUnitConfig.configId.isEmpty || adUnitConfig.configId.containsOnly(.whitespaces) {
            completion(BidInfo(resultCode: .prebidInvalidConfigId))
            return
        }
        
        if Prebid.shared.prebidServerAccountId.isEmpty || Prebid.shared.prebidServerAccountId.containsOnly(.whitespaces) {
            completion(BidInfo(resultCode: .prebidInvalidAccountId))
            return
        }
        
        if !isInitialFetchDemandCallMade {
            isInitialFetchDemandCallMade = true
            startDispatcher()
        }
        
        didReceiveResponse = false
        timeOutSignalSent = false
        lastFetchDemandCompletion = completion
        adServerObject = adObject
        
        
        let timeoutHandler = DispatchWorkItem {
            if (!self.didReceiveResponse) {
                self.timeOutSignalSent = true
                completion(BidInfo(resultCode: .prebidDemandTimedOut))
                return
            }
        }
        
        bidRequester.requestBids { [weak self] bidResponse, error in
            timeoutHandler.cancel()

            guard let self = self else { return }
            self.didReceiveResponse = true
            
            guard let bidResponse = bidResponse else {
                if (!self.timeOutSignalSent) {
                    completion(BidInfo(resultCode: PBMError.demandResult(from: error)))
                }
                
                return
            }
            
            if (!self.timeOutSignalSent) {
                let resultCode = self.setUp(adObject, with: bidResponse)
                let bidInfo = BidInfo.create(resultCode: resultCode, bidResponse: bidResponse)
                completion(bidInfo)
            }
        }
        
        let timeout = Int(truncating: Prebid.shared.timeoutMillisDynamic ?? NSNumber(value: .PB_Request_Timeout))
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(timeout), execute: timeoutHandler)
    }
    
    func setUp(_ adObject: AnyObject?, with bidResponse: BidResponse) -> ResultCode {
        
        if Targeting.shared.forceSdkToChooseWinner {
            Log.error("Breaking change: set Targeting.forceSdkToChooseWinner = false and test your behavior. In the upcoming major release, the SDK will send all targeting keywords to the AdSever, so you should prepare your setup.")
        }

        guard let winningBid = bidResponse.winningBid else {
            
            //When the new behavior is active
            if !Targeting.shared.forceSdkToChooseWinner {
                
                if let adObject {
                    Utils.shared.validateAndAttachKeywords(adObject: adObject, bidResponse: bidResponse)
                }
                //If there are no winning bids, but there are bids the SDK will send back prebidDemandFetchSuccess
                if let bids = bidResponse.allBids, !bids.isEmpty {
                    return .prebidDemandFetchSuccess
                }
            }
            return .prebidDemandNoBids
        }

        if let cacheId = cacheBidIfNeeded(winningBid) {
            bidResponse.addTargetingInfoValue(key: PrebidLocalCacheIdKey, value: cacheId)
        }
        
        if let adObject {
            Utils.shared.validateAndAttachKeywords(adObject: adObject, bidResponse: bidResponse)
        }
        
        return .prebidDemandFetchSuccess
    }
    
    private func cacheBidIfNeeded(_ winningBid: Bid) -> String?  {
        guard winningBid.adFormat == .native else {
            return nil
        }
        
        let expireInterval = TimeInterval(truncating: winningBid.bid.exp ?? CacheManager.cacheManagerExpireInterval as NSNumber)
        
        do {
            if let cacheId = CacheManager.shared.save(content: try winningBid.bid.toJsonString(), expireInterval: expireInterval), !cacheId.isEmpty {
                return cacheId
            }
        } catch {
            Log.error("Error saving bid content to cache: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    // MARK: - adunit ext data aka inventory data (imp[].ext.data)
    

    /// This method obtains the context data keyword & value for adunit context targeting
    /// If the key already exists the value will be appended to the list. No duplicates will be added
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtData method instead.")
    public func addContextData(key: String, value: String) {
        addExtData(key: key, value: value)
    }

    /// This method obtains the context data keyword & values for adunit context targeting
    /// The values if the key already exist will be replaced with the new set of values
    @available(*, deprecated, message: "This method is deprecated. Please, use updateExtData method instead.")
    public func updateContextData(key: String, value: Set<String>) {
        updateExtData(key: key, value: value)
    }
    
    /// This method allows to remove specific context data keyword & values set from adunit context targeting
    @available(*, deprecated, message: "This method is deprecated. Please, use removeExtData method instead.")
    public func removeContextData(forKey: String) {
        removeExtData(forKey: forKey)
    }
    
    /// This method allows to remove all context data set from adunit context targeting
    @available(*, deprecated, message: "This method is deprecated. Please, use clearExtData method instead.")
    public func clearContextData() {
        clearExtData()
    }
    
    // Used for tests
    func getExtDataDictionary() -> [String: [String]] {
        return adUnitConfig.getExtData()
    }
    
    /// This method obtains the ext data keyword & value for adunit targeting.
    /// If the key already exists the value will be appended to the list. No duplicates will be added
    public func addExtData(key: String, value: String) {
        adUnitConfig.addExtData(key: key, value: value)
    }
    
    /// This method obtains the ext data keyword & values for adunit targeting
    /// The values if the key already exist will be replaced with the new set of values
    public func updateExtData(key: String, value: Set<String>) {
        adUnitConfig.updateExtData(key: key, value: value)
    }
    
    /// This method allows to remove specific ext data keyword & values set from adunit targeting
    public func removeExtData(forKey: String) {
        adUnitConfig.removeExtData(for: forKey)
    }
    
    /// This method allows to remove all ext data set from adunit targeting
    public func clearExtData() {
        adUnitConfig.clearExtData()
    }
    
    // MARK: - adunit ext keywords (imp[].ext.keywords)
    
    /// This method obtains the context keyword for adunit context targeting
    /// Inserts the given element in the set if it is not already present.
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtKeyword method instead.")
    public func addContextKeyword(_ newElement: String) {
        addExtKeyword(newElement)
    }
    
    /// This method obtains the context keyword set for adunit context targeting
    /// Adds the elements of the given set to the set.
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtKeywords method instead.")
    public func addContextKeywords(_ newElements: Set<String>) {
        addExtKeywords(newElements)
    }
    
    /// This method allows to remove specific context keyword from adunit context targeting
    @available(*, deprecated, message: "This method is deprecated. Please, use removeExtKeyword method instead.")
    public func removeContextKeyword(_ element: String) {
        removeExtKeyword(element)
    }
    
    /// This method allows to remove all keywords from the set of adunit context targeting
    @available(*, deprecated, message: "This method is deprecated. Please, use clearExtKeywords method instead.")
    public func clearContextKeywords() {
        clearExtKeywords()
    }

    /// This method obtains the keyword for adunit targeting
    /// Inserts the given element in the set if it is not already present.
    public func addExtKeyword(_ newElement: String) {
        adUnitConfig.addExtKeyword(newElement)
    }
    
    /// This method obtains the keyword set for adunit targeting
    /// Adds the elements of the given set to the set.
    public func addExtKeywords(_ newElements: Set<String>) {
        adUnitConfig.addExtKeywords(newElements)
    }
    
    /// This method allows to remove specific keyword from adunit targeting
    public func removeExtKeyword(_ element: String) {
        adUnitConfig.removeExtKeyword(element)
    }
    
    /// This method allows to remove all keywords from the set of adunit targeting
    public func clearExtKeywords() {
        adUnitConfig.clearExtKeywords()
    }
    
    // Used for tests
    func getExtKeywordsSet() -> Set<String> {
        adUnitConfig.getExtKeywords()
    }
    
    // MARK: - App Content (app.content.data)
    
    /// Sets the app content object, replacing any existing content.
    ///
    /// - Parameter appContentObject: The `PBMORTBAppContent` object representing the app's content.
    public func setAppContent(_ appContentObject: PBMORTBAppContent) {
        adUnitConfig.setAppContent(appContentObject)
    }
    
    /// Retrieves the current app content object.
    ///
    /// - Returns: The current `PBMORTBAppContent` object, or `nil` if no content is set.
    public func getAppContent() -> PBMORTBAppContent? {
        return adUnitConfig.getAppContent()
    }
    
    /// Clears the current app content object.
    public func clearAppContent() {
        adUnitConfig.clearAppContent()
    }
    
    /// Adds an array of content data objects to the app content.
    ///
    /// - Parameter dataObjects: An array of `PBMORTBContentData` objects to add.
    public func addAppContentData(_ dataObjects: [PBMORTBContentData]) {
        adUnitConfig.addAppContentData(dataObjects)
    }
    
    /// Removes a specific content data object from the app content.
    ///
    /// - Parameter dataObject: The `PBMORTBContentData` object to remove.
    public func removeAppContentData(_ dataObject: PBMORTBContentData) {
        adUnitConfig.removeAppContentData(dataObject)
    }
    
    /// Clears all content data objects from the app content.
    public func clearAppContentData() {
        adUnitConfig.clearAppContentData()
    }
    
    // MARK: - User Data (user.data)
    
    /// Retrieves the current user data.
    ///
    /// - Returns: An array of `PBMORTBContentData` objects representing the user data, or `nil` if no data is available.
    public func getUserData() -> [PBMORTBContentData]? {
        return adUnitConfig.getUserData()
    }
    
    /// Adds an array of user data objects.
    ///
    /// - Parameter userDataObjects: An array of `PBMORTBContentData` objects to add to the user data.
    public func addUserData(_ userDataObjects: [PBMORTBContentData]) {
        adUnitConfig.addUserData(userDataObjects)
    }
    
    /// Removes a specific user data object.
    ///
    /// - Parameter userDataObject: The `PBMORTBContentData` object to remove from the user data.
    public func removeUserData(_ userDataObject: PBMORTBContentData) {
        adUnitConfig.removeUserData(userDataObject)
    }
    
    /// Clears all user data.
    public func clearUserData() {
        adUnitConfig.clearUserData()
    }
    
    // MARK: GPID
    
    /// Sets the GPID for the ad unit.
    ///
    /// - Parameter gpid: The GPID string to set. Can be `nil` to clear the GPID.
    public func setGPID(_ gpid: String?) {
        adUnitConfig.gpid = gpid
    }
    
    /// Retrieves the current GPID for the ad unit.
    ///
    /// - Returns: The GPID string, or `nil` if no GPID is set.
    public func getGPID() -> String? {
        return adUnitConfig.gpid
    }
    
    // MARK: Arbitrary ORTB Configuration
    
    @available(*, deprecated, message: "Deprecated. Use setImpORTBConfig(_:) for impression-level ORTB configuration.")
    public func setOrtbConfig(_ ortbObject: String?) {
        adUnitConfig.ortbConfig = ortbObject
    }
    
    @available(*, deprecated, message: "Deprecated. Use getImpORTBConfig() for impression-level ORTB configuration.")
    public func getOrtbConfig() -> String? {
        return adUnitConfig.ortbConfig
    }
    
    /// Sets the impression-level OpenRTB configuration string for the ad unit.
    ///
    /// - Parameter ortbObject: The impression-level OpenRTB configuration string to set. Can be `nil` to clear the configuration.
    public func setImpORTBConfig(_ ortbConfig: String?) {
        adUnitConfig.impORTBConfig = ortbConfig
    }
    
    /// Returns the impression-level OpenRTB configuration string.
    public func getImpORTBConfig() -> String? {
        adUnitConfig.impORTBConfig
    }
    
    // MARK: - Others
    
    
     /// This method allows to set the auto refresh period for the demand
     /// - Parameter time: refresh time interval
    public func setAutoRefreshMillis(time: Double) {
        
        guard checkRefreshTime(time) else {
            Log.error("auto refresh not set as the refresh time is less than to \(AdUnit.PB_MIN_RefreshTime as Double) seconds")
            return
        }
        
        if dispatcher?.state == .stopped {
            dispatcher?.setAutoRefreshMillis(time: time)
            return
        }
        
        stopDispatcher()
        
        initDispatcher(refreshTime: time)
        
        if isInitialFetchDemandCallMade {
            startDispatcher()
        }
    }
    
    /// This method stops the auto refresh of demand
    public func stopAutoRefresh() {
        stopDispatcher()
    }
    
    /// This method resumes the auto refresh of demand
    public func resumeAutoRefresh() {
        if dispatcher?.state == .stopped {
            if isInitialFetchDemandCallMade {
                startDispatcher()
            }
        }
    }
    
    dynamic func checkRefreshTime(_ time: Double) -> Bool {
        return time >= AdUnit.PB_MIN_RefreshTime
    }
    
    func refreshDemand() {
        if let lastFetchDemandCompletion = lastFetchDemandCompletion {
            baseFetchDemand(adObject: adServerObject, completion: lastFetchDemandCompletion)
        }
    }
    
    func initDispatcher(refreshTime: Double) {
        dispatcher = Dispatcher.init(withDelegate: self, autoRefreshMillies: refreshTime)
    }
    
    func startDispatcher() {
        guard let dispatcher = self.dispatcher else {
            Log.verbose("Dispatcher is nil")
            return
        }
        
        dispatcher.start()
    }
    
    func stopDispatcher() {
        guard let dispatcher = self.dispatcher else {
            Log.verbose("Dispatcher is nil")
            return
        }
        
        dispatcher.stop()
    }
}
