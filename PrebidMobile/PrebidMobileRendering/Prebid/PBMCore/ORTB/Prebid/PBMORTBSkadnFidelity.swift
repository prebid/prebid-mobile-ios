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

@objcMembers
public class PBMORTBSkadnFidelity: PBMORTBAbstract {
    /// The fidelity-type of the attribution to track
    public var fidelity: NSNumber?

    /// SKAdNetwork signature as specified by Apple
    public var signature: String?

    /// An id unique to each ad response. Refer to Apple’s documentation for the proper UUID format requirements
    public var nonce: UUID?

    /// Unix time in millis string used at the time of signature
    public var timestamp: NSNumber?
    
    public override init() {
        super.init()
    }
    
    public override init(jsonDictionary: [String : Any]) {
        fidelity = jsonDictionary[key: "fidelity"]
        nonce = jsonDictionary[key: "nonce", as: String.self].flatMap { UUID(uuidString: $0) }
        timestamp = jsonDictionary[key: "timestamp"]
        signature = jsonDictionary[key: "signature"]
        
        super.init()
    }
    
    public override func toJsonDictionary() -> [String : Any] {
        var ret = [String : Any]()
        
        ret["fidelity"] = fidelity
        ret["nonce"] = nonce?.uuidString
        ret["timestamp"] = timestamp
        ret["signature"] = signature
        
        return ret
    }
}
