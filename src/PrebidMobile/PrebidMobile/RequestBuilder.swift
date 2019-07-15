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
import CoreTelephony
import CoreLocation
import WebKit
import AdSupport

@objcMembers public class RequestBuilder: NSObject {
    /**
     * The class is created as a singleton object & used
     */
    static let shared = RequestBuilder()

    static var myUserAgent: String = ""

    /**
     * The initializer that needs to be created only once
     */
    private override init() {

        super.init()
    }

    func buildPrebidRequest(adUnit: AdUnit?, callback:@escaping(_ urlRequest: URLRequest?) throws -> Void) throws {
        do {
            try callback(self.buildRequest(adUnit: adUnit))

        } catch let error {
            throw error
        }
    }

    func buildRequest(adUnit: AdUnit?) throws -> URLRequest? {

            let hostUrl: String = try Host.shared.getHostURL(host: Prebid.shared.prebidServerHost)
        var request: URLRequest = URLRequest(url: URL(string: hostUrl)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: TimeInterval(Prebid.shared.timeoutMillis))
            request.httpMethod = "POST"
            let requestBody: [String: Any] = openRTBRequestBody(adUnit: adUnit)!

            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            //HTTP HeadersExpression implicitly coerced from '[AnyHashable : Any]?' to Any
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            Log.info("Prebid Request post body \(requestBody)")
            return request
    }

    func openRTBRequestBody(adUnit: AdUnit?) -> [String: Any]? {
        var requestDict: [String: Any] = [:]

        requestDict["id"] = UUID().uuidString
        if let aSource = openrtbSource() {
            requestDict["source"] = aSource
        }
        requestDict["app"] = openrtbApp()
        requestDict["device"] = openrtbDevice(adUnit: adUnit)
        if Targeting.shared.subjectToGDPR == true {
            requestDict["regs"] = openrtbRegs()
        }
        requestDict["user"] = openrtbUser(adUnit: adUnit)
        requestDict["imp"] = openrtbImps(adUnit: adUnit)
        requestDict["ext"] = openrtbRequestExtension()

        return requestDict
    }

    func openrtbSource() -> [String: Any]? {

        let uuid = UUID().uuidString
        var sourceDict: [String: Any] = [:]
        sourceDict["tid"] = uuid

        return sourceDict
    }

    func openrtbRequestExtension() -> [AnyHashable: Any]? {
        var requestPrebidExt: [AnyHashable: Any] = [:]
        requestPrebidExt["targeting"] = [:]
        requestPrebidExt["storedrequest"] = ["id": Prebid.shared.prebidServerAccountId]
        requestPrebidExt["cache"] = ["bids": [AnyHashable: Any]()]
        var requestExt: [AnyHashable: Any] = [:]
        requestExt["prebid"] = requestPrebidExt
        return requestExt
    }

    func openrtbImps(adUnit: AdUnit?) -> [Any]! {
        var imps: [Any] = []

        var imp: [AnyHashable: Any] = [:]
        if let anIdentifier = adUnit?.identifier {
            imp["id"] = anIdentifier
        }

        imp["secure"] = 1

        var sizeArray = [[String: CGFloat]]()
        for size: CGSize in (adUnit?.adSizes)! {
            let sizeDict = [
                "w": size.width,
                "h": size.height
            ]
            sizeArray.append(sizeDict)
        }
        let formats = ["format": sizeArray]
        imp["banner"] = formats

        if (adUnit is InterstitialAdUnit) {
            imp["instl"] = 1
        }

        //to be used when openRTB supports storedRequests
        var prebidAdUnitExt: [AnyHashable: Any] = [:]
        if let anId = adUnit?.prebidConfigId {
            prebidAdUnitExt["storedrequest"] = ["id": anId]
        }

        var adUnitExt: [AnyHashable: Any] = [:]
        adUnitExt["prebid"] = prebidAdUnitExt

        imp["ext"] = adUnitExt

        imps.append(imp)

        return imps
    }

    // OpenRTB 2.5 Object: App in section 3.2.14

    func openrtbApp() -> [AnyHashable: Any]? {
        var app: [AnyHashable: Any] = [:]

        let itunesID: String? = Targeting.shared.itunesID
        let bundle = Bundle.main.bundleIdentifier
        if itunesID != nil {
            app["bundle"] = itunesID
        } else if bundle != nil {
            app["bundle"] = bundle ?? ""
        }

        let version: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        if version != "" {
            app["ver"] = version
        }

        app["publisher"] = ["id": Prebid.shared.prebidServerAccountId ?? 0] as NSDictionary

        let prebidSdkVersion = Bundle(for: type(of: self)).infoDictionary?["CFBundleShortVersionString"] as? String
        app["ext"] = ["prebid": ["version": prebidSdkVersion, "source": "prebid-mobile"]]
        
        if let storeUrl = Targeting.shared.storeURL, !storeUrl.isEmpty {
            app["storeurl"] = storeUrl
        }
        
        if let domain = Targeting.shared.domain, !domain.isEmpty {
            app["domain"] = domain
        }

        return app
    }

    // OpenRTB 2.5 Object: Device in section 3.2.18

    func openrtbDevice(adUnit: AdUnit?) -> [AnyHashable: Any]? {
        var deviceDict: [AnyHashable: Any] = [:]

        if (RequestBuilder.myUserAgent != "") {
            deviceDict["ua"] = RequestBuilder.myUserAgent
        }

        deviceDict["geo"] = openrtbGeo()

        deviceDict["make"] = "Apple"
        deviceDict["os"] = "iOS"
        deviceDict["osv"] = UIDevice.current.systemVersion
        deviceDict["h"] = UIScreen.main.bounds.size.height
        deviceDict["w"] = UIScreen.main.bounds.size.width

        let deviceModel = UIDevice.current.modelName
        if deviceModel != "" {
            deviceDict["model"] = deviceModel
        }
        let netinfo = CTTelephonyNetworkInfo()
        let carrier: CTCarrier? = netinfo.subscriberCellularProvider

        if (carrier?.carrierName?.count ?? 0) > 0 {
            deviceDict["carrier"] = carrier?.carrierName ?? ""
        }

        let reachability: Reachability = Reachability()!
        var connectionType: Int = 0
        if (reachability.connection == .wifi) {
            connectionType = 1
        } else if (reachability.connection == .cellular) {
            connectionType = 2
        }

        deviceDict["connectiontype"] = connectionType

        if (carrier?.mobileCountryCode?.count ?? 0) > 0 && (carrier?.mobileNetworkCode?.count ?? 0) > 0 {
            deviceDict["mccmnc"] = carrier?.mobileCountryCode ?? "" + ("-") + (carrier?.mobileNetworkCode ?? "")
        }
        let lmtAd: Bool = !ASIdentifierManager.shared().isAdvertisingTrackingEnabled
        // Limit ad tracking
        deviceDict["lmt"] = NSNumber(value: lmtAd).intValue

        let deviceId = RequestBuilder.DeviceUUID()
        if deviceId != "" {
            deviceDict["ifa"] = deviceId
        }

        let timeInMiliseconds = Int(Date().timeIntervalSince1970)
        deviceDict["devtime"] = timeInMiliseconds

        let pixelRatio: CGFloat = UIScreen.main.scale

        deviceDict["pxratio"] = pixelRatio
        
        if let deviceExt = self.fetchDeviceExt(adUnit: adUnit) {
            deviceDict["ext"] = deviceExt
        }

        return deviceDict

    }

    // OpenRTB 2.5 Object: Geo in section 3.2.19

    func openrtbGeo() -> [AnyHashable: Any]? {

        if Location.shared.location != nil {
            var geoDict: [AnyHashable: Any] = [:]
            let latitude = Location.shared.location?.coordinate.latitude
            let longitude = Location.shared.location?.coordinate.longitude

            geoDict["lat"] = latitude ?? 0.0
            geoDict["lon"] = longitude ?? 0.0

            let locationTimestamp: Date? = Location.shared.location?.timestamp
            let ageInSeconds: TimeInterval = -1.0 * (locationTimestamp?.timeIntervalSinceNow ?? 0.0)
            let ageInMilliseconds = Int64(ageInSeconds * 1000)

            geoDict["lastfix"] = ageInMilliseconds
            geoDict["accuracy"] = Int(Location.shared.location?.horizontalAccuracy ?? 0)

            return geoDict
        }
        return nil
    }

    func openrtbRegs() -> [AnyHashable: Any]? {

        var regsDict: [AnyHashable: Any] = [:]

        let gdpr: Bool? = Targeting.shared.subjectToGDPR

        if (gdpr != nil) {
            regsDict["ext"] = ["gdpr": NSNumber(value: gdpr!).intValue] as NSDictionary
        }
        return regsDict
    }

    // OpenRTB 2.5 Object: User in section 3.2.20
    func openrtbUser(adUnit: AdUnit?) -> [AnyHashable: Any]? {
        var userDict: [AnyHashable: Any] = [:]

        let yob = Targeting.shared.yearOfBirth
        if yob > 0 {
            userDict["yob"] = yob
        }

        let genderValue: Gender = Targeting.shared.gender
        var gender: String
        switch genderValue {
        case .male:
            gender = "M"
        case .female:
            gender = "F"
        default:
            gender = "O"
        }
        userDict["gender"] = gender

        let targetingUserParams = adUnit?.userKeywords

        let userKeywordString = fetchKeywordsString(targetingUserParams)

        if !(userKeywordString == "") {
            userDict["keywords"] = userKeywordString
        }

        if Targeting.shared.subjectToGDPR == true {

            let consentString = Targeting.shared.gdprConsentString
            if (consentString != nil && consentString != .EMPTY_String) {
                userDict["ext"] = ["consent": consentString]
            }
        }
        return userDict
    }

    class func precisionNumberFormatter() -> NumberFormatter? {
        var precisionNumberFormatterToken: Int = 0
        var precisionNumberFormatter: NumberFormatter?
        if (precisionNumberFormatterToken == 0) {
            precisionNumberFormatter = NumberFormatter()
            precisionNumberFormatter?.locale = NSLocale(localeIdentifier: "en_US") as Locale
        }
        precisionNumberFormatterToken = 1
        return precisionNumberFormatter
    }

    func fetchKeywordsString(_ kewordsDictionary: [AnyHashable: Any]?) -> String? {

        var keywordString = ""

        for (key, dictValues) in (kewordsDictionary)! {

            let values = dictValues as? [String?]

            for value in values! {

                let keyvalue = "\(key)=\(value!)"

                if (keywordString != "") {
                    keywordString = "\(keywordString),\(keyvalue)"
                } else {
                    keywordString = keyvalue
                }
            }
        }

        return keywordString
    }
    
    func fetchDeviceExt(adUnit: AdUnit?) -> [AnyHashable: Any]? {
        
        var deviceExt: [AnyHashable: Any] = [:]
        var deviceExtPrebid: [AnyHashable: Any] = [:]
        var deviceExtPrebidInstlDict: [AnyHashable: Any] = [:]
        
        if let adUnit = adUnit as? InterstitialAdUnit {
            deviceExtPrebidInstlDict["minwidthperc"] = adUnit.minSizePerc?.width
            deviceExtPrebidInstlDict["minheightperc"] = adUnit.minSizePerc?.height
        }
        
        deviceExtPrebid["interstitial"] = deviceExtPrebidInstlDict
        deviceExt["prebid"] = deviceExtPrebid
        
        let deviceExtWithoutEmptyValues = deviceExt.getObjectWithoutEmptyValues()
        return deviceExtWithoutEmptyValues
    }

    class func UserAgent(callback:@escaping(_ userAgentString: String) -> Void) {

        var wkUserAgent: String = ""
        let myGroup = DispatchGroup()

        let window = UIApplication.shared.keyWindow
        let webView = WKWebView(frame: UIScreen.main.bounds)
        webView.isHidden = true
        window?.addSubview(webView)
        myGroup.enter()
        webView.loadHTMLString("<html></html>", baseURL: nil)
        webView.evaluateJavaScript("navigator.userAgent", completionHandler: { (userAgent, _) in
            wkUserAgent = userAgent as! String
            webView.stopLoading()
            webView.removeFromSuperview()
            myGroup.leave()

        })
        myGroup.notify(queue: .main) {
            callback(wkUserAgent)
        }

    }

    class func DeviceUUID() -> String {
        var uuidString: String = ""

        if (uuidString == "") {
            let advertisingIdentifier: String = ASIdentifierManager.shared().advertisingIdentifier.uuidString

            if (advertisingIdentifier != .kIFASentinelValue) {
                uuidString = advertisingIdentifier
            }
        }

        return uuidString
    }

}
