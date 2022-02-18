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
#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif
class RequestBuilder: NSObject {
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
        let requestBodyJSON = try JSONSerialization.data(withJSONObject: requestBody, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body

        request.httpBody = requestBodyJSON
        //HTTP HeadersExpression implicitly coerced from '[AnyHashable : Any]?' to Any
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        self.setCustomHeaders(request: &request)
        request.httpShouldHandleCookies = isAllowedAccessDeviceData()
        
        let gdprApplies = Targeting.shared.subjectToGDPR
        let deviceAccessConsent = Targeting.shared.getDeviceAccessConsent()
        // HTTP cookies should not be allowed when we do not have deviceAccessConsent
        if ((deviceAccessConsent == nil && (gdprApplies == nil || gdprApplies == true)) || deviceAccessConsent == false) {
            request.httpShouldHandleCookies = false
        }
        
        let stringObject = String.init(data: requestBodyJSON, encoding: String.Encoding.utf8)
        Log.info("Prebid Request post body \(stringObject ?? "nil")")
        
        return request
    }
    
    func setCustomHeaders(request: inout URLRequest) {
        for(headerName, headerValue) in Prebid.shared.customHeaders {
            request.addValue(headerValue, forHTTPHeaderField: headerName)
        }
    }

    func openRTBRequestBody(adUnit: AdUnit?) -> [AnyHashable: Any]? {
        var requestDict: [AnyHashable: Any] = [:]

        requestDict["id"] = UUID().uuidString
        requestDict["source"] = openrtbSource()
        requestDict["app"] = openrtbApp(adUnit: adUnit)
        requestDict["device"] = openrtbDevice(adUnit: adUnit)
        requestDict["regs"] = openrtbRegs()
        requestDict["user"] = openrtbUser(adUnit: adUnit)
        requestDict["imp"] = openrtbImps(adUnit: adUnit)
        requestDict["ext"] = openrtbRequestExtension()
        
        if Prebid.shared.pbsDebug {
            requestDict["test"] = 1
        }

        if let requestDictWithoutEmptyValues = requestDict.getObjectWithoutEmptyValues() {
            requestDict = requestDictWithoutEmptyValues

            if var ext = requestDict["ext"] as? [String: Any],
                var prebid = ext["prebid"] as? [String: Any] {

                prebid["targeting"] = [:]
                var cache: [AnyHashable: Any] = [:]
                cache["bids"] = [AnyHashable: Any]()
                
                if (adUnit is VideoBaseAdUnit) {
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
        
        var extDict: [String: Any] = [:]
        extDict["omidpn"] = Targeting.shared.omidPartnerName
        extDict["omidpv"] = Targeting.shared.omidPartnerVersion
        
        sourceDict["ext"] = extDict

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

        if let nativeRequest = adUnit as? NativeRequest {
            
            imp["native"] = nativeRequest.getNativeRequestObject()
            
        } else if let bannerBaseAdUnit = adUnit as? BannerBaseAdUnit {

            var sizeArray = [[String: CGFloat]]()
            for size: CGSize in (adUnit?.adSizes)! {
                let sizeDict = [
                    "w": size.width,
                    "h": size.height
                ]
                sizeArray.append(sizeDict)
            }
            var banner: [AnyHashable: Any] = [:]
            
            banner["format"] = sizeArray
            
            if let bannerParameters = bannerBaseAdUnit.parameters {
                banner["api"] = bannerParameters.api?.toIntArray()
            }
            
            imp["banner"] = banner

        }
        
        if (adUnit is InterstitialAdUnit || adUnit is VideoInterstitialAdUnit || adUnit is RewardedVideoAdUnit) {
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

        if (adUnit is RewardedVideoAdUnit) {
            prebidAdUnitExt["is_rewarded_inventory"] = 1
        }

        var adUnitExt: [AnyHashable: Any] = [:]
        adUnitExt["prebid"] = prebidAdUnitExt

        var prebidAdUnitExtContext: [AnyHashable: Any] = [:]
        prebidAdUnitExtContext["keywords"] = adUnit?.getContextKeywordsSet().toCommaSeparatedListString()

        var contextData: [AnyHashable: Any] = [:]
        
        contextData = adUnit?.getContextDataDictionary().getCopyWhereValueIsArray() ?? [:]
        contextData["adslot"] = adUnit?.pbAdSlot

        prebidAdUnitExtContext["data"] = contextData
        
        adUnitExt["context"] = prebidAdUnitExtContext

        imp["ext"] = adUnitExt

        if let adUnit = adUnit as? VideoBaseAdUnit {

            var video: [AnyHashable: Any] = [:]
            
            var placementValue: Int?
            
            if let parameters = adUnit.parameters {
                video["api"] = parameters.api?.toIntArray()
                video["maxbitrate"] = parameters.maxBitrate?.value
                video["minbitrate"] = parameters.minBitrate?.value
                video["maxduration"] = parameters.maxDuration?.value
                video["minduration"] = parameters.minDuration?.value
                video["mimes"] = parameters.mimes
                video["playbackmethod"] = parameters.playbackMethod?.toIntArray()
                video["protocols"] = parameters.protocols?.toIntArray()
                video["startdelay"] = parameters.startDelay?.value
                
                placementValue = parameters.placement?.value
            }
            
            let adSize = adUnit.adSizes[0]
            video["w"] = adSize.width
            video["h"] = adSize.height
            
            if (adUnit is VideoInterstitialAdUnit || adUnit is RewardedVideoAdUnit) {
                if (placementValue == nil) {
                    placementValue = 5
                }
            }

            video["placement"] = placementValue

            video["linearity"] = 1
            
            imp["video"] = video
        }
        imps.append(imp)

        return imps
    }

    // OpenRTB 2.5 Object: App in section 3.2.14

    func openrtbApp(adUnit: AdUnit?) -> [AnyHashable: Any]? {
        var app: [AnyHashable: Any] = [:]

        let itunesID: String? = Targeting.shared.itunesID
        let bundle = Bundle.main.bundleIdentifier
        let bundleAppName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        
        if let bundleAppName = bundleAppName {
            app["name"] = bundleAppName
        }
        if itunesID != nil {
            app["bundle"] = itunesID
        } else if bundle != nil {
            app["bundle"] = bundle ?? ""
        }
        app["ver"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        app["publisher"] = ["id": Prebid.shared.prebidServerAccountId] as NSDictionary

        var requestAppExt: [AnyHashable: Any] = [:]

        var prebidSdkVersion: String? = nil
        #if SWIFT_PACKAGE
            prebidSdkVersion = PREBID_VERSION
        #else
            prebidSdkVersion = Bundle(for: type(of: self)).infoDictionary?["CFBundleShortVersionString"] as? String
        #endif
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
        
        if let appContent = adUnit?.getAppContent()?.toJSONDictionary() {
            app["content"] = appContent
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
        
        if (isAllowedAccessDeviceData()) {
            let deviceId = RequestBuilder.DeviceUUID()
                if deviceId != "" {
                    deviceDict["ifa"] = deviceId
                }
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
    
    //fetch advertising identifier based TCF 2.0 Purpose1 value
    //truth table
    /*
                        deviceAccessConsent=true  deviceAccessConsent=false  deviceAccessConsent undefined
     gdprApplies=false        Yes, read IDFA       No, don’t read IDFA           Yes, read IDFA
     gdprApplies=true         Yes, read IDFA       No, don’t read IDFA           No, don’t read IDFA
     gdprApplies=undefined    Yes, read IDFA       No, don’t read IDFA           Yes, read IDFA
     */
    func isAllowedAccessDeviceData() -> Bool {
        let gdprApplies = Targeting.shared.subjectToGDPR
        let deviceAccessConsent = Targeting.shared.getDeviceAccessConsent()
        
        if ((deviceAccessConsent == nil && (gdprApplies == nil || gdprApplies == false)) || deviceAccessConsent == true) {
            return true
        }
        
        return false
    }

    // OpenRTB 2.5 Object: Geo in section 3.2.19

    func openrtbGeo() -> [AnyHashable: Any]? {

        guard Prebid.shared.shareGeoLocation, let location = CLLocationManager().location else {
            return nil
        }
        
        var geoDict: [AnyHashable: Any] = [:]
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        geoDict["lat"] = latitude
        geoDict["lon"] = longitude

        let locationTimestamp = location.timestamp
        let ageInSeconds: TimeInterval = -1.0 * locationTimestamp.timeIntervalSinceNow
        let ageInMilliseconds = Int64(ageInSeconds * 1000)

        geoDict["lastfix"] = ageInMilliseconds
        geoDict["accuracy"] = Int(location.horizontalAccuracy)

        return geoDict
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
        
        requestUserExt["eids"] = getExternalUserIds()

        userDict["ext"] = requestUserExt

        return userDict
    }
    
    func getExternalUserIds() -> [[AnyHashable: Any]]? {
       
        var externalUserIdArray = [ExternalUserId]()
        if Prebid.shared.externalUserIdArray.count != 0 {
            externalUserIdArray = Prebid.shared.externalUserIdArray
        }
        else if Targeting.shared.externalUserIds.count != 0{
            externalUserIdArray = Targeting.shared.externalUserIds
        }
        var transformedUserIdArray = [[AnyHashable: Any]]()
        for externaluserId in externalUserIdArray {
            var transformedeuidDic = [AnyHashable: Any]()
            guard externaluserId.source.count != 0 && externaluserId.identifier.count != 0 else {
                return nil
            }
            transformedeuidDic["source"] = externaluserId.source
            var uidArray = [[AnyHashable: Any]]()
            var uidDic = [AnyHashable: Any]()
            uidDic["id"] = externaluserId.identifier
            uidDic["atype"] = externaluserId.atype
            uidDic["ext"] = externaluserId.ext
            uidArray.append(uidDic)
            transformedeuidDic["uids"] = uidArray
            transformedUserIdArray.append(transformedeuidDic)
        }
        return transformedUserIdArray
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
        
        #if canImport(AppTrackingTransparency)
        if #available(iOS 14, *) {
            deviceExt["atts"] = ATTrackingManager.trackingAuthorizationStatus.rawValue
        }
        #endif

        return deviceExt
    }

    class func UserAgent(callback: @escaping(_ userAgentString: String) -> Void) {
        DispatchQueue.main.async {
            let webViewForUserAgent = WKWebView()
            webViewForUserAgent.loadHTMLString("<html></html>", baseURL: nil)
            webViewForUserAgent.evaluateJavaScript(
                "navigator.userAgent",
                completionHandler: { (userAgent: Any?, error: Error?) in
                    if let error = error {
                        Log.error("retrieving userAgent error:\(error)")
                    } else if let userAgent = userAgent as? String {
                        callback(userAgent)
                    }
                    webViewForUserAgent.stopLoading()
                    webViewForUserAgent.removeFromSuperview()
                })
        }
    }

    class func DeviceUUID() -> String {
        var uuidString: String = ""

        if (uuidString == "") {
            let advertisingIdentifier: String = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            uuidString = advertisingIdentifier
        }

        return uuidString
    }
}
