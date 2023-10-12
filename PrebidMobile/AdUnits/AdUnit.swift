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

@objcMembers
public class AdUnit: NSObject, DispatcherDelegate {
    
    public var pbAdSlot: String? {
        get { adUnitConfig.getPbAdSlot()}
        set { adUnitConfig.setPbAdSlot(newValue) }
    }
    
    var adSizes: [CGSize] {
        get { [adUnitConfig.adSize] + (adUnitConfig.additionalSizes ?? []) }
    }
    
    private static let PB_MIN_RefreshTime = 30000.0
    
    private(set) var dispatcher: Dispatcher?
    
    private(set) var adUnitConfig: AdUnitConfig
    
    private var bidRequester: PBMBidRequesterProtocol
    
    //This flag is set to check if the refresh needs to be made though the user has not invoked the fetch demand after initialization
    private var isInitialFetchDemandCallMade = false
    
    private var adServerObject: AnyObject?
    private var lastFetchDemandCompletion: ((_ bidInfo: BidInfo) -> Void)?
    
    //notification flag set to check if the prebid response is received within the specified time
    private var didReceiveResponse = false
    
    //notification flag set to determine if delegate call needs to be made after timeout delegate is sent
    private var timeOutSignalSent = false
    
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
    
    dynamic public func fetchDemand(completionBidInfo: @escaping (_ bidInfo: BidInfo) -> Void) {
        baseFetchDemand(completion: completionBidInfo)
    }
    
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
        
        bidRequester.requestBids { [weak self] bidResponse, error in
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
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(timeout), execute: {
            if (!self.didReceiveResponse) {
                self.timeOutSignalSent = true
                completion(BidInfo(resultCode: .prebidDemandTimedOut))
                return
            }
        })
    }
    
    private func setUp(_ adObject: AnyObject?, with bidResponse: BidResponse) -> ResultCode {
        guard let winningBid = bidResponse.winningBid else {
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
    
    /**
     * This method obtains the context data keyword & value for adunit context targeting
     * if the key already exists the value will be appended to the list. No duplicates will be added
     */
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtData method instead.")
    public func addContextData(key: String, value: String) {
        addExtData(key: key, value: value)
    }
    
    /**
     * This method obtains the context data keyword & values for adunit context targeting
     * the values if the key already exist will be replaced with the new set of values
     */
    @available(*, deprecated, message: "This method is deprecated. Please, use updateExtData method instead.")
    public func updateContextData(key: String, value: Set<String>) {
        updateExtData(key: key, value: value)
    }
    
    /**
     * This method allows to remove specific context data keyword & values set from adunit context targeting
     */
    @available(*, deprecated, message: "This method is deprecated. Please, use removeExtData method instead.")
    public func removeContextData(forKey: String) {
        removeExtData(forKey: forKey)
    }
    
    /**
     * This method allows to remove all context data set from adunit context targeting
     */
    @available(*, deprecated, message: "This method is deprecated. Please, use clearExtData method instead.")
    public func clearContextData() {
        clearExtData()
    }
    
    // Used for tests
    func getExtDataDictionary() -> [String: [String]] {
        return adUnitConfig.getExtData()
    }
    
    /**
     * This method obtains the ext data keyword & value for adunit targeting
     * if the key already exists the value will be appended to the list. No duplicates will be added
     */
    public func addExtData(key: String, value: String) {
        adUnitConfig.addExtData(key: key, value: value)
    }
    
    /**
     * This method obtains the ext data keyword & values for adunit targeting
     * the values if the key already exist will be replaced with the new set of values
     */
    public func updateExtData(key: String, value: Set<String>) {
        adUnitConfig.updateExtData(key: key, value: value)
    }
    
    /**
     * This method allows to remove specific ext data keyword & values set from adunit targeting
     */
    public func removeExtData(forKey: String) {
        adUnitConfig.removeExtData(for: forKey)
    }
    
    /**
     * This method allows to remove all ext data set from adunit targeting
     */
    public func clearExtData() {
        adUnitConfig.clearExtData()
    }
    
    // MARK: - adunit ext keywords (imp[].ext.keywords)
    
    /**
     * This method obtains the context keyword for adunit context targeting
     * Inserts the given element in the set if it is not already present.
     */
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtKeyword method instead.")
    public func addContextKeyword(_ newElement: String) {
        addExtKeyword(newElement)
    }
    
    /**
     * This method obtains the context keyword set for adunit context targeting
     * Adds the elements of the given set to the set.
     */
    @available(*, deprecated, message: "This method is deprecated. Please, use addExtKeywords method instead.")
    public func addContextKeywords(_ newElements: Set<String>) {
        addExtKeywords(newElements)
    }
    
    /**
     * This method allows to remove specific context keyword from adunit context targeting
     */
    @available(*, deprecated, message: "This method is deprecated. Please, use removeExtKeyword method instead.")
    public func removeContextKeyword(_ element: String) {
        removeExtKeyword(element)
    }
    
    /**
     * This method allows to remove all keywords from the set of adunit context targeting
     */
    @available(*, deprecated, message: "This method is deprecated. Please, use clearExtKeywords method instead.")
    public func clearContextKeywords() {
        clearExtKeywords()
    }
    
    /**
     * This method obtains the keyword for adunit targeting
     * Inserts the given element in the set if it is not already present.
     */
    public func addExtKeyword(_ newElement: String) {
        adUnitConfig.addExtKeyword(newElement)
    }
    
    /**
     * This method obtains the keyword set for adunit targeting
     * Adds the elements of the given set to the set.
     */
    public func addExtKeywords(_ newElements: Set<String>) {
        adUnitConfig.addExtKeywords(newElements)
    }
    
    /**
     * This method allows to remove specific keyword from adunit targeting
     */
    public func removeExtKeyword(_ element: String) {
        adUnitConfig.removeExtKeyword(element)
    }
    
    /**
     * This method allows to remove all keywords from the set of adunit targeting
     */
    public func clearExtKeywords() {
        adUnitConfig.clearExtKeywords()
    }
    
    // Used for tests
    func getExtKeywordsSet() -> Set<String> {
        adUnitConfig.getExtKeywords()
    }
    
    // MARK: - App Content (app.content.data)
    
    public func setAppContent(_ appContentObject: PBMORTBAppContent) {
        adUnitConfig.setAppContent(appContentObject)
    }
    
    public func getAppContent() -> PBMORTBAppContent? {
        return adUnitConfig.getAppContent()
    }
    
    public func clearAppContent() {
        adUnitConfig.clearAppContent()
    }
    
    public func addAppContentData(_ dataObjects: [PBMORTBContentData]) {
        adUnitConfig.addAppContentData(dataObjects)
    }
    
    public func removeAppContentData(_ dataObject: PBMORTBContentData) {
        adUnitConfig.removeAppContentData(dataObject)
    }
    
    public func clearAppContentData() {
        adUnitConfig.clearAppContentData()
    }
    
    // MARK: - User Data (user.data)
    
    public func getUserData() -> [PBMORTBContentData]? {
        return adUnitConfig.getUserData()
    }
    
    public func addUserData(_ userDataObjects: [PBMORTBContentData]) {
        adUnitConfig.addUserData(userDataObjects)
    }
    
    public func removeUserData(_ userDataObject: PBMORTBContentData) {
        adUnitConfig.removeUserData(userDataObject)
    }
    
    public func clearUserData() {
        adUnitConfig.clearUserData()
    }
    
    // MARK: GPID
    
    public func setGPID(_ gpid: String?) {
        adUnitConfig.gpid = gpid
    }
    
    public func getGPID() -> String? {
        return adUnitConfig.gpid
    }
    
    // MARK: - others
    
    /**
     * This method allows to set the auto refresh period for the demand
     *
     * - Parameter time: refresh time interval
     */
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
    
    /**
     * This method stops the auto refresh of demand
     */
    public func stopAutoRefresh() {
        stopDispatcher()
    }
    
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
