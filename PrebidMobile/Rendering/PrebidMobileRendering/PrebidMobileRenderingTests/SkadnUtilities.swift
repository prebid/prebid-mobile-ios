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

import XCTest

import StoreKit

@testable import PrebidMobileRendering

class SkadnUtilities {
    class func createSkadnExt() -> PBMORTBBidExtSkadn {
        let skadn = PBMORTBBidExtSkadn()
        
        skadn.version = "2.0"
        skadn.network = "cDkw7geQsH.skadnetwork"
        skadn.campaign = 45
        skadn.itunesitem = 123456789
        skadn.nonce = UUID()
        skadn.sourceapp = 880047117
        skadn.timestamp = 1594406341
        skadn.signature = "MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg=="
        skadn.fidelities = nil
        
        return skadn
    }
    
    class func createSkadnExtWithFidelities() -> PBMORTBBidExtSkadn {
        let skadn = PBMORTBBidExtSkadn()
        
        skadn.version = "2.2"
        skadn.network = "cDkw7geQsH.skadnetwork"
        skadn.campaign = 45
        skadn.itunesitem = 123456789
        skadn.sourceapp = 880047117
        let fidelity0 = PBMORTBSkadnFidelity()
        fidelity0.fidelity = 0
        fidelity0.signature = "MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg=="
        fidelity0.nonce = UUID()
        fidelity0.timestamp = 1594406342
        let fidelity1 = PBMORTBSkadnFidelity()
        fidelity1.fidelity = 1
        fidelity1.signature = "MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg=="
        fidelity1.nonce = UUID()
        fidelity1.timestamp = 1594406341
        
        skadn.fidelities = [fidelity0, fidelity1]
        return skadn
    }
    
    @available(iOS 14.0, *)
    class func createSkadnProductParameters(from skadn: PBMORTBBidExtSkadn) -> [String: Any] {
        let fidelity1 = skadn.fidelities!.filter({ $0.fidelity == 1 }).first!
        return [
            SKStoreProductParameterITunesItemIdentifier : skadn.itunesitem!,
            SKStoreProductParameterAdNetworkIdentifier : skadn.network!,
            SKStoreProductParameterAdNetworkCampaignIdentifier : skadn.campaign!,
            SKStoreProductParameterAdNetworkVersion : skadn.version!,
            SKStoreProductParameterAdNetworkSourceAppStoreIdentifier : skadn.sourceapp!,
            SKStoreProductParameterAdNetworkTimestamp : fidelity1.timestamp!,
            SKStoreProductParameterAdNetworkNonce : fidelity1.nonce!.uuidString,
            SKStoreProductParameterAdNetworkAttributionSignature : fidelity1.signature!
        ]
        
    }
    
    @available(iOS 14.5, *)
    class func createSkadImpression(with nonce: UUID) -> SKAdImpression {
        let imp = SKAdImpression()
        imp.sourceAppStoreItemIdentifier = 880047117
        imp.advertisedAppStoreItemIdentifier = 123456789
        imp.adNetworkIdentifier = "cDkw7geQsH.skadnetwork"
        imp.adCampaignIdentifier = 45
        imp.adImpressionIdentifier = nonce.uuidString
        imp.timestamp = 1594406342
        imp.signature = "MEQCIEQlmZRNfYzKBSE8QnhLTIHZZZWCFgZpRqRxHss65KoFAiAJgJKjdrWdkLUOCCjuEx2RmFS7daRzSVZRVZ8RyMyUXg=="
        return imp
    }
}

