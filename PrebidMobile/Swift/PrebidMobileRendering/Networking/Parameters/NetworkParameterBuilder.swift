/*   Copyright 2018-2021 Prebid.org, Inc.

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

import CoreTelephony
import Foundation

class NetworkParameterBuilder: NSObject, ParameterBuilder {

    private let ctTelephonyNetworkInfo: CTTelephonyNetworkInfo
    private let reachability: Reachability

    init(ctTelephonyNetworkInfo: CTTelephonyNetworkInfo, reachability: Reachability) {
        self.ctTelephonyNetworkInfo = ctTelephonyNetworkInfo
        self.reachability = reachability
        super.init()
    }

    func build(_ bidRequest: ORTBBidRequest) {
        // reachability type
        let networkStatus = reachability.currentReachabilityStatus
        bidRequest.device.connectiontype = NSNumber(value: networkStatus.rawValue)

        setCarrier(in: bidRequest)
    }

    private func setCarrier(in bidRequest: ORTBBidRequest) {
        var carrier: CTCarrier?

        if #available(iOS 16.0, *) {
            // do nothing - CTCarrier is deprecated with no replacement
        } else {
            carrier = ctTelephonyNetworkInfo.serviceSubscriberCellularProviders?.values.first
        }

        guard let carrier = carrier else {
            return
        }

        // Update params dict
        if let countryCode = carrier.mobileCountryCode, let carrierCode = carrier.mobileNetworkCode {
            bidRequest.device.mccmnc = "\(countryCode)-\(carrierCode)"
        }

        // Update ORTB
        // carrier
        bidRequest.device.carrier = carrier.carrierName
    }
}
