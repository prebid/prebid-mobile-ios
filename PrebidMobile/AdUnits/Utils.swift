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

/// A utility class for handling various ad-related operations and conversions.
public class Utils: NSObject {

    /// The class is created as a singleton object & used
    @objc
    public static let shared = Utils()

    /// The initializer that needs to be created only once
    private override init() {
        super.init()
    }
    
    /// A delegate to handle native ad events.
    @objc
    public weak var delegate: NativeAdDelegate?

    private let DFP_BANNER_VIEW_CLASSNAME = "DFPBannerView"
    private let DFP_WEBADVIEW_CLASSNAME = "GADWebAdView"
    private let MOPUB_NATIVE_AD_CLASSNAME = "MPNativeAd"
    private let DFP_CUSTOM_TEMPLATE_AD_CLASSNAME = "GADNativeCustomTemplateAd"
    private let GAD_CUSTOM_NATIVE_AD = "GADCustomNativeAd"
    private let INNNER_HTML_SCRIPT = "document.body.innerHTML"

    /// Deprecated. MoPub is not available anymore. Use Prebid MAX adapters instead.
    @available(*, deprecated, message: "MoPub is not available anymore. Use Prebid MAX adapters instead.")
    @objc
    public func convertDictToMoPubKeywords(dict: Dictionary<String, String>) -> String {
        return dict.toString(entrySeparator: ",", keyValueSeparator: ":")
        
    }

    func removeHBKeywords (adObject: AnyObject) {

        let adServerObject: String = String(describing: type(of: adObject))
        if (adServerObject == .DFP_Object_Name || adServerObject == .DFP_O_Object_Name ||
            adServerObject == .DFP_N_Object_Name || adServerObject == .GAD_N_Object_Name ||
            adServerObject == .GAD_Object_Name || adServerObject == .GAM_Object_Name) {
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
                        let keywordsArray = targetingKeywordsString.components(separatedBy: ",")
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
        } else if (adServerObject == .MoPub_Request_Name) {
            let hasMoPubMember = adObject.responds(to: NSSelectorFromString("setTargeting:"))

            if (hasMoPubMember) {
                //for mopub the keywords has to be set as a string seperated by ,
                // split the dictionary & construct a string comma separated
                let adTargeting = adObject.value(forKey: "targeting")
                if adTargeting != nil {
                    if let adTargeting = adTargeting{
                        if let targetingKeywordsString = ((adTargeting as AnyObject).value(forKey: "keywords") as? String) {

                            let commaString: String = ","
                            if (targetingKeywordsString != "") {
                                let keywordsArray = targetingKeywordsString.components(separatedBy: ",")
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
                                (adTargeting as AnyObject).setValue( newString, forKey: "keywords")
                                adObject.setValue( adTargeting, forKey: "targeting")
                            }
                        }
                    }
                }

            }
        }
    }

    func validateAndAttachKeywords (adObject: AnyObject, bidResponse: BidResponse) {

        let adServerObject: String = String(describing: type(of: adObject))
        if (adServerObject == .DFP_Object_Name || adServerObject == .DFP_O_Object_Name ||
            adServerObject == .DFP_N_Object_Name || adServerObject == .GAD_N_Object_Name ||
            adServerObject == .GAD_Object_Name || adServerObject == .GAM_Object_Name) {
            let hasDFPMember = adObject.responds(to: NSSelectorFromString("setCustomTargeting:"))
            if (hasDFPMember) {
                //check if the publisher has added any custom targeting. If so then merge the bid keywords to the same.
                if (adObject.value(forKey: "customTargeting") != nil) { 
                    var existingDict: [String: Any] = adObject.value(forKey: "customTargeting") as! [String: Any]
                    existingDict.merge(dict: bidResponse.targetingInfo ?? [:])
                    adObject.setValue( existingDict, forKey: "customTargeting")
                } else {
                    adObject.setValue( bidResponse.targetingInfo, forKey: "customTargeting")
                }

                return
            }
        } else if (adServerObject == .MoPub_Object_Name || adServerObject == .MoPub_Interstitial_Name) {
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

                if let targetingInfo = bidResponse.targetingInfo {
                    for (key, value) in targetingInfo {
                        if ( targetingKeywordsString == .EMPTY_String) {
                            targetingKeywordsString = key + ":" + value
                        } else {
                            targetingKeywordsString += commaString + key + ":" + value
                        }

                    }
                }

                Log.info("MoPub targeting keys are \(targetingKeywordsString)")
                adObject.setValue( targetingKeywordsString, forKey: "keywords")

            }
        } else if (adServerObject == .MoPub_Request_Name) {
            let hasMoPubMember = adObject.responds(to: NSSelectorFromString("setTargeting:"))

            if (hasMoPubMember) {
                //for mopub the keywords has to be set as a string seperated by ,
                // split the dictionary & construct a string comma separated
                var targetingKeywordsString: String = ""
                //get the publisher set keywords & append the bid keywords to the same

                let adTargeting = adObject.value(forKey: "targeting")
                if adTargeting != nil {
                    if let adTargeting = adTargeting {
                        if let keywordsString = ((adTargeting as AnyObject).value(forKey: "keywords") as? String) {
                            targetingKeywordsString = keywordsString
                        }
                    }
                }

                let commaString: String = ","

                if let targetingInfo = bidResponse.targetingInfo {
                    for (key, value) in targetingInfo {
                        if ( targetingKeywordsString == .EMPTY_String) {
                            targetingKeywordsString = key + ":" + value
                        } else {
                            targetingKeywordsString += commaString + key + ":" + value
                        }

                    }
                }

                Log.info("MoPub targeting keys are \(targetingKeywordsString)")

                if adTargeting != nil {
                    if let adTargeting = adTargeting {
                        (adTargeting as AnyObject).setValue( targetingKeywordsString, forKey: "keywords")
                        adObject.setValue( adTargeting, forKey: "targeting")
                    }
                }

            }
        } else if let dictContainer = adObject as? DictionaryContainer<String, String>,
                  let targetingInfo = bidResponse.targetingInfo {
            dictContainer.dict = targetingInfo
        } else if let dict = adObject as? NSMutableDictionary {
            dict.addEntries(from: bidResponse.targetingInfo ?? [:])
        }
    }

    /// Finds a native ad object within a given object.
    ///
    /// - Parameter adObject: The object to search within.
    @objc
    public func findNative(adObject: AnyObject){
        if (self.isObjectFromClass(adObject, DFP_BANNER_VIEW_CLASSNAME)) {
            let dfpBannerView = adObject as! UIView
            findNativeForDFPBannerAdView(dfpBannerView)
        } else if (self.isObjectFromClass(adObject, MOPUB_NATIVE_AD_CLASSNAME)) {
            findNativeForMoPubNativeAd(adObject)
        } else if (self.isObjectFromClass(adObject, DFP_CUSTOM_TEMPLATE_AD_CLASSNAME) || self.isObjectFromClass(adObject, GAD_CUSTOM_NATIVE_AD)) {
            findNativeForDFPCustomTemplateAd(adObject)
        } else {
            delegate?.nativeAdNotFound()
        }
    }

    private func findNativeForDFPCustomTemplateAd(_ dfpCustomAd: AnyObject){
        let isPrebid = dfpCustomAd.string?(forKey: "isPrebid")
        if("1" == isPrebid) {
            if let hb_cache_id_local = dfpCustomAd.string?(forKey: PrebidLocalCacheIdKey), CacheManager.shared.isValid(cacheId: hb_cache_id_local)
            {
                let ad = NativeAd.create(cacheId: hb_cache_id_local)
                if (ad != nil) {
                    delegate?.nativeAdLoaded(ad: ad!)
                    return
                } else {
                    delegate?.nativeAdNotValid()
                    return
                }
            }
        }

        delegate?.nativeAdNotFound()
    }

    private func findNativeForMoPubNativeAd(_ mopub: AnyObject){
        let mopubObject:AnyObject = mopub as! NSObject
        let properties = mopubObject.value(forKey: "properties") as! Dictionary<String, AnyObject>
        let isPrebid = properties["isPrebid"] as? Bool
        if (isPrebid != nil && isPrebid!) {
            if let hb_cache_id_local = properties[PrebidLocalCacheIdKey] as? String, CacheManager.shared.isValid(cacheId: hb_cache_id_local){
                let ad = NativeAd.create(cacheId: hb_cache_id_local)
                if (ad != nil){
                    delegate?.nativeAdLoaded(ad: ad!)
                } else {
                    delegate?.nativeAdNotValid()
                }
            }
        } else {
            delegate?.nativeAdNotFound()
        }
    }
    
    private func isObjectFromClass(_ object: AnyObject, _ className: String) -> Bool{
        let objectClassName = String(describing: type(of: object))
        if objectClassName == className {
            return true
        }
        return false
    }
    
    private func findNativeForDFPBannerAdView(_ view:UIView){
        var array = [UIView]()
        recursivelyFindWebViewList(view, &array)
        if array.count == 0 {
            delegate?.nativeAdNotFound()
        } else {
            self.iterateWebViewListAsync(array, array.count - 1)
        }

    }

    private func iterateWebViewListAsync(_ array: [UIView], _ index: Int){
        let processNextWebView:(Int)->Void = {(i) in
            if i > 0 {
                self.iterateWebViewListAsync(array, i - 1)
            } else {
                self.delegate?.nativeAdNotFound()
            }
        }
        let processHTMLContent:(String)->Void = {(html) in
            if let cacheId = self.getCacheIdFromBody(html), CacheManager.shared.isValid(cacheId: cacheId) {
                let ad = NativeAd.create(cacheId: cacheId)
                if ad != nil {
                    self.delegate?.nativeAdLoaded(ad: ad!)
                } else {
                    self.delegate?.nativeAdNotValid()
                }
            } else {
                processNextWebView(index)
            }
        }
        let gadWebAdView = array[index]
        let controller = gadWebAdView.value(forKey: "webViewController")
        let someController = controller as! NSObject
        let webView = someController.value(forKey: "webView") as! UIView
        if webView is WKWebView {
            let wk = webView as! WKWebView
            wk.evaluateJavaScript(self.INNNER_HTML_SCRIPT, completionHandler: { (value: Any!, error: Error!) -> Void in

                if error != nil {
                    return
                }

                let html = value as! String
                processHTMLContent(html)
            })
        } else {
            processNextWebView(index)
        }
    }

    private func getCacheIdFromBody(_ body: String) -> String? {
        let regex = "\\%\\%Prebid\\%\\%.*\\%\\%Prebid\\%\\%"
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: body, range: NSRange(body.startIndex..., in: body))
            let matched = results.map {
                String(body[Range($0.range, in: body)!])
            }
            if matched.isEmpty {
                return nil
            }
            let firstResult = matched[0]

            return firstResult
        } catch {
            return nil
        }
    }

    private func recursivelyFindWebViewList(_ view:UIView, _ webViewArray:inout [UIView]){
        if(self.isObjectFromClass(view, self.DFP_WEBADVIEW_CLASSNAME)){
            webViewArray.append(view)
        } else {
            for subview in view.subviews {
                recursivelyFindWebViewList(subview, &webViewArray)
            }
        }
    }

    func getStringFromDictionary(_ dic: [String: AnyObject]) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
            let text = String(data: jsonData, encoding: .utf8)
            return text
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }

    func getDictionaryFromString(_ text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                return json
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func getDictionary(from value: Any?) -> [String: Any]? {
          guard let stringValue = value as? String else {
              Log.error("Can't parse given value to string type")
              return nil
          }

          guard let data = stringValue.data(using: .utf8) else {
              Log.error("Can't parse given value to data type")
              return nil
          }

          do {
              let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
              return json
          } catch {
              Log.error(error.localizedDescription)
          }

          return nil
      }
}


/// 1. It is a class that allow use it as AnyObject and passs to - func fetchDemand(adObject: AnyObject, ...)
/// 2. It is not a public class as a result client can not directly pass it to - func fetchDemand(adObject: AnyObject, ...)
class DictionaryContainer<T1: Hashable, T2: Hashable> {
    var dict = [T1 : T2]()
}
