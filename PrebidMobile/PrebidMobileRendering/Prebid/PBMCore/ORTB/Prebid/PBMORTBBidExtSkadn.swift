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

//https://github.com/InteractiveAdvertisingBureau/openrtb/blob/master/extensions/community_extensions/skadnetwork.md

@objcMembers
public class PBMORTBBidExtSkadn: PBMORTBAbstract {
    /// Version of SKAdNetwork desired. Must be 2.0 or above
    public var version: String?
    
    /// Ad network identifier used in signature
    public var network: String?
    
    /// Campaign ID compatible with Apple’s spec
    public var campaign: NSNumber?
    
    /// A four-digit integer that ad networks define to represent the ad campaign. Used in SKAdNetwork 4.0+,
    /// replaces Campaign ID `campaign`. DSPs must generate signatures in 4.0+ using the Source Identifier.
    public var sourceidentifier: String?
    
    /// ID of advertiser’s app in Apple’s app store
    public var itunesitem: NSNumber?
    
    /// ID of publisher’s app in Apple’s app store
    public var sourceapp: NSNumber?
    
    /// Supports multiple fidelity types introduced in SKAdNetwork v2.2
    public var fidelities: [PBMORTBSkadnFidelity]?
    
    /// SKOverlay Support
    public var skoverlay: PBMORTBBidExtSkadnSKOverlay?
    
    //Placeholder for exchange-specific extensions to OpenRTB.
    //Note: ext object not supported.
    
    public override init() {
        super.init()
    }
    
    public override init(jsonDictionary: [String : Any]) {
        version = jsonDictionary[key: "version"]
        network = jsonDictionary[key: "network"]
        campaign = jsonDictionary[key: "campaign"]
        itunesitem = jsonDictionary[key: "itunesitem"]
        sourceapp = jsonDictionary[key: "sourceapp"]
        sourceidentifier = jsonDictionary[key: "sourceidentifier"]
        fidelities = jsonDictionary.array(key: "fidelities", ofEntity: PBMORTBSkadnFidelity.self)
        skoverlay = jsonDictionary.entity(key: "skoverlay")
        
        super.init()
    }
    
    public override func toJsonDictionary() -> [String : Any] {
        var ret = [String : Any]()
        
        ret["version"] = version
        ret["network"] = network
        ret["campaign"] = campaign
        ret["itunesitem"] = itunesitem
        ret["sourceapp"] = sourceapp
        ret["sourceidentifier"] = sourceidentifier
        ret["fidelities"] = fidelities?.compactMap { $0.toJsonDictionary().nilIfEmpty }.nilIfEmpty
        ret["skoverlay"] = skoverlay?.toJsonDictionary().nilIfEmpty
        
        return ret
    }
}
