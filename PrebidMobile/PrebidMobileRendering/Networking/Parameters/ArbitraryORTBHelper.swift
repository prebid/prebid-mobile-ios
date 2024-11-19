/*   Copyright 2018-2024 Prebid.org, Inc.

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

protocol ArbitraryORTBHelperProtocol {
    func getValidatedORTBDict() -> [String: Any]?
}

class ArbitraryImpORTBHelper: ArbitraryORTBHelperProtocol {
    
    private let ortb: String?
    
    init(ortb: String?) {
        self.ortb = ortb
    }
    
    func getValidatedORTBDict() -> [String : Any]? {
        guard let ortb else { return nil }
        
        // 1. Validate if JSON string is valid
        guard let ortbDict = try? PBMFunctions.dictionaryFromJSONString(ortb) else {
            Log.warn("The provided impression-level ortbConfig object is not valid JSON and will be ignored.")
            return nil
        }
        
        return ortbDict
    }
}

class ArbitraryGlobalORTBHelper: ArbitraryORTBHelperProtocol {
    
    private let ortb: String?
    
    init(ortb: String?) {
        self.ortb = ortb
    }
    
    func getValidatedORTBDict() -> [String : Any]? {
        guard let ortb else { return nil}
        
        // 1. Validate if JSON string is valid
        guard var ortbDict = try? PBMFunctions.dictionaryFromJSONString(ortb) else {
            Log.warn("The provided global-level ortbConfig object is not valid JSON and will be ignored.")
            return nil
        }
        
        // 2. Remove protected fields
        if var regs = ortbDict["regs"] as? [String: Any] {
            if var regsExt = regs["ext"] as? [String: Any] {
                regsExt["gdpr"] = nil
                regsExt["us_privacy"] = nil
                
                regs["ext"] = regsExt
            }
            
            regs["gpp_sid"] = nil
            regs["gpp"] = nil
            regs["coppa"] = nil
            
            ortbDict["regs"] = regs
        }
        
        if var device = ortbDict["device"] as? [String: Any] {
            if var deviceExt = device["ext"] as? [String: Any] {
                deviceExt["atts"] = nil
                deviceExt["ifv"] = nil
                device["ext"] = deviceExt
            }
            
            if var deviceGeo = device["geo"] as? [String: Any] {
                deviceGeo["lat"] = nil
                deviceGeo["lon"] = nil
                deviceGeo["type"] = nil
                device["geo"] = deviceGeo
            }
            
            device["w"] = nil
            device["h"] = nil
            device["lmt"] = nil
            device["ifa"] = nil
            device["make"] = nil
            device["model"] = nil
            device["os"] = nil
            device["osv"] = nil
            device["hwv"] = nil
            device["language"] = nil
            device["connectiontype"] = nil
            device["mccmnc"] = nil
            device["carrier"] = nil
            device["ua"] = nil
            device["pxratio"] = nil
            
            ortbDict["device"] = device
        }
        
        if var user = ortbDict["user"] as? [String: Any] {
            if var userExt = user["ext"] as? [String: Any] {
                userExt["consent"] = nil
                
                user["ext"] = userExt
                
            }
            
            if var userGeo = user["geo"] as? [String: Any] {
                userGeo["lat"] = nil
                userGeo["lon"] = nil
                user["geo"] = userGeo
            }
            
            ortbDict["user"] = user
        }
        
        return ortbDict
    }
}
