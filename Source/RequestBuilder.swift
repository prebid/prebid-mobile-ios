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
            var request: URLRequest = URLRequest(url: URL(string: hostUrl)!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: TimeInterval(Prebid.shared.timeoutMillisDynamic))
            request.httpMethod = "POST"
            let requestBody = openRTBRequestBody(adUnit: adUnit) ?? [:]

            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            //HTTP HeadersExpression implicitly coerced from '[AnyHashable : Any]?' to Any
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            Log.info("Prebid Request post body \(requestBody)")
            return request
    }

    func openRTBRequestBody(adUnit: AdUnit?) -> [AnyHashable: Any]? {
        var requestDict: [AnyHashable: Any] = [:]

        requestDict["id"] = UUID().uuidString
        if let aSource = openrtbSource() {
            requestDict["source"] = aSource
        }
        requestDict["app"] = openrtbApp()
        requestDict["device"] = openrtbDevice(adUnit: adUnit)
        requestDict["regs"] = openrtbRegs()
        requestDict["user"] = openrtbUser(adUnit: adUnit)
        requestDict["imp"] = openrtbImps(adUnit: adUnit)
        requestDict["ext"] = openrtbRequestExtension()

        if let requestDictWithoutEmptyValues = requestDict.getObjectWithoutEmptyValues() {
            requestDict = requestDictWithoutEmptyValues

            if var ext = requestDict["ext"] as? [String: Any],
                var prebid = ext["prebid"] as? [String: Any] {

                prebid["targeting"] = [:]
                var cache: [AnyHashable: Any] = [:]
                cache["bids"] = [AnyHashable: Any]()
                
                if (adUnit is VideoAdUnit || adUnit is VideoInterstitialAdUnit) {
                    cache["vastxml"] = [AnyHashable: Any]()
                }
                prebid["cache"] = cache

                ext["prebid"] = prebid
                requestDict["ext"] = ext
            }
        }

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
        requestPrebidExt["storedrequest"] = ["id": Prebid.shared.prebidServerAccountId]
        requestPrebidExt["data"] = ["bidders": Array(Targeting.shared.getAccessControlList())]

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

        if (adUnit is BannerAdUnit || adUnit is InterstitialAdUnit) {
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

        }
        
        if (adUnit is InterstitialAdUnit || adUnit is VideoInterstitialAdUnit) {
            imp["instl"] = 1
        }

        //to be used when openRTB supports storedRequests
        var prebidAdUnitExt: [AnyHashable: Any] = [:]
        if let anId = adUnit?.prebidConfigId {
            prebidAdUnitExt["storedrequest"] = ["id": anId]
        }

        if !Prebid.shared.storedAuctionResponse.isEmpty {
            prebidAdUnitExt["storedauctionresponse"] = ["id": Prebid.shared.storedAuctionResponse]
        }

        if !Prebid.shared.storedBidResponses.isEmpty {
            var storedBidResponses: [Any] = []

            for(bidder, responseId) in Prebid.shared.storedBidResponses {
                var storedBidResponse: [String: String] = [:]
                storedBidResponse["bidder"] = bidder
                storedBidResponse["id"] = responseId
                storedBidResponses.append(storedBidResponse)
            }

            prebidAdUnitExt["storedbidresponse"] = storedBidResponses
        }

        var adUnitExt: [AnyHashable: Any] = [:]
        adUnitExt["prebid"] = prebidAdUnitExt

        var prebidAdUnitExtContext: [AnyHashable: Any] = [:]
        prebidAdUnitExtContext["keywords"] = adUnit?.getContextKeywordsSet().toCommaSeparatedListString()
        prebidAdUnitExtContext["data"] = adUnit?.getContextDataDictionary().getCopyWhereValueIsArray()

        adUnitExt["context"] = prebidAdUnitExtContext

        imp["ext"] = adUnitExt

        if (adUnit is VideoAdUnit || adUnit is VideoInterstitialAdUnit) {
            var video: [AnyHashable: Any] = [:]
            
            let videoMimes: [String] = ["video/mp4"]
            video["mimes"] = videoMimes
            
            let videoPlaybackMethod: [Int] = [2]
            video["playbackmethod"] = videoPlaybackMethod
            
            let adSize = adUnit!.adSizes[0]
            video["w"] = adSize.width
            video["h"] = adSize.height
            
            let placement: Int?

            switch adUnit {
            case let videoAdUnit as VideoAdUnit:
                placement = videoAdUnit.type.rawValue
            case is VideoInterstitialAdUnit:
                placement = 5
            default: placement = nil
            }

            video["placement"] = placement

            video["linearity"] = 1
            
            imp["video"] = video
        }
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

        var requestAppExt: [AnyHashable: Any] = [:]

        let prebidSdkVersion = Bundle(for: type(of: self)).infoDictionary?["CFBundleShortVersionString"] as? String
        requestAppExt["prebid"] = ["version": prebidSdkVersion, "source": "prebid-mobile"]

        requestAppExt["data"] = Targeting.shared.getContextDataDictionary().getCopyWhereValueIsArray()

        app["ext"] = requestAppExt

        app["keywords"] = Targeting.shared.getContextKeywordsSet().toCommaSeparatedListString()

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

    func openrtbRegs() -> [AnyHashable: Any] {

        var regsDict: [AnyHashable: Any] = [:]
        var ext: [AnyHashable: Any] = [:]

        if Targeting.shared.subjectToGDPR == true {
            ext["gdpr"] = 1
        }
        
        ext["us_privacy"] = StorageUtils.iabCcpa()
        
        regsDict["ext"] = ext

        let coppa = Targeting.shared.subjectToCOPPA
        if coppa == true {
            regsDict["coppa"] = NSNumber(value: coppa).intValue
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

        let globalUserKeywordString = Targeting.shared.getUserKeywordsSet().toCommaSeparatedListString()
        userDict["keywords"] = globalUserKeywordString

        var requestUserExt: [AnyHashable: Any] = [:]

        if Targeting.shared.subjectToGDPR == true {

            if let gdprConsentString = Targeting.shared.gdprConsentString, !gdprConsentString.isEmpty {
                requestUserExt["consent"] = gdprConsentString
            }
        }

        requestUserExt["data"] = Targeting.shared.getUserDataDictionary().getCopyWhereValueIsArray()

        userDict["ext"] = requestUserExt

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

        return deviceExt
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
