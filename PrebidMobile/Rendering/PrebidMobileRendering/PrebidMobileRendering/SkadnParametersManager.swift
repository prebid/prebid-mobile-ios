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

@objcMembers
public class SkadnParametersManager: NSObject {
    
    private static func getFidelity(from skadnInfo: PBMORTBBidExtSkadn, fidelityType: NSNumber) -> PBMORTBSkadnFidelity? {
        guard let fidelities = skadnInfo.fidelities else { return nil }
        
        for fidelity in fidelities {
            if fidelity.fidelity == fidelityType {
                return fidelity
            }
        }
        return nil
    }
    
    @available(iOS 14.5, *)
    public static func getSkadnImpression(for skadnInfo: PBMORTBBidExtSkadn) -> SKAdImpression? {
        guard let fidelity = SkadnParametersManager.getFidelity(from: skadnInfo, fidelityType: 0) else { return nil }
        
        let imp = SKAdImpression()
        if let itunesitem = skadnInfo.itunesitem,
           let network = skadnInfo.network,
           let campaign = skadnInfo.campaign,
           let sourceapp = skadnInfo.sourceapp,
           let nonce = fidelity.nonce,
           let timestamp = fidelity.timestamp,
           let signature = fidelity.signature {
            imp.sourceAppStoreItemIdentifier = sourceapp
            imp.advertisedAppStoreItemIdentifier = itunesitem
            imp.adNetworkIdentifier = network
            imp.adCampaignIdentifier = campaign
            imp.adImpressionIdentifier = nonce.uuidString
            imp.timestamp = timestamp
            imp.signature = signature
        }
        return nil
    }
    
    public static func getSkadnProductParameters(for skadnInfo: PBMORTBBidExtSkadn) -> Dictionary<String, Any>? {
        if #available(iOS 14.0, *) {
            var productParams = Dictionary<String, Any>()
            
            if let itunesitem = skadnInfo.itunesitem,
               let network = skadnInfo.network,
               let campaign = skadnInfo.campaign,
               let sourceapp = skadnInfo.sourceapp,
               let version = skadnInfo.version {
                productParams[SKStoreProductParameterITunesItemIdentifier] = itunesitem
                productParams[SKStoreProductParameterAdNetworkIdentifier] = network
                productParams[SKStoreProductParameterAdNetworkCampaignIdentifier] = campaign
                productParams[SKStoreProductParameterAdNetworkVersion] = version
                productParams[SKStoreProductParameterAdNetworkSourceAppStoreIdentifier] = sourceapp
                
                // SKAdNetwork 2.0, 2.1
                if let timestamp = skadnInfo.timestamp,
                   let nonce = skadnInfo.nonce,
                   let signature = skadnInfo.signature {
                    productParams[SKStoreProductParameterAdNetworkTimestamp] = timestamp
                    productParams[SKStoreProductParameterAdNetworkNonce] = nonce
                    productParams[SKStoreProductParameterAdNetworkAttributionSignature] = signature
                    
                    return productParams
                }
                
                // >= SKAdNetwork 2.2
                if #available(iOS 14.5, *) {
                    guard let fidelity = SkadnParametersManager.getFidelity(from: skadnInfo, fidelityType: 1) else { return nil }
                    if let timestamp = fidelity.timestamp,
                       let nonce = fidelity.nonce,
                       let signature = fidelity.signature {
                        productParams[SKStoreProductParameterAdNetworkTimestamp] = timestamp
                        productParams[SKStoreProductParameterAdNetworkNonce] = nonce
                        productParams[SKStoreProductParameterAdNetworkAttributionSignature] = signature
                        
                        return productParams
                    }
                }
            }
        }
        return nil
    }
}
