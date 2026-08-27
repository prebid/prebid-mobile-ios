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

import AppTrackingTransparency
import Foundation

class DeviceInfoParameterBuilder: NSObject, ParameterBuilder {

    static var ifaKey: String { "ifa" }
    static var lmtKey: String { "lmt" }
    static var ifvKey: String { "ifv" }
    static var attsKey: String { "atts" }

    private static let zeroedIFA = "00000000-0000-0000-0000-000000000000"

    private let deviceAccessManager: DeviceAccessManager

    init(deviceAccessManager: DeviceAccessManager) {
        self.deviceAccessManager = deviceAccessManager
        super.init()
    }

    func build(_ bidRequest: ORTBBidRequest) {
        let screenSize = deviceAccessManager.screenSize()

        bidRequest.device.w = NSNumber(value: Double(screenSize.width))
        bidRequest.device.h = NSNumber(value: Double(screenSize.height))

        // The OpenRTB `lmt` property is the inverse of Apple's `ASIdentifierManager` API.
        // OpenRTB spec defines `lmt` as:
        //     “Limit Ad Tracking” signal commercially endorsed (e.g., iOS, Android), where 0 = tracking
        //     is unrestricted, 1 = tracking must be limited per commercial guidelines.
        var lmt = NSNumber(value: !deviceAccessManager.advertisingTrackingEnabled())

        var ifa: String? = Targeting.shared.isAllowedAccessDeviceData()
            ? deviceAccessManager.advertisingIdentifier()
            : nil
        if ifa?.isEmpty == true {
            ifa = nil
        }

        bidRequest.device.lmt = lmt
        bidRequest.device.ifa = ifa

        // Only passed when IDFA (BidRequest.device.ifa) is unavailable or all zeros.
        if ifa == nil || ifa == DeviceInfoParameterBuilder.zeroedIFA {
            bidRequest.device.extAtts.ifv = deviceAccessManager.identifierForVendor
        }

        // https://github.com/InteractiveAdvertisingBureau/openrtb/blob/master/extensions/community_extensions/skadnetwork.md#device-extension
        if #available(iOS 14.0, *) {
            let atts = NSNumber(value: deviceAccessManager.appTrackingTransparencyStatus())
            bidRequest.device.extAtts.atts = atts
            lmt = atts.uintValue == ATTrackingManager.AuthorizationStatus.authorized.rawValue ? 0 : 1
            bidRequest.device.lmt = lmt
        }

        bidRequest.device.make = deviceAccessManager.deviceMake
        bidRequest.device.model = deviceAccessManager.deviceModel
        bidRequest.device.os = deviceAccessManager.deviceOS
        bidRequest.device.osv = deviceAccessManager.OSVersion
        bidRequest.device.hwv = deviceAccessManager.platformString
        bidRequest.device.language = deviceAccessManager.userLangaugeCode
    }
}
