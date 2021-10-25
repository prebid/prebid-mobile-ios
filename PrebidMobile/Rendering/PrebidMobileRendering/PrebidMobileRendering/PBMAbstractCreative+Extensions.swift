//
/*   Copyright 2018-2021 Prebid.org, Inc.

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
import StoreKit

@available(iOS 14.5, *)
@objc extension PBMAbstractCreative {
    @objc public func buildSKAdNetworkImpression() -> SKAdImpression? {
        if let skadInfo = self.transaction?.skadInfo {
            let imp = SKAdImpression()
            if let itunesitem = skadInfo.itunesitem,
               let network = skadInfo.network,
               let campaign = skadInfo.campaign,
               let sourceapp = skadInfo.sourceapp {
                imp.sourceAppStoreItemIdentifier = sourceapp
                imp.advertisedAppStoreItemIdentifier = itunesitem
                imp.adNetworkIdentifier = network
                imp.adCampaignIdentifier = campaign
            } else {
                 return nil
            }
            
            if let safeFids = skadInfo.fidelities {
                for fid in safeFids {
                    if fid.fidelity == 0 {
                        if let nonce = fid.nonce,
                           let timestamp = fid.timestamp,
                           let signature = fid.signature {
                            imp.adImpressionIdentifier = nonce.uuidString
                            imp.timestamp = timestamp
                            imp.signature = signature
                            
                            return imp
                        } else {
                            return nil
                        }
                    }
                }
            }
        }
        return nil
    }
}
