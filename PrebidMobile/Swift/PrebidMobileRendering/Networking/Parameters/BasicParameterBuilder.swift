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

    static var platformKey: String { "sp" }
    static var platformValue: String { "iOS" }
    static var allowRedirectsKey: String { "dr" }
    static var allowRedirectsVal: String { "true" }
    static var sdkVersionKey: String { "sv" }
    static var urlKey: String { PrebidConstants.APP_STORE_URL_SCHEME }
    static var rewardedVideoKey: String { "vrw" }
    static var rewardedVideoValue: String { "1" }

    // Note: properties below are optional for UnitTests to be able to write 'nil' into them.
    // TODO: Prove that 'init' arguments are never nil; convert to 'let'; remove redundant checks and tests.

    var adConfiguration: AdConfiguration?
    var sdkConfiguration: Prebid?
    var targeting: Targeting?
    var sdkVersion: String?

    init(
        adConfiguration: AdConfiguration?,
        sdkConfiguration: Prebid?,
        sdkVersion: String?,
        targeting: Targeting?
    ) {
        self.adConfiguration = adConfiguration
        self.sdkConfiguration = sdkConfiguration
        self.sdkVersion = sdkVersion
        self.targeting = targeting
        super.init()
    }

    func build(_ bidRequest: ORTBBidRequest) {
        guard let adConfiguration = adConfiguration, sdkConfiguration != nil, let sdkVersion = sdkVersion else {
            Log.error("Invalid properties")
            return
        }

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

        bidRequest.regs.coppa = targeting?.coppa
        bidRequest.regs.ext?["gdpr"] = targeting?.getSubjectToGDPR()
        bidRequest.regs.gpp = InternalUserConsentDataManager.gppHDRString

        let gppSID = InternalUserConsentDataManager.gppSID
        if !gppSID.isEmpty {
            bidRequest.regs.gppSID = gppSID
        }

        appendFormatSpecificParameters(for: bidRequest)
    }

    private func appendFormatSpecificParameters(for bidRequest: ORTBBidRequest) {
        guard let adFormats = adConfiguration?.adFormats else {
            return
        }

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
