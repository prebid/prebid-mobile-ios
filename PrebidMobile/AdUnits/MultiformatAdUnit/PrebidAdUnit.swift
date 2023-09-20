/*   Copyright 2019-2023 Prebid.org, Inc.

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

@objcMembers
public class PrebidAdUnit: NSObject {
    
    public var pbAdSlot: String? {
        get { adUnit.pbAdSlot }
        set { adUnit.pbAdSlot = newValue }
    }
    
    private var adUnit: AdUnit
    
    public init(configId: String) {
        self.adUnit = AdUnit(configId: configId, size: CGSize.zero, adFormats: [])
        super.init()
    }
    
    public func fetchDemand(adObject: AnyObject, request: PrebidRequest,
                            completion: @escaping (ResultCode) -> Void) {
        adUnit.fetchDemand(adObject: adObject, request: request, completion: completion)
    }
    
    public func fetchDemand(request: PrebidRequest, completion: @escaping (BidInfo) -> Void) {
        adUnit.fetchDemand(request: request, completion: completion)
    }
    
    
    // MARK: - Auto refresh API
    /**
     * This method allows to set the auto refresh period for the demand
     *
     * - Parameter time: refresh time interval
     */
    public func setAutoRefreshMillis(time: Double) {
        adUnit.setAutoRefreshMillis(time: time)
    }
    
    /**
     * This method stops the auto refresh of demand
     */
    public func stopAutoRefresh() {
        adUnit.stopAutoRefresh()
    }
    
    public func resumeAutoRefresh() {
        adUnit.resumeAutoRefresh()
    }
}
