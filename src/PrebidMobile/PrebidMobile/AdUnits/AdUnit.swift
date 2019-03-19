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

    var prebidConfigId: String! = ""

    var adSizes = [CGSize] ()

    var identifier: String

    var timerClass: Dispatcher?

    var refreshTime: Double? = 0.0

    private var customUserKeywords = [String: [String]]()
    private var customInvKeywords = [String: [String]]()

    //This flag is set to check if the refresh needs to be made though the user has not invoked the fetch demand after initialization
    private var isInitialCallMade: Bool! = false

    private var adServerObject: AnyObject?

    private var closure: (ResultCode) -> Void

    //notification flag set to check if the prebid response is received within the specified time
    var didReceiveResponse: Bool! = false

    //notification flag set to determine if delegate call needs to be made after timeout delegate is sent
    var timeOutSignalSent: Bool! = false

    init(configId: String, size: CGSize) {
        self.closure = {_ in return}
        prebidConfigId = configId
        adSizes.append(size)
        identifier = UUID.init().uuidString
        super.init()

        timerClass = Dispatcher.init(withDelegate: self)
    }

    dynamic public func fetchDemand(adObject: AnyObject, completion: @escaping(_ result: ResultCode) -> Void) {

        Utils.shared.removeHBKeywords(adObject: adObject)

        for size in adSizes {
            if (size.width < 0 || size.height < 0) {
                completion(ResultCode.prebidInvalidSize)
                return
            }
        }

        if (prebidConfigId.isEmpty || (prebidConfigId.trimmingCharacters(in: CharacterSet.whitespaces)).count == 0) {
            completion(ResultCode.prebidInvalidConfigId)
            return
        }
        if (Prebid.shared.prebidServerAccountId.isEmpty || (Prebid.shared.prebidServerAccountId.trimmingCharacters(in: CharacterSet.whitespaces)).count == 0) {
            completion(ResultCode.prebidInvalidAccountId)
            return
        }
        if (isInitialCallMade == false) {
            //the publisher called the fetch demand 1st fire the timer
            isInitialCallMade = true
            //start the timer only if the refresh timer is valided & set
            if (refreshTime! > 0.0) {
                self.timerClass?.start(autoRefreshMillies: refreshTime!)
            }
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

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(.PB_Request_Timeout), execute: {
            if (!self.didReceiveResponse) {
                self.timeOutSignalSent = true
                completion(ResultCode.prebidDemandTimedOut)

            }
        })
    }

    var userKeywords: [String: [String]] {
        Log.info("user keywords are \(customUserKeywords)")
        return customUserKeywords
    }

    var invKeywords: [String: [String]] {
        Log.info("user keywords are \(customInvKeywords)")
        return customInvKeywords
    }

    /**
     * This method obtains the user keyword & value user for targeting
     * if the key already exists the value will be appended to the list. No duplicates will be added
     */
    public func addUserKeyword(key: String, value: String) {
        var existingValues: [String] = []
        if (customUserKeywords[key] != nil) {
            existingValues = customUserKeywords[key]!
        }
        if (!existingValues.contains(value)) {
            existingValues.append(value)
            customUserKeywords[key] = existingValues
        }
    }

    /**
     * This method obtains the inventory keyword & value for targeting
     * if the key already exists the value will be appended to the list. No duplicates will be added
     */
    public func addInvKeyword(key: String, value: String) {
        var existingValues: [String] = []
        if (customInvKeywords[key] != nil) {
            existingValues = customInvKeywords[key]!
        }
        if (!existingValues.contains(value)) {
            existingValues.append(value)
            customInvKeywords[key] = existingValues
        }
    }

    /**
     * This method obtains the user keyword & values set for user targeting.
     * the values if the key already exist will be replaced with the new set of values
     */
    public func addUserKeywords(key: String, value: [String]) {

        customUserKeywords[key] = value

    }

    /**
     * This method obtains the inventory keyword & values set for targeting.
     * the values if the key already exist will be replaced with the new set of values
     */
    public func addInvKeywords(key: String, value: [String]) {

        customInvKeywords[key] = value

    }

    /**
     * This method allows to remove all the user keywords set for user targeting
     */
    public func clearUserKeywords() {

        if (customUserKeywords.count > 0 ) {
            customUserKeywords.removeAll()
        }

    }

    /**
     * This method allows to remove all the inventory keywords set for user targeting
     */
    public func clearInvKeywords() {

        if (customInvKeywords.count > 0 ) {
            customInvKeywords.removeAll()
        }

    }

    /**
     * This method allows to remove specific user keyword & value set from user targeting
     */
    public func removeUserKeyword(forKey: String) {
        if (customUserKeywords[forKey] != nil) {
            customUserKeywords.removeValue(forKey: forKey)
        }
    }

    /**
     * This method allows to remove specific inventory keyword & value set from user targeting
     */
    public func removeInvKeyword(forKey: String) {
        if (customInvKeywords[forKey] != nil) {
            customInvKeywords.removeValue(forKey: forKey)
        }
    }

    /**
     * This method allows to set the auto refresh period for the demand
     */
    public func setAutoRefreshMillis(time: Double) {
        if (time >= .PB_MIN_RefreshTime) {
            //Stop the old refresh & start a new timer
            if (refreshTime! > 0.0 && isInitialCallMade == true) {
                timerClass!.stop()
                refreshTime = time
                timerClass!.start(autoRefreshMillies: refreshTime!)

            } else {
                refreshTime = time
            }
        } else {
            Log.error("auto refresh not set as the refresh time is less than to 30 seconds")
        }
    }

    /**
     * This method stops the auto refresh of demand
     */
    public func stopAutoRefresh() {
        timerClass!.stop()
    }

    func refreshDemand() {
        if (adServerObject != nil) {
            self.fetchDemand(adObject: adServerObject!, completion: self.closure)
        }

    }

}
