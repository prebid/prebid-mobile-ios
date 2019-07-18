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
    @objc
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

    private static let innerHtmlScript = "document.body.innerHTML"
    private static let sizeValueRegexExpression = "[0-9]+x[0-9]+"
    private static let sizeKeyValueRegexExpression = "hb_size\\W+\(sizeValueRegexExpression)" //"hb_size\\W+[0-9]+x[0-9]+"

    @objc
    public func findPrebidCreativeSize(_ adView: UIView, success: @escaping (CGSize) -> Void, failure: @escaping (Error) -> Void) {
        
        let view = self.findWebView(adView) { (subView) -> Bool in
            return isWebView(subView)
        }
        
        if let wkWebView = view as? WKWebView  {
            Log.debug("subView is WKWebView")
            self.findSizeInWebViewAsync(wkWebView: wkWebView, success: success, failure: failure)
            
        } else if let uiWebView = view as? UIWebView {
            Log.debug("subView is UIWebView")
            self.findSizeInWebViewAsync(uiWebView: uiWebView, success: success, failure: failure)
        } else {
            warnAndTriggerFailure(.prebidFindSizeErrorNoWebView, failure: failure)
        }
    }
    
    @available(iOS, deprecated, message: "Please migrate to - findPrebidCreativeSize(_:success:failure:)")
    public func findPrebidCreativeSize(_ adView: UIView, completion: @escaping (CGSize?) -> Void) {
        
        findPrebidCreativeSize(adView, success: completion) { (error) in
            Log.warn("Missing failure handler, please migrate to - findPrebidCreativeSize(_:success:failure:)")
            completion(nil) // backwards compatibility
        }
       
    }
    
    func warnAndTriggerFailure(_ error: PrebidFindSizeError, failure: (Error) -> Void) {
        let description = error.name()
        Log.warn(description)
        
        let error = NSError(domain: "com.prebidmobile", code: error.errorCode, userInfo: [NSLocalizedDescriptionKey: description])
        failure(error)
    }
    
    func findWebView(_ view: UIView, closure:(UIView) -> Bool) -> UIView? {
        if closure(view)  {
            return view
        } else {
            return recursivelyFindWebView(view, closure: closure)
        }
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
    
    func findSizeInWebViewAsync(wkWebView: WKWebView, success: @escaping (CGSize) -> Void, failure: @escaping (Error) -> Void) {
        
        wkWebView.evaluateJavaScript(Utils.innerHtmlScript, completionHandler: { (value: Any!, error: Error!) -> Void in
            
            if error != nil {
                self.warnAndTriggerFailure(.prebidFindSizeErrorWKWebView(message: error.localizedDescription), failure: failure)
                return
            }

            self.findSizeInHTML(body: value as? String, success: success, failure: failure)
        })
        
    }
    
    func findSizeInWebViewAsync(uiWebView: UIWebView, success: @escaping (CGSize) -> Void, failure: @escaping (Error) -> Void) {

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            
            if uiWebView.isLoading {
                self.findSizeInWebViewAsync(uiWebView: uiWebView, success: success, failure: failure)
            } else {

                let content = uiWebView.stringByEvaluatingJavaScript(from: Utils.innerHtmlScript)

                self.findSizeInHTML(body: content, success: success, failure: failure)
            }
        }

    }
    
    func findSizeInHTML(body: String?, success: @escaping (CGSize) -> Void, failure: @escaping (Error) -> Void) {
        guard let htmlBody = body, !htmlBody.isEmpty else {
            self.warnAndTriggerFailure(.prebidFindSizeErrorNoHTML, failure: failure)
            return
        }
        
        guard let hbSizeObject = findHbSizeObject(in: htmlBody) else {
            warnAndTriggerFailure(.prebidFindSizeErrorNoKeyValue, failure: failure)
            return
        }
            
        guard let hbSizeValue = findHbSizeValue(in: hbSizeObject) else {
            warnAndTriggerFailure(.prebidFindSizeErrorNoValue, failure: failure)
            return
        }
        
        let maybeSize = stringToCGSize(hbSizeValue)
        if let size = maybeSize {
            success(size)
        } else {
            warnAndTriggerFailure(.prebidFindSizeErrorParsing, failure: failure)
        }
    }
    
    func findHbSizeObject(in text: String) -> String? {
        return matchAndCheck(regex: Utils.sizeKeyValueRegexExpression, text: text)
    }
    
    func findHbSizeValue(in hbSizeObject: String) -> String? {
        return matchAndCheck(regex: Utils.sizeValueRegexExpression, text: hbSizeObject)
    }
    
    func isWebView(_ view: UIView) -> Bool {
        return view is WKWebView || view is UIWebView
    }
    
    func matchAndCheck(regex: String, text: String) -> String? {
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

enum PrebidFindSizeError {
    
    case prebidFindSizeErrorNoWebView
    case prebidFindSizeErrorNoHTML
    case prebidFindSizeErrorUIWebView(message: String)
    case prebidFindSizeErrorWKWebView(message: String)
    case prebidFindSizeErrorNoKeyValue
    case prebidFindSizeErrorNoValue
    case prebidFindSizeErrorParsing
    
    public func name() -> String {
        switch self {
        case .prebidFindSizeErrorNoWebView:
            return "The view doesn't include WebView"
        case .prebidFindSizeErrorNoHTML:
            return "The WebView doesn't have HTML"
        case .prebidFindSizeErrorUIWebView(let message):
            return "UIWebView error:\(message)"
        case .prebidFindSizeErrorWKWebView(let message):
            return "WKWebView error:\(message)"
        case .prebidFindSizeErrorNoKeyValue:
            return "The HTML doesn't contain a size object"
        case .prebidFindSizeErrorNoValue:
            return "The size object doesn't contain a value"
        case .prebidFindSizeErrorParsing:
            return "The size value has a wrong format"
        }
    }
    
    var errorCode: Int {
        switch self {
        case .prebidFindSizeErrorNoWebView:
            return 10
        case .prebidFindSizeErrorNoHTML:
            return 20
        case .prebidFindSizeErrorUIWebView:
            return 30
        case .prebidFindSizeErrorWKWebView:
            return 40
        case .prebidFindSizeErrorNoKeyValue:
            return 50
        case .prebidFindSizeErrorNoValue:
            return 60
        case .prebidFindSizeErrorParsing:
            return 70
        }
    }
    
}
