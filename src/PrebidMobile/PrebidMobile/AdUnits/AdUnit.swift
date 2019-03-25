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
