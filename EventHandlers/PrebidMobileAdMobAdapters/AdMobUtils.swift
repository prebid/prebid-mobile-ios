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
import GoogleMobileAds
import PrebidMobile

fileprivate let HBKeywordPrefix = "hb_"

@objcMembers
public class AdMobUtils: NSObject {
    public static func initializeGAD() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    
    static func removeHBKeywordsFrom(_ keywords: [String]) -> [String]  {
        return keywords
            .filter { !$0.hasPrefix(HBKeywordPrefix) }
    }
    
    static func buildExtras(configId: String,
                            configIdKey: String,
                            extrasObject: Any?,
                            extrasObjectKey: String) -> [AnyHashable: Any]? {
        var extras = [AnyHashable: Any]()
        extras[configIdKey] = configId
        extras[extrasObjectKey] = extrasObject
        return !extras.isEmpty ? extras : nil
    }
    
    static func buildKeywords(existingKeywords: [Any]?, targetingInfo: [String: String]) -> [Any]? {
        let prebidKeywords = targetingInfo.map { $0 + ":" + $1 }
        if let existingKeywords = existingKeywords, !existingKeywords.isEmpty {
            let joinedKeywords = existingKeywords + prebidKeywords
            return !joinedKeywords.isEmpty ? joinedKeywords : nil
        }
       
        return !prebidKeywords.isEmpty ? prebidKeywords : nil
    }
    
    static func isServerParameterInKeywords(_ serverParameter: String, _ keywords: [String]) -> Bool {
        let keywordsDictionary = arrayStringToDictionary(dataStringArray: keywords)
        return isServerParameterInKeywordsDictionary(serverParameter, keywordsDictionary)
    }
    
    static func isServerParameterInKeywordsDictionary(_ serverParameter: String, _ keywordsDictionary: [String: String]) -> Bool {
        guard let serverParametersDictionary = stringToDictionary(dataString: serverParameter) else {
            Log.info("Wrong server parameter format.")
            return false
        }
        
        guard !serverParametersDictionary.isEmpty else {
            Log.info("Empty server parameter.")
            return false
        }
        
        guard !keywordsDictionary.isEmpty else {
            Log.info("Empty user keywords.")
            return false
        }
        
        for parameter in serverParametersDictionary {
            if keywordsDictionary[parameter.key] != parameter.value {
                Log.info("Server parameter is absent in user keywords.")
                return false
            }
        }
        
        return true
    }
    
    // Private methods
    private static func stringToDictionary(dataString: String) -> [String: String]? {
        let data = Data(dataString.utf8)
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                return json
            }
        } catch let error as NSError {
            Log.info("Failed to load: \(error.localizedDescription)")
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
