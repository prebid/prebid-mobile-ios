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
@objc extension PBMORTBBidExtSkadn {

    @objc private func getFidelityTypes() -> Array<NSNumber>? {
        guard let fidelities = fidelities else { return nil }
        var fidsArray = [NSNumber]()
        for fid in fidelities {
            if let safeFid = fid.fidelity {
                fidsArray.append(safeFid)
            }
        }
        return fidsArray
    }
    
    @objc public func getSKAdNetworkImpression() -> SKAdImpression? {
        if let fids = self.getFidelityTypes() {
            if fids.contains(0) {
                let imp = SKAdImpression()
                if let itunesitem = itunesitem,
                   let network = network,
                   let campaign = campaign,
                   let sourceapp = sourceapp {
                    imp.sourceAppStoreItemIdentifier = sourceapp
                    imp.advertisedAppStoreItemIdentifier = itunesitem
                    imp.adNetworkIdentifier = network
                    imp.adCampaignIdentifier = campaign
                    
                    if let safeFids = fidelities {
                        for fid in safeFids {
                            if fid.fidelity == 0 {
                                if let nonce = fid.nonce,
                                   let timestamp = fid.timestamp,
                                   let signature = fid.signature {
                                    imp.adImpressionIdentifier = nonce.uuidString
                                    imp.timestamp = timestamp
                                    imp.signature = signature
                                    
                                    return imp
                                }
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
}
