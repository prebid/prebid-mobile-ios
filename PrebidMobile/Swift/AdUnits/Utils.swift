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
import CoreLocation

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
    private let INNNER_HTML_SCRIPT = "document.body.innerHTML"

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
        } else if (self.isObjectFromClass(adObject, DFP_CUSTOM_TEMPLATE_AD_CLASSNAME) || self.isObjectFromClass(adObject, .GAD_Object_Custom_Native_Name)) {
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
    
    /**
     Rounds geographic coordinates to a specified decimal precision.
     
     This method rounds both latitude and longitude values to the specified number of decimal places.
     For example, with precision 2, coordinates (37.7749, -122.4194) become (37.77, -122.42).
     
     - Parameters:
       - coordinates: The geographic coordinates to round (latitude: -90 to 90, longitude: -180 to 180)
       - precision: The number of decimal places to round to. Must be non-negative.
                    - 0: Round to whole numbers (e.g., 37.8 -> 38.0)
                    - 1: Round to 1 decimal place (e.g., 37.7749 -> 37.8)
                    - 2: Round to 2 decimal places (e.g., 37.7749 -> 37.77)
                    - nil: Return original coordinates unchanged
     
     - Returns: A new CLLocationCoordinate2D with rounded values, or the original coordinates if:
                - precision is nil
                - precision is negative
                - coordinates are invalid (outside valid ranges)
                - precision results in infinite or zero multiplier
                - rounded values are not finite
     
     - Note: This method uses standard rounding rules (round half up). For example:
             - 37.775 rounds to 37.78 with precision 2
             - 37.774 rounds to 37.77 with precision 2
     
     - Example:
     ```swift
     let utils = Utils.shared
     let coords = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
     let rounded = utils.round(coordinates: coords, precision: NSNumber(value: 2))
     // Result: latitude: 37.77, longitude: -122.42
     ```
     */
    @objc public func round(coordinates : CLLocationCoordinate2D, precision: NSNumber?) -> CLLocationCoordinate2D {
        // Early return if precision is nil or coordinates are invalid
        guard let precision, CLLocationCoordinate2DIsValid(coordinates) else {
            return coordinates
        }
        
        // Return original coordinates for negative precision (invalid input)
        guard precision.doubleValue >= 0 else {
            return coordinates
        }
        
        // Optimized path for precision 0 (rounding to whole numbers)
        if precision.doubleValue == 0 {
            return CLLocationCoordinate2D(
                latitude: coordinates.latitude.rounded(),
                longitude: coordinates.longitude.rounded()
            )
        }
        
        // Calculate multiplier for rounding (e.g., precision 2 -> multiplier 100)
        let multiplier = pow(10.0, precision.doubleValue)
        
        // Guard against edge cases where multiplier becomes 0 or infinite
        guard !multiplier.isZero && multiplier.isFinite else {
            // For cases that result in 0/inf values of multiplier which can lead to unexpected behavior. 
            return coordinates
        }
        
        // Round coordinates using standard rounding (round half up)
        let roundedLat = (coordinates.latitude * multiplier).rounded() / multiplier
        let roundedLon = (coordinates.longitude * multiplier).rounded() / multiplier
        
        // Ensure rounded values are finite (not NaN or infinite)
        guard roundedLat.isFinite, roundedLon.isFinite else {
            return coordinates
        }
        
        return CLLocationCoordinate2D(latitude: roundedLat, longitude: roundedLon)
    }
}


/// 1. It is a class that allow use it as AnyObject and passs to - func fetchDemand(adObject: AnyObject, ...)
/// 2. It is not a public class as a result client can not directly pass it to - func fetchDemand(adObject: AnyObject, ...)
class DictionaryContainer<T1: Hashable, T2: Hashable> {
    var dict = [T1 : T2]()
}
