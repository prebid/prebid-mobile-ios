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

class SKAdNetworksParameterBuilder: NSObject, ParameterBuilder {

    // Keys into Bundle info Dict
    static var SKAdNetworkItemsKey: String { "SKAdNetworkItems" }
    static var SKAdNetworkIdentifierKey: String { "SKAdNetworkIdentifier" }

    private let bundle: BundleProtocol
    private let targeting: Targeting
    private let adConfiguration: AdConfiguration?

    init(bundle: BundleProtocol, targeting: Targeting, adConfiguration: AdConfiguration?) {
        self.bundle = bundle
        self.targeting = targeting
        self.adConfiguration = adConfiguration
        super.init()
    }

    func build(_ bidRequest: ORTBBidRequest) {
        guard let skadnetids = skAdNetworkIds() else {
            return
        }

        let sourceapp = targeting.sourceapp
        if sourceapp == nil {
            Log.error("Info.plist contains SKAdNetwork but sourceapp is nil!")
        }

        for imp in bidRequest.imp {
            imp.extSkadn.sourceapp = sourceapp
            imp.extSkadn.skadnetids = skadnetids

            if adConfiguration?.supportSKOverlay == true {
                imp.extSkadn.skoverlay = 1
            }
        }
    }

    /// Returns an array of SKAdNetwork ids or nil
    func skAdNetworkIds() -> [String]? {
        guard #available(iOS 14.0, *) else {
            return nil
        }

        let itemsKey = SKAdNetworksParameterBuilder.SKAdNetworkItemsKey
        guard let skadNetworks = bundle.infoDictionary?[itemsKey] as? [[String: Any]] else {
            return nil
        }

        return skadNetworks.compactMap { $0[SKAdNetworksParameterBuilder.SKAdNetworkIdentifierKey] as? String }
    }
}
