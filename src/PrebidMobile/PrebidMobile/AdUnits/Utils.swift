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

public class Utils : NSObject {
    
    /**
     * The class is created as a singleton object & used
     */
    public static let shared = Utils()
    
    /**
     * The initializer that needs to be created only once
     */
    private override init() {
        super.init()
        
        
    }

@objc public func removeHBKeywords (adObject:AnyObject) {
    
    let adServerObject:String = String(describing: type(of: adObject))
    if(adServerObject == .DFP_O_Object_Name || adServerObject == .DFP_N_Object_Name || adServerObject == .GAD_N_Object_Name){
        let hasDFPMember = adObject.responds(to: NSSelectorFromString("setCustomTargeting:"))
        if(hasDFPMember){
            //check if the publisher has added any custom targeting. If so then merge the bid keywords to the same.
            if(adObject.value(forKey:"customTargeting") != nil){
                var existingDict:[String:Any] = adObject.value(forKey:"customTargeting") as! [String:Any]
                for (key,_)in existingDict {
                    if(key.starts(with:"hb_")){
                        existingDict[key] = nil
                    }
                }
                adObject.setValue( existingDict,forKey:"customTargeting")
            }
        }
    }
    
    if(adServerObject == .MoPub_Object_Name || adServerObject == .MoPub_Interstitial_Name){
        let hasMoPubMember = adObject.responds(to: NSSelectorFromString("setKeywords:"))
        
        if(hasMoPubMember) {
            //for mopub the keywords has to be set as a string seperated by ,
            // split the dictionary & construct a string comma separated
            if(adObject.value(forKey:"keywords") != nil){
                let targetingKeywordsString:String = adObject.value(forKey:"keywords") as! String
                
                let commaString :String = ","
                if(targetingKeywordsString != ""){
                    var keywordsArray = targetingKeywordsString.components(separatedBy: ",")
                    var i = 0
                    var newString:String = ""
                    while i < keywordsArray.count {
                        if(!keywordsArray[i].starts(with:"hb_")){
                            
                            if( newString == .EMPTY_String){
                                newString = keywordsArray[i]
                            } else {
                                newString = newString + commaString + keywordsArray[i]
                            }
                        }
                        
                        i = i+1
                    }
                    DispatchQueue.main.async {
                        Log.info("MoPub targeting keys are \(newString)")
                        adObject.setValue( newString,forKey:"keywords")
                    }
                    
                }
            }
            
            
        }
        
    }
}

@objc func validateAndAttachKeywords (adObject:AnyObject, bidResponse:BidResponse) {
    
    let adServerObject:String = String(describing: type(of: adObject))
    if(adServerObject == .DFP_O_Object_Name || adServerObject == .DFP_N_Object_Name || adServerObject == .GAD_N_Object_Name){
        let hasDFPMember = adObject.responds(to: NSSelectorFromString("setCustomTargeting:"))
        if(hasDFPMember){
            //check if the publisher has added any custom targeting. If so then merge the bid keywords to the same.
            if(adObject.value(forKey:"customTargeting") != nil){
                var existingDict:[String:Any] = adObject.value(forKey:"customTargeting") as! [String:Any]
                existingDict.merge(dict:bidResponse.customKeywords)
                adObject.setValue( existingDict,forKey:"customTargeting")
            } else {
                adObject.setValue( bidResponse.customKeywords,forKey:"customTargeting")
            }
            
            
            return
        }
    }
    
    if(adServerObject == .MoPub_Object_Name || adServerObject == .MoPub_Interstitial_Name){
        let hasMoPubMember = adObject.responds(to: NSSelectorFromString("setKeywords:"))
        
        if(hasMoPubMember) {
            //for mopub the keywords has to be set as a string seperated by ,
            // split the dictionary & construct a string comma separated
            var targetingKeywordsString:String = ""
            //get the publisher set keywords & append the bid keywords to the same
            
            if let keywordsString = (adObject.value(forKey:"keywords") as? String) {
                targetingKeywordsString = keywordsString
            }
            
            let commaString :String = ","
            
            for (key,value) in bidResponse.customKeywords {
                if( targetingKeywordsString == .EMPTY_String){
                    targetingKeywordsString = key + ":" + value
                } else {
                    targetingKeywordsString = targetingKeywordsString + commaString + key + ":" + value
                }
                
            }
            DispatchQueue.main.async {
                Log.info("MoPub targeting keys are \(targetingKeywordsString)")
                adObject.setValue( targetingKeywordsString,forKey:"keywords")
            }
            
            
        }
        
    }
    
}

}
