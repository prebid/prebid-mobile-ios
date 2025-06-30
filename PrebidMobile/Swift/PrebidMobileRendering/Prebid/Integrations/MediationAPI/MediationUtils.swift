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

@objc(PBMMediationUtils) @objcMembers
public class MediationUtils: NSObject {
     
    public static func isServerParameterInTargetingInfo(_ serverParameter: String, _ targetingInfo: [String]) -> Bool {
        let targetingInfoDictionary = arrayStringToDictionary(dataStringArray: targetingInfo)
        
        return isServerParameterInTargetingInfoDict(serverParameter, targetingInfoDictionary)
    }
    
    public static func isServerParameterInTargetingInfoDict(_ serverParameter: String,
                                                            _ targetingInfoDictionary: [String: String]) -> Bool {
        guard let serverParametersDictionary = stringToDictionary(dataString: serverParameter) else {
            Log.warn("Wrong server parameter format.")
            return false
        }
        
        return isServerParameterDictInTargetingInfoDict(serverParametersDictionary, targetingInfoDictionary)
    }
    
    public static func isServerParameterDictInTargetingInfoDict(_ serverParametersDictionary: [String: String],
                                                                _ targetingInfoDictionary: [String: String]) -> Bool {
        
        guard !serverParametersDictionary.isEmpty else {
            Log.warn("Server parameters dictionary is empty")
            return false
        }
        
        guard !targetingInfoDictionary.isEmpty else {
            Log.warn("Targeting info dictionary is empty")
            return false
        }
        
        for parameter in serverParametersDictionary {
            if targetingInfoDictionary[parameter.key] != parameter.value {
                Log.warn("Server parameter \(parameter.key):\(parameter.value) is absent in targeting info")
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Private Helpers
    
    private static func stringToDictionary(dataString: String) -> [String: String]? {
        let data = Data(dataString.utf8)
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                return json
            }
        } catch let error as NSError {
            Log.error("Failed to load: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    private static func arrayStringToDictionary(dataStringArray: [String]) -> [String: String] {
        var dataStringDictionary = [String: String]()
        
        for dataString in dataStringArray {
            let components = dataString.components(separatedBy: .whitespaces).joined().components(separatedBy: ":")
            dataStringDictionary[components[0]] = components[1...].joined(separator: ":")
        }
        
        return dataStringDictionary
    }
}
