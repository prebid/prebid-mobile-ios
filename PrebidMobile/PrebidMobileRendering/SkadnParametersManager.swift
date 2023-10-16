/*   Copyright 2018-2019 Prebid.org, Inc.
 
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

@objc(PBMSkadnParametersManager) @objcMembers
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
           let sourceapp = skadnInfo.sourceapp,
           let nonce = fidelity.nonce,
           let timestamp = fidelity.timestamp,
           let signature = fidelity.signature,
           let version = skadnInfo.version {
            imp.sourceAppStoreItemIdentifier = sourceapp
            imp.advertisedAppStoreItemIdentifier = itunesitem
            imp.adNetworkIdentifier = network
            imp.adImpressionIdentifier = nonce.uuidString
            imp.timestamp = timestamp
            imp.signature = signature
            imp.version = version
            
            if let campaign = skadnInfo.campaign {
                imp.adCampaignIdentifier = campaign
            }
            
            // For SKAdNetwork 4.0 add sourceidentifier that replaces campaign
            if #available(iOS 16.1, *) {
                if let sourceidentifier = skadnInfo.sourceidentifier, let sourceidentifierInteger = Int(sourceidentifier) {
                    imp.sourceIdentifier = NSNumber(value: sourceidentifierInteger)
                }
            }
            
            return imp
        }
        
        return nil
    }
    
    public static func getSkadnProductParameters(for skadnInfo: PBMORTBBidExtSkadn) -> Dictionary<String, Any>? {
        // >= SKAdNetwork 2.2
        if #available(iOS 14.5, *) {
            guard let fidelity = SkadnParametersManager.getFidelity(from: skadnInfo, fidelityType: 1) else { return nil }
            
            var productParams = Dictionary<String, Any>()
            
            if let itunesitem = skadnInfo.itunesitem,
               let network = skadnInfo.network,
               let sourceapp = skadnInfo.sourceapp,
               let version = skadnInfo.version,
               let timestamp = fidelity.timestamp,
               let nonce = fidelity.nonce,
               let signature = fidelity.signature {
                
                if let campaign = skadnInfo.campaign {
                    productParams[SKStoreProductParameterAdNetworkCampaignIdentifier] = campaign
                }
                
                if #available(iOS 16.1, *) {
                    if let sourceIdentifier = skadnInfo.sourceidentifier, let sourceidentifierInteger = Int(sourceIdentifier) {
                        productParams[SKStoreProductParameterAdNetworkSourceIdentifier] = NSNumber(value: sourceidentifierInteger)
                    }
                }
                
                productParams[SKStoreProductParameterITunesItemIdentifier] = itunesitem
                productParams[SKStoreProductParameterAdNetworkIdentifier] = network
                productParams[SKStoreProductParameterAdNetworkVersion] = version
                productParams[SKStoreProductParameterAdNetworkSourceAppStoreIdentifier] = sourceapp
                productParams[SKStoreProductParameterAdNetworkTimestamp] = timestamp
                productParams[SKStoreProductParameterAdNetworkNonce] = nonce
                productParams[SKStoreProductParameterAdNetworkAttributionSignature] = signature
                
                return productParams
            }
        }
        return nil
    }
}
