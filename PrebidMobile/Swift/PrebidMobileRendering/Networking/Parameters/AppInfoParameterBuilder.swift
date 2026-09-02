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

class AppInfoParameterBuilder: NSObject, ParameterBuilder {

    // Keys into Bundle info Dict
    static var bundleNameKey: String { "CFBundleName" }
    static var bundleDisplayNameKey: String { "CFBundleDisplayName" }

    private let bundle: BundleProtocol
    private let targeting: Targeting

    init(bundle: BundleProtocol, targeting: Targeting) {
        self.bundle = bundle
        self.targeting = targeting
        super.init()
    }

    func build(_ bidRequest: ORTBBidRequest) {
        if bidRequest.app.bundle == nil, let bundleIdentifier = bundle.bundleIdentifier {
            bidRequest.app.bundle = bundleIdentifier
        }

        if let bundleDict = bundle.infoDictionary {
            let bundleDisplayName = bundleDict[AppInfoParameterBuilder.bundleDisplayNameKey] as? String
            let bundleName = bundleDict[AppInfoParameterBuilder.bundleNameKey] as? String
            if let appName = bundleDisplayName ?? bundleName {
                bidRequest.app.name = appName
            }
        }

        if bidRequest.app.publisher?.name == nil, let publisherName = targeting.publisherName {
            if bidRequest.app.publisher == nil {
                bidRequest.app.publisher = ORTBPublisher()
            }
            bidRequest.app.publisher?.name = publisherName
        }
    }
}
