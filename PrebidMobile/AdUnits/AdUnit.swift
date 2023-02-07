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

@objcMembers public class AdUnit: NSObject, DispatcherDelegate {
    
    public var pbAdSlot: String? {
        get { adUnitConfig.getPbAdSlot()}
        set { adUnitConfig.setPbAdSlot(newValue) }
    }
    
    private static let PB_MIN_RefreshTime = 30000.0

    var identifier: String

    var dispatcher: Dispatcher?
    
    var adUnitConfig: AdUnitConfig
    
    var bidRequester: PBMBidRequester?
    
    var adSizes: [CGSize] {
        get { [adUnitConfig.adSize] + (adUnitConfig.additionalSizes ?? []) }
        set {
            if let adSize = newValue.first {
                adUnitConfig.adSize = adSize
            }
            
            if newValue.count > 1 {
                adUnitConfig.additionalSizes = Array(newValue.dropFirst())
            }
        }
    }
    
    var prebidConfigId: String {
        get { adUnitConfig.configId }
        set { adUnitConfig.configId = newValue }
    }

    //This flag is set to check if the refresh needs to be made though the user has not invoked the fetch demand after initialization
    private var isInitialFetchDemandCallMade: Bool = false

    private var adServerObject: AnyObject?

    private var closureAd: ((ResultCode) -> Void)?
    private var closureBids: ((ResultCode, [String : String]?) -> Void)?

    //notification flag set to check if the prebid response is received within the specified time
    var didReceiveResponse: Bool! = false

    //notification flag set to determine if delegate call needs to be made after timeout delegate is sent
    var timeOutSignalSent: Bool! = false

    public init(configId: String, size: CGSize?) {
        adUnitConfig = AdUnitConfig(configId: configId, size: size ?? CGSize.zero)
        adUnitConfig.adConfiguration.isOriginalAPI = true
        identifier = UUID.init().uuidString
        super.init()
        
        // PBS should cache the bid for original api.
        Prebid.shared.useCacheForReportingWithRenderingAPI = true
        Prebid.shared.useExternalClickthroughBrowser = true
    }

    //TODO: dynamic is used by tests
    dynamic public func fetchDemand(completion: @escaping(_ result: ResultCode, _ kvResultDict: [String : String]?) -> Void) {

        closureBids = completion

        let dictContainer = DictionaryContainer<String, String>()

        fetchDemand(adObject: dictContainer) { (resultCode) in
            let dict = dictContainer.dict

            DispatchQueue.main.async {
                completion(resultCode, dict.count > 0 ? dict : nil)
            }
        }
    }

    //TODO: dynamic is used by tests
    dynamic public func fetchDemand(adObject: AnyObject, completion: @escaping(_ result: ResultCode) -> Void) {
        
        if !(self is NativeRequest){
            for size in adSizes {
                if (size.width < 0 || size.height < 0) {
                    completion(.prebidInvalidSize)
                    return
                }
            }
        }

        Utils.shared.removeHBKeywords(adObject: adObject)

        if (prebidConfigId.isEmpty || (prebidConfigId.trimmingCharacters(in: CharacterSet.whitespaces)).count == 0) {
            completion(.prebidInvalidConfigId)
            return
        }
        if (Prebid.shared.prebidServerAccountId.isEmpty || (Prebid.shared.prebidServerAccountId.trimmingCharacters(in: CharacterSet.whitespaces)).count == 0) {
            completion(.prebidInvalidAccountId)
            return
        }

        if !isInitialFetchDemandCallMade {
            isInitialFetchDemandCallMade = true
            startDispatcher()
        }

        didReceiveResponse = false
        timeOutSignalSent = false
        self.closureAd = completion
        adServerObject = adObject

        bidRequester = PBMBidRequester(connection: ServerConnection.shared,
                                       sdkConfiguration: Prebid.shared,
                                       targeting: Targeting.shared,
                                       adUnitConfiguration: adUnitConfig)
        
        bidRequester?.requestBids { [weak self] bidResponse, error in
            guard let self = self else { return }
            self.didReceiveResponse = true
            
            if let bidResponse = bidResponse {
                if (!self.timeOutSignalSent) {
                    self.handleBidResponse(adObject: adObject, bidResponse: bidResponse) { resultCode in
                        if resultCode == .prebidDemandFetchSuccess {
                            Utils.shared.validateAndAttachKeywords (adObject: adObject, bidResponse: bidResponse)
                        }
                        completion(resultCode)
                        return
                    }
                }
            } else {
                if (!self.timeOutSignalSent) {
                    completion(PBMError.demandResult(from: error))
                    return
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(truncating: Prebid.shared.timeoutMillisDynamic ?? NSNumber(value: .PB_Request_Timeout))), execute: {
            if (!self.didReceiveResponse) {
                self.timeOutSignalSent = true
                completion(.prebidDemandTimedOut)
                return
            }
        })
    }
    
    private func handleBidResponse(adObject: AnyObject, bidResponse: BidResponse, completion: (ResultCode) -> Void) {
        if let winningBid = bidResponse.winningBid {
            if self.adUnitConfig.adFormats.contains(AdFormat.native) {
                let expireInterval = TimeInterval(truncating: winningBid.bid.exp ?? CacheManager.cacheManagerExpireInterval as NSNumber)
                do {
                    if let cacheId = CacheManager.shared.save(content: try winningBid.bid.toJsonString(), expireInterval: expireInterval), !cacheId.isEmpty {
                        var newTargetingInfo = bidResponse.targetingInfo ?? [:]
                        newTargetingInfo[PrebidLocalCacheIdKey] = cacheId
                        bidResponse.setTargetingInfo(with: newTargetingInfo)
                        completion(.prebidDemandFetchSuccess)
                        return
                    }
                } catch {
                    Log.error("Error saving bid content to cache: \(error.localizedDescription)")
                }
            } else {
                completion(.prebidDemandFetchSuccess)
                return
            }
        } else {
            completion(.prebidDemandNoBids)
            return
        }
    }

    // MARK: - adunit context data aka inventory data (imp[].ext.data)
    
    /**
     * This method obtains the context data keyword & value for adunit context targeting
     * if the key already exists the value will be appended to the list. No duplicates will be added
     */
    public func addContextData(key: String, value: String) {
        adUnitConfig.addContextData(key: key, value: value)
    }
    
    /**
     * This method obtains the context data keyword & values for adunit context targeting
     * the values if the key already exist will be replaced with the new set of values
     */
    public func updateContextData(key: String, value: Set<String>) {
        adUnitConfig.updateContextData(key: key, value: value)
    }
    
    /**
     * This method allows to remove specific context data keyword & values set from adunit context targeting
     */
    public func removeContextData(forKey: String) {
        adUnitConfig.removeContextData(for: forKey)
    }
    
    /**
     * This method allows to remove all context data set from adunit context targeting
     */
    public func clearContextData() {
        adUnitConfig.clearContextData()
    }
    
    func getContextDataDictionary() -> [String: [String]] {
        return adUnitConfig.getContextData()
    }
    
    // MARK: - adunit context keywords (imp[].ext.context.keywords)
    
    /**
     * This method obtains the context keyword for adunit context targeting
     * Inserts the given element in the set if it is not already present.
     */
    public func addContextKeyword(_ newElement: String) {
        adUnitConfig.addContextKeyword(newElement)
    }
    
    /**
     * This method obtains the context keyword set for adunit context targeting
     * Adds the elements of the given set to the set.
     */
    public func addContextKeywords(_ newElements: Set<String>) {
        adUnitConfig.addContextKeywords(newElements)
    }
    
    /**
     * This method allows to remove specific context keyword from adunit context targeting
     */
    public func removeContextKeyword(_ element: String) {
        adUnitConfig.removeContextKeyword(element)
    }
    
    /**
     * This method allows to remove all keywords from the set of adunit context targeting
     */
    public func clearContextKeywords() {
        adUnitConfig.clearContextKeywords()
    }
    
    func getContextKeywordsSet() -> Set<String> {
        adUnitConfig.getContextKeywords()
    }
    
    // MARK: - App Content
    
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
    
    // MARK: - User Data
        
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
        
        if self.dispatcher?.state == .stopped {
            self.dispatcher?.setAutoRefreshMillis(time: time)
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
        if self.dispatcher?.state == .stopped {
            if isInitialFetchDemandCallMade {
                startDispatcher()
            }
        }
    }

    dynamic func checkRefreshTime(_ time: Double) -> Bool {
        return time >= AdUnit.PB_MIN_RefreshTime
    }

    func refreshDemand() {

        guard let adServerObject = adServerObject else {
            return
        }

        if adServerObject is DictionaryContainer<String, String>, let closureBids = closureBids {
            fetchDemand(completion: closureBids)
        } else if let closureAd = closureAd {
            fetchDemand(adObject: adServerObject, completion: closureAd)
        }

    }

    func initDispatcher(refreshTime: Double) {
        self.dispatcher = Dispatcher.init(withDelegate: self, autoRefreshMillies: refreshTime)
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
