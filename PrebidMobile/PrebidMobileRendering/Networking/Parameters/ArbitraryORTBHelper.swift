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
    
    private let ortb: String
    
    init(ortb: String) {
        self.ortb = ortb
    }
    
    func getValidatedORTBDict() -> [String : Any]? {
        guard let ortbDict = try? PBMFunctions.dictionaryFromJSONString(ortb) else {
            Log.warn("The provided impression-level ortbConfig object is not valid JSON and will be ignored.")
            return nil
        }
        
        return ortbDict
    }
}

class ArbitraryGlobalORTBHelper: ArbitraryORTBHelperProtocol {
    
    private let ortb: String
    
    struct ProtectedFields {
        
        static var deviceProps: [String] {
            [
                "w" ,"h" ,"lmt", "ifa","make", "model", "os", "osv", "hwv", "language",
                "connectiontype", "mccmnc", "carrier", "ua", "pxratio", "geo"
            ]
        }
        
        static var deviceExtProps: [String] {
            [ "atts", "ifv" ]
        }
        
        static var regsProps: [String] {
            [ "gpp_sid", "gpp", "coppa" ]
        }
        
        static var regsExtProps: [String] {
            [ "gdpr", "us_privacy" ]
        }
        
        static var userProps: [String] {
            [ "geo" ]
        }
        
        static var userExtProps: [String] {
            [ "consent" ]
        }
    }
    
    init(ortb: String) {
        self.ortb = ortb
    }
    
    func getValidatedORTBDict() -> [String : Any]? {
        guard var ortbDict = try? PBMFunctions.dictionaryFromJSONString(ortb) else {
            Log.warn("The provided global-level ortbConfig object is not valid JSON and will be ignored.")
            return nil
        }
        
        ortbDict["regs"] = removeProtectedFields(
            from: ortbDict["regs"] as? [String: Any],
            props: ProtectedFields.regsProps,
            extProps: ProtectedFields.regsExtProps
        )
        
        ortbDict["device"] = removeProtectedFields(
            from: ortbDict["device"] as? [String: Any],
            props: ProtectedFields.deviceProps,
            extProps: ProtectedFields.deviceExtProps
        )
        
        ortbDict["user"] = removeProtectedFields(
            from: ortbDict["user"] as? [String: Any],
            props: ProtectedFields.userProps,
            extProps: ProtectedFields.userExtProps
        )
        
        return ortbDict
    }
    
    private func removeProtectedFields(
        from dict: [String: Any]?,
        props: [String],
        extProps: [String]
    ) -> [String: Any]? {
        guard var dict = dict else { return nil }
        
        if var ext = dict["ext"] as? [String: Any] {
            extProps.forEach { ext[$0] = nil }
            dict["ext"] = ext
        }
        
        props.forEach { dict[$0] = nil }
        return dict
    }
}
