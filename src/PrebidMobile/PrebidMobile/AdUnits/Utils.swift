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
import WebKit

public class Utils: NSObject {

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

@objc public func removeHBKeywords (adObject: AnyObject) {

    let adServerObject: String = String(describing: type(of: adObject))
    if (adServerObject == .DFP_Object_Name || adServerObject == .DFP_O_Object_Name || 
        adServerObject == .DFP_N_Object_Name || adServerObject == .GAD_N_Object_Name || 
        adServerObject == .GAD_Object_Name) {
        let hasDFPMember = adObject.responds(to: NSSelectorFromString("setCustomTargeting:"))
        if (hasDFPMember) {
            //check if the publisher has added any custom targeting. If so then merge the bid keywords to the same.
            if (adObject.value(forKey: "customTargeting") != nil) {
                var existingDict: [String: Any] = adObject.value(forKey: "customTargeting") as! [String: Any]
                for (key, _)in existingDict {
                    if (key.starts(with: "hb_")) {
                        existingDict[key] = nil
                    }
                }
                adObject.setValue( existingDict, forKey: "customTargeting")
            }
        }
    }

    if (adServerObject == .MoPub_Object_Name || adServerObject == .MoPub_Interstitial_Name) {
        let hasMoPubMember = adObject.responds(to: NSSelectorFromString("setKeywords:"))

        if (hasMoPubMember) {
            //for mopub the keywords has to be set as a string seperated by ,
            // split the dictionary & construct a string comma separated
            if (adObject.value(forKey: "keywords") != nil) {
                let targetingKeywordsString: String = adObject.value(forKey: "keywords") as! String

                let commaString: String = ","
                if (targetingKeywordsString != "") {
                    var keywordsArray = targetingKeywordsString.components(separatedBy: ",")
                    var i = 0
                    var newString: String = ""
                    while i < keywordsArray.count {
                        if (!keywordsArray[i].starts(with: "hb_")) {

                            if ( newString == .EMPTY_String) {
                                newString = keywordsArray[i]
                            } else {
                                newString += commaString + keywordsArray[i]
                            }
                        }

                        i += 1
                    }

                    Log.info("MoPub targeting keys are \(newString)")
                    adObject.setValue( newString, forKey: "keywords")


                }
            }

        }

    }
}
    
    public func resizeAdManagerBannerAdView(_ adView: UIView, completion: @escaping (CGSize?) -> Void) {
        
        let view = self.recursivelyFindWebView(adView) { (subView) -> Bool in
            return subView is WKWebView || subView is UIWebView
        }
        
        if let wkWebView = view as? WKWebView  {
            Log.debug("prebid resize, subView is WKWebView")
            self.findSizeInWebViewAsync(wkWebView: wkWebView, completion: completion)
            
        } else if let uiWebView = view as? UIWebView {
            Log.debug("prebid resize, subView is UIWebView")
            self.findSizeInWebViewAsync(uiWebView: uiWebView, completion: completion)
        } else {
            Log.warn("prebid resize, subView doesn't include WebView")
        }
       
    }
    
    func runResizeCompletion(size: CGSize?, completion: @escaping (CGSize?) -> Void) {
        guard let size = size else {
            Log.warn("prebid resize, size is nil")
            return
        }
        
        Log.debug("prebid resize, size:\(size)")
        completion(size)
    }
    
    func recursivelyFindWebView(_ view: UIView, closure:(UIView) -> Bool) -> UIView? {
        for subview in view.subviews {
            
            if closure(subview)  {
                return subview
            }
            
            if let result = recursivelyFindWebView(subview, closure: closure) {
                return result
            }
        }
        
        return nil
    }
    
    func findSizeInWebViewAsync(wkWebView: WKWebView, completion: @escaping (CGSize?) -> Void) {
        
        wkWebView.evaluateJavaScript("document.body.innerHTML", completionHandler: { (value: Any!, error: Error!) -> Void in
            
            if error != nil {
                Log.warn("prebid resize, error:\(error.localizedDescription)")
                return
            }

            let wkResult = self.findSizeInJavaScript(jsCode: value as? String)
            
            self.runResizeCompletion(size: wkResult, completion: completion)
        })
        
    }
    
    func findSizeInWebViewAsync(uiWebView: UIWebView, completion: @escaping (CGSize?) -> Void) {
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
        
            guard uiWebView.isLoading else {
                return
            }
            
            timer.invalidate()
            let content = uiWebView.stringByEvaluatingJavaScript(from: "document.body.innerHTML")
            
            let uiResult = self.findSizeInJavaScript(jsCode: content)
            self.runResizeCompletion(size: uiResult, completion: completion)
            
        }

    }
    
    func findSizeInJavaScript(jsCode: String?) -> CGSize? {
        guard let jsCode = jsCode else {
            Log.warn("prebid resize, jsCode is nil")
            return nil
        }
        
        guard let hbSizeKeyValue = findHbSizeKeyValue(in: jsCode) else {
            Log.warn("prebid resize, HbSizeKeyValue is nil")
            return nil
        }
            
        guard let hbSizeValue = findHbSizeValue(in: hbSizeKeyValue) else {
            Log.warn("prebid resize, HbSizeValue is nil")
            return nil
        }
        
        return stringToCGSize(hbSizeValue)
    }
    
    func findHbSizeKeyValue(in text: String) -> String?{
        return matchAndCheck(regex: "hb_size\\W+[0-9]+x[0-9]+", text: text)
    }
    
    func findHbSizeValue(in hbSizeKeyValue: String) -> String?{
        return matchAndCheck(regex: "[0-9]+x[0-9]+", text: hbSizeKeyValue)
    }
    
    func matchAndCheck(regex: String, text: String) -> String?{
        let matched = matches(for: regex, in: text)
        
        if matched.isEmpty {
            return nil
        }
        
        let firstResult = matched[0]
        
        return firstResult
    }
    
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            Log.warn("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func stringToCGSize(_ size: String) -> CGSize? {
        
        let sizeArr = size.split{$0 == "x"}.map(String.init)
        guard sizeArr.count == 2 else {
            Log.warn("\(size) has a wrong format")
            return nil
        }
        
        let nsNumberWidth = NumberFormatter().number(from: sizeArr[0])
        let nsNumberHeight = NumberFormatter().number(from: sizeArr[1])
        
        guard let numberWidth = nsNumberWidth, let numberHeight = nsNumberHeight else {
            Log.warn("\(size) can not be converted to CGSize")
            return nil
        }
        
        let width = CGFloat(truncating: numberWidth)
        let height = CGFloat(truncating: numberHeight)
        
        let gcSize = CGSize(width: width, height: height)
        
        return gcSize
    }

@objc func validateAndAttachKeywords (adObject: AnyObject, bidResponse: BidResponse) {

    let adServerObject: String = String(describing: type(of: adObject))
    if (adServerObject == .DFP_Object_Name || adServerObject == .DFP_O_Object_Name || 
        adServerObject == .DFP_N_Object_Name || adServerObject == .GAD_N_Object_Name || 
        adServerObject == .GAD_Object_Name) {
        let hasDFPMember = adObject.responds(to: NSSelectorFromString("setCustomTargeting:"))
        if (hasDFPMember) {
            //check if the publisher has added any custom targeting. If so then merge the bid keywords to the same.
            if (adObject.value(forKey: "customTargeting") != nil) {
                var existingDict: [String: Any] = adObject.value(forKey: "customTargeting") as! [String: Any]
                existingDict.merge(dict: bidResponse.customKeywords)
                adObject.setValue( existingDict, forKey: "customTargeting")
            } else {
                adObject.setValue( bidResponse.customKeywords, forKey: "customTargeting")
            }

            return
        }
    }

    if (adServerObject == .MoPub_Object_Name || adServerObject == .MoPub_Interstitial_Name) {
        let hasMoPubMember = adObject.responds(to: NSSelectorFromString("setKeywords:"))

        if (hasMoPubMember) {
            //for mopub the keywords has to be set as a string seperated by ,
            // split the dictionary & construct a string comma separated
            var targetingKeywordsString: String = ""
            //get the publisher set keywords & append the bid keywords to the same

            if let keywordsString = (adObject.value(forKey: "keywords") as? String) {
                targetingKeywordsString = keywordsString
            }

            let commaString: String = ","

            for (key, value) in bidResponse.customKeywords {
                if ( targetingKeywordsString == .EMPTY_String) {
                    targetingKeywordsString = key + ":" + value
                } else {
                    targetingKeywordsString += commaString + key + ":" + value
                }

            }

            Log.info("MoPub targeting keys are \(targetingKeywordsString)")
            adObject.setValue( targetingKeywordsString, forKey: "keywords")

        }

    }

}

}
