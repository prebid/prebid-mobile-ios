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

import Foundation
import ObjectiveC.runtime

@objcMembers public class AdUnit: NSObject, DispatcherDelegate {

    var prebidConfigId: String = ""

    var adSizes = Array<CGSize> ()

    var identifier: String

    var dispatcher: Dispatcher?

    private var contextDataDictionary = [String: Set<String>]()

    private var contextKeywordsSet = Set<String>()

    //This flag is set to check if the refresh needs to be made though the user has not invoked the fetch demand after initialization
    private var isInitialFetchDemandCallMade: Bool = false

    private var adServerObject: AnyObject?

    private var closure: (ResultCode) -> Void

    //notification flag set to check if the prebid response is received within the specified time
    var didReceiveResponse: Bool! = false

    //notification flag set to determine if delegate call needs to be made after timeout delegate is sent
    var timeOutSignalSent: Bool! = false

    init(configId: String, size: CGSize?) {
        self.closure = {_ in return}
        prebidConfigId = configId
        if let givenSize = size {
           adSizes.append(givenSize)
        }
        identifier = UUID.init().uuidString
        super.init()
    }

    dynamic public func fetchDemand(adObject: AnyObject, completion: @escaping(_ result: ResultCode) -> Void) {
        
        if !(self is NativeRequest){
            for size in adSizes {
                if (size.width < 0 || size.height < 0) {
                    completion(ResultCode.prebidInvalidSize)
                    return
                }
            }
        }

        Utils.shared.removeHBKeywords(adObject: adObject)

        if (prebidConfigId.isEmpty || (prebidConfigId.trimmingCharacters(in: CharacterSet.whitespaces)).count == 0) {
            completion(ResultCode.prebidInvalidConfigId)
            return
        }
        if (Prebid.shared.prebidServerAccountId.isEmpty || (Prebid.shared.prebidServerAccountId.trimmingCharacters(in: CharacterSet.whitespaces)).count == 0) {
            completion(ResultCode.prebidInvalidAccountId)
            return
        }

        if !isInitialFetchDemandCallMade {
            isInitialFetchDemandCallMade = true
            startDispatcher()
        }

        didReceiveResponse = false
        timeOutSignalSent = false
        self.closure = completion
        adServerObject = adObject
        let manager: BidManager = BidManager(adUnit: self)

        manager.requestBidsForAdUnit { (bidResponse, resultCode) in
            self.didReceiveResponse = true
            if (bidResponse != nil) {
                if (!self.timeOutSignalSent) {
                    Utils.shared.validateAndAttachKeywords (adObject: adObject, bidResponse: bidResponse!)
                    completion(resultCode)
                }

            } else {
                if (!self.timeOutSignalSent) {
                    completion(resultCode)
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Prebid.shared.timeoutMillisDynamic), execute: {
            if (!self.didReceiveResponse) {
                self.timeOutSignalSent = true
                completion(ResultCode.prebidDemandTimedOut)

            }
        })
    }
    
    // MARK: - DEPRECATED adunit user keywords (user.keywords)

    /**
     The func uses Targeting.addUserKeyword() inside.
     - Parameters:
        - key: parameter is omitted
        - value: is passed to Targeting.addUserKeyword()
     */
    @available(*, deprecated, message: "Please use Targeting.addUserKeyword() method instead")
    public func addUserKeyword(key: String, value: String) {
        Targeting.shared.addUserKeyword(value)
    }

    /**
     The func uses Targeting.addUserKeyword() inside.
     - Parameters:
        - key: parameter is omitted
        - value: is passed to Targeting.addUserKeywords()
     */
    @available(*, deprecated, message: "Please use Targeting.addUserKeywords() method instead")
    public func addUserKeywords(key: String, value: Set<String>) {
        Targeting.shared.addUserKeywords(value)
    }

    /**
     The func uses Targeting.clearUserKeywords() inside.
     */
    @available(*, deprecated, message: "Please use Targeting.clearUserKeywords() method instead")
    public func clearUserKeywords() {
        Targeting.shared.clearUserKeywords()
    }

    /**
     The func uses Targeting.removeUserKeyword() inside.
     - Parameters:
     - forKey: is a value that has been added previously
     */
    @available(*, deprecated, message: "Please use Targeting.removeUserKeyword() method instead")
    public func removeUserKeyword(forKey: String) {
        Targeting.shared.removeUserKeyword(forKey)
    }

    // MARK: - adunit context data aka inventory data (imp[].ext.context.data)
    
    /**
     * This method obtains the context data keyword & value for adunit context targeting
     * if the key already exists the value will be appended to the list. No duplicates will be added
     */
    public func addContextData(key: String, value: String) {
        contextDataDictionary.addValue(value, forKey: key)
    }
    
    /**
     * This method obtains the context data keyword & values for adunit context targeting
     * the values if the key already exist will be replaced with the new set of values
     */
    public func updateContextData(key: String, value: Set<String>) {
        contextDataDictionary.updateValue(value, forKey: key)
    }
    
    /**
     * This method allows to remove specific context data keyword & values set from adunit context targeting
     */
    public func removeContextData(forKey: String) {
        contextDataDictionary.removeValue(forKey: forKey)
    }
    
    /**
     * This method allows to remove all context data set from adunit context targeting
     */
    public func clearContextData() {
        contextDataDictionary.removeAll()
    }
    
    func getContextDataDictionary() -> [String: Set<String>] {
        Log.info("adunit context data dictionary is \(contextDataDictionary)")
        return contextDataDictionary
    }
    
    // MARK: - adunit context keywords (imp[].ext.context.keywords)
    
    /**
     * This method obtains the context keyword for adunit context targeting
     * Inserts the given element in the set if it is not already present.
     */
    public func addContextKeyword(_ newElement: String) {
        contextKeywordsSet.insert(newElement)
    }
    
    /**
     * This method obtains the context keyword set for adunit context targeting
     * Adds the elements of the given set to the set.
     */
    public func addContextKeywords(_ newElements: Set<String>) {
        contextKeywordsSet.formUnion(newElements)
    }
    
    /**
     * This method allows to remove specific context keyword from adunit context targeting
     */
    public func removeContextKeyword(_ element: String) {
        contextKeywordsSet.remove(element)
    }
    
    /**
     * This method allows to remove all keywords from the set of adunit context targeting
     */
    public func clearContextKeywords() {
        contextKeywordsSet.removeAll()
    }
    
    func getContextKeywordsSet() -> Set<String> {
        Log.info("adunit context keywords set is \(contextKeywordsSet)")
        return contextKeywordsSet
    }

    // MARK: - others

    /**
     * This method allows to set the auto refresh period for the demand
     *
     * - Parameter time: refresh time interval
     */
    public func setAutoRefreshMillis(time: Double) {

        stopDispatcher()

        guard time >= .PB_MIN_RefreshTime else {
            Log.error("auto refresh not set as the refresh time is less than to \(.PB_MIN_RefreshTime as Double) seconds")
            return
        }

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

    func refreshDemand() {
        if (adServerObject != nil) {
            self.fetchDemand(adObject: adServerObject!, completion: self.closure)
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
        self.dispatcher = nil
    }

}
