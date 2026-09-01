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

import Foundation

class BasicParameterBuilder: NSObject, ParameterBuilder {

    private let adConfiguration: AdConfiguration
    private let sdkConfiguration: Prebid
    private let targeting: Targeting
    private let sdkVersion: String

    init(
        adConfiguration: AdConfiguration,
        sdkConfiguration: Prebid,
        sdkVersion: String,
        targeting: Targeting
    ) {
        self.adConfiguration = adConfiguration
        self.sdkConfiguration = sdkConfiguration
        self.sdkVersion = sdkVersion
        self.targeting = targeting
        super.init()
    }

    func build(_ bidRequest: ORTBBidRequest) {
        // Add an impression if none exist
        if bidRequest.imp.isEmpty {
            bidRequest.imp = [ORTBImp()]
        }

        for rtbImp in bidRequest.imp {
            rtbImp.displaymanager = adConfiguration.isOriginalAPI ? nil : "prebid-mobile"
            rtbImp.displaymanagerver = adConfiguration.isOriginalAPI ? nil : sdkVersion

            rtbImp.instl = adConfiguration.presentAsInterstitial ? 1 : 0

            // set secure=1 for https or secure=0 for http
            rtbImp.secure = 1
        }

        bidRequest.regs.coppa = targeting.coppa
        // `regs.ext["gdpr"]` is owned by `UserConsentParameterBuilder`, which runs after this one.
        bidRequest.regs.gpp = InternalUserConsentDataManager.gppHDRString

        let gppSID = InternalUserConsentDataManager.gppSID
        if !gppSID.isEmpty {
            bidRequest.regs.gppSID = gppSID
        }

        appendFormatSpecificParameters(for: bidRequest)
    }

    private func appendFormatSpecificParameters(for bidRequest: ORTBBidRequest) {
        let adFormats = adConfiguration.adFormats

        if adFormats.contains(.banner) {
            appendDisplayParameters(for: bidRequest)
        }

        if adFormats.contains(.video) {
            appendVideoParameters(for: bidRequest)
        }

        if adFormats.contains(.native) {
            appendNativeParameters(for: bidRequest)
        }
    }

    private func appendDisplayParameters(for bidRequest: ORTBBidRequest) {
        // Ensure there's at least 1 banner
        let hasBanner = bidRequest.imp.contains { $0.banner != nil }

        if !hasBanner {
            bidRequest.imp.first?.banner = ORTBBanner()
        }
    }

    private func appendVideoParameters(for bidRequest: ORTBBidRequest) {
        bidRequest.imp.first?.video = ORTBVideo()
    }

    private func appendNativeParameters(for bidRequest: ORTBBidRequest) {
        bidRequest.imp.first?.native = ORTBNative()
    }
}
