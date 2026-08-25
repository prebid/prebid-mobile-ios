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
    
    private static func getFidelity(from skadnInfo: ORTBBidExtSkadn, fidelityType: NSNumber) -> ORTBSkadnFidelity? {
        guard let fidelities = skadnInfo.fidelities else { return nil }
        
        for fidelity in fidelities {
            if fidelity.fidelity == fidelityType {
                return fidelity
            }
        }
        return nil
    }
    
    /// The ORTB SKAdNetwork extension types these identifiers as strings of digits, so they are
    /// parsed strictly: `Int64` is locale-independent - unlike `NumberFormatter`, which follows
    /// `Locale.current` - and rejects both non-numeric and out-of-range values.
    private static func number(from string: String) -> NSNumber? {
        Int64(string).map { NSNumber(value: $0) }
    }
    
    @available(iOS 14.5, *)
    public static func getSkadnImpression(for skadnInfo: ORTBBidExtSkadn) -> SKAdImpression? {
        guard let fidelity = getFidelity(from: skadnInfo, fidelityType: 0) else { return nil }
        
        let imp = SKAdImpression()
        if let itunesitem = skadnInfo.itunesitem, let numberItunesitem = number(from: itunesitem),
           let network = skadnInfo.network,
           let sourceapp = skadnInfo.sourceapp, let numberSourceapp = number(from: sourceapp),
           let nonce = fidelity.nonce,
           let timestamp = fidelity.timestamp, let numberTimestamp = number(from: timestamp),
           let signature = fidelity.signature,
           let version = skadnInfo.version {
            imp.sourceAppStoreItemIdentifier = numberSourceapp
            imp.advertisedAppStoreItemIdentifier = numberItunesitem
            imp.adNetworkIdentifier = network
            imp.adImpressionIdentifier = nonce
            imp.timestamp = numberTimestamp
            imp.signature = signature
            imp.version = version
            
            if let campaign = skadnInfo.campaign, let numberCampaign = number(from: campaign) {
                imp.adCampaignIdentifier = numberCampaign
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
    
    public static func getSkadnProductParameters(for skadnInfo: ORTBBidExtSkadn) -> Dictionary<String, Any>? {
        // >= SKAdNetwork 2.2
        guard #available(iOS 14.5, *) else { return nil }
        
        // >= SKAdNetwork 2.2
        guard let fidelity = getFidelity(from: skadnInfo, fidelityType: 1) else { return nil }
        
        if let itunesitem = skadnInfo.itunesitem,
           let network = skadnInfo.network,
           let sourceapp = skadnInfo.sourceapp,
           let version = skadnInfo.version,
           let timestamp = fidelity.timestamp,
           let nonce = fidelity.nonce,
           let signature = fidelity.signature {
            
            var productParams = Dictionary<String, Any>()
            
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
        
        return nil
    }
}
