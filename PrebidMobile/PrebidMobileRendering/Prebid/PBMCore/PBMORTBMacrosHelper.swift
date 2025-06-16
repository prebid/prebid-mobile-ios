//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    

import Foundation

@objc @_spi(PBMInternal) public
class PBMORTBMacrosHelper: NSObject {
    
    let macroValues: [String : String]
    
    init(bidPrice: NSNumber) {
        macroValues = [
            "AUCTION_PRICE": bidPrice.stringValue,
        ]
    }
        
    @objc public convenience init(bid: Bid) {
        self.init(bidPrice: bid.bid.price)
    }
    
    @objc(replaceMacrosInString:)
    public func replaceMacros(in sourceString: String?) -> String? {
        guard var mutatedString = sourceString else {
            return nil
        }
        
        macroValues.forEach { key, value in
            // replace `${AUCTION_PRICE}`
            mutatedString = mutatedString.replacingOccurrences(of: "${\(key)}", with: value)
            
            // replace `${AUCTION_PRICE:B64}`
            if let base64Value = value.data(using: .utf8)?.base64EncodedString() {
                mutatedString = mutatedString.replacingOccurrences(of: "${\(key):B64}", with: base64Value)
            }
        }
        return mutatedString;
    }
    
}
