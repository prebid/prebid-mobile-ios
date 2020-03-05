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

import XCTest
import CoreTelephony
import CoreLocation
import AdSupport
import WebKit
@testable import PrebidMobile

class RequestBuilderTests: XCTestCase, CLLocationManagerDelegate {

    var app: XCUIApplication?
    var coreLocation: CLLocationManager?
    var adUnit: BannerAdUnit!
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

//        app = XCUIApplication()
//
//        addUIInterruptionMonitor(withDescription: "Location authorization") { (alert) -> Bool in
//            if alert.buttons["OK"].exists {
//                alert.buttons["OK"].tap()
//            }
//            return true
//        }
//
//        app?.launch()

        Prebid.shared.prebidServerHost = PrebidHost.Appnexus
        adUnit = BannerAdUnit(configId: Constants.configID1, size: CGSize(width: Constants.width2, height: Constants.height2))
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        adUnit = nil
        
        Targeting.shared.clearAccessControlList()
        Targeting.shared.clearUserData()
        Targeting.shared.clearContextData()
        Targeting.shared.clearContextKeywords()
        Targeting.shared.clearUserKeywords()
    }

    func testPostData() throws {

        //given
        let targeting = Targeting.shared
        targeting.subjectToGDPR = true

        targeting.gdprConsentString = "testGDPR"
        
        targeting.purposeConsents = "10"
        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        //then
        //TODO move to this area
        validationResponse(jsonRequestBody: jsonRequestBody as! [String : Any])
    }



    func testPostDataWithServerAccountId() throws {

        //given
        Prebid.shared.prebidServerAccountId = "bfa84af2-bd16-4d35-96ad-31c6bb888df0"

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let ext = jsonRequestBody["ext"] as? [String: Any],
            let prebid = ext["prebid"] as? [String: Any],
            let storedrequest = prebid["storedrequest"] as? [String: Any],
            let soredRequestid = storedrequest["id"] as? String else {

                XCTFail("parsing error")
                return

        }

        guard let app = jsonRequestBody["app"] as? [String: Any],
            let publisher = app["publisher"] as? [String: Any],
            let publisherId = publisher["id"] as? String else {

                XCTFail("parsing error")
                return

        }

        //then
        XCTAssertEqual("bfa84af2-bd16-4d35-96ad-31c6bb888df0", soredRequestid)
        XCTAssertEqual("bfa84af2-bd16-4d35-96ad-31c6bb888df0", publisherId)
    }

    func testPostDataWithIdentifier() throws {

        //given
        adUnit.identifier = "PrebidMobile"

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let impArray = jsonRequestBody["imp"] as? [Any],
            let impDic = impArray[0] as? [String: Any],
            let id = impDic["id"] as? String else {

                XCTFail("parsing error")
                return
        }

        //then
        XCTAssertEqual("PrebidMobile", id)
    }

    func testPostDataWithGender() throws {

        //given
        let targeting = Targeting.shared
        targeting.gender = Gender.male

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let user = jsonRequestBody["user"] as? [String: Any],
            let gender = user["gender"] as? String else {

            XCTFail("parsing error")
            return
        }

        //then
        XCTAssertEqual("M", gender)
    }

    func testPostDataWithItunesId() throws {

        //given
        let targeting = Targeting.shared
        targeting.itunesID = "12345"

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let app = jsonRequestBody["app"] as? [String: Any],
            let itunesID = app["bundle"] as? String else {

                XCTFail("parsing error")
                return
        }

        //then
        XCTAssertEqual("12345", itunesID)
    }
    
    func testPostDataVersion() throws {

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody
        
        guard let app = jsonRequestBody["app"] as? [String: Any],
            let version = app["ver"] as? String else {

                XCTFail("parsing error")
                return
        }

        //then
        XCTAssertNotNil(version)
    }

    func testPostDataWithStoreUrl() throws {
        //given
        let targeting = Targeting.shared
        targeting.storeURL = "https://itunes.apple.com/app/id123456789"

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let app = jsonRequestBody["app"] as? [String: Any],
            let storeurl = app["storeurl"] as? String else {

                XCTFail("parsing error")
                return
        }

        //then
        XCTAssertEqual("https://itunes.apple.com/app/id123456789", storeurl)
    }

    func testPostDataWithDomain() throws {
        //given
        let targeting = Targeting.shared
        targeting.domain = "appdomain.com"

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let app = jsonRequestBody["app"] as? [String: Any],
            let domain = app["domain"] as? String else {

                XCTFail("parsing error")
                return
        }

        //then
        XCTAssertEqual("appdomain.com", domain)
    }

    func testPostDataWithRubiconHost() throws {

        //given
        Prebid.shared.prebidServerHost = .Rubicon

        //when
        let urlRequest = try getPostDataHelper(adUnit: adUnit).urlRequest

        //then
        XCTAssertEqual(PrebidHost.Rubicon.name(), urlRequest.url?.absoluteString)
    }

    func testPostDataWithCOPPA() throws {

        //given
        let targeting = Targeting.shared
        targeting.subjectToCOPPA = true
        defer {
            targeting.subjectToCOPPA = false
        }
        
        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let regs = jsonRequestBody["regs"] as? [String: Any],
            let coppa = regs["coppa"] as? Int else {

                XCTFail("parsing error")
                return
        }

        //then
        XCTAssertEqual(1, coppa)
    }
    
    func testPostDataWithoutCOPPA() throws {

        //given
        let targeting = Targeting.shared
        targeting.subjectToCOPPA = false
        defer {
            targeting.subjectToCOPPA = false
        }
        
        var coppa: Int? = nil

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        if let regs = jsonRequestBody["regs"] as? [String: Any],
            let regsCoppa = regs["coppa"] as? Int {

            coppa = regsCoppa
        }

        //then
        XCTAssertNil(coppa)
    }
    
    func testPostDataWithGdprSubject() throws {

        //given
        let targeting = Targeting.shared
        targeting.subjectToGDPR = true
        defer {
            targeting.subjectToGDPR = false
        }

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let regs = jsonRequestBody["regs"] as? [String: Any],
            let regsExt = regs["ext"] as? [String: Any],
            let gdpr = regsExt["gdpr"] as? Int else {

                XCTFail("parsing error")
                return
        }

        //then
        XCTAssertEqual(1, gdpr)
    }

    func testPostDataWithoutGdprSubject() throws {

        //given
        let targeting = Targeting.shared
        targeting.subjectToGDPR = false
        defer {
            targeting.subjectToGDPR = false
        }

        var gdpr: Int? = nil

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        if let regs = jsonRequestBody["regs"] as? [String: Any],
            let regsExt = regs["ext"] as? [String: Any],
            let extGdpr = regsExt["gdpr"] as? Int {

            gdpr = extGdpr
        }

        //then
        XCTAssertNil(gdpr)
    }
    
    func testPostDataWithGdprConsent() throws {

        //given
        let targeting = Targeting.shared
        targeting.subjectToGDPR = true
        defer {
            targeting.subjectToGDPR = false
        }

        targeting.gdprConsentString = "testGDPR"

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let regs = jsonRequestBody["regs"] as? [String: Any],
            let regsExt = regs["ext"] as? [String: Any],
            let gdpr = regsExt["gdpr"] as? Int,
            //consent
            let user = jsonRequestBody["user"] as? [String: Any],
            let userExt = user["ext"] as? [String: Any],
            let consent = userExt["consent"] as? String else {
                
                XCTFail("parsing error")
                return
        }

        //then
        XCTAssertEqual(1, gdpr)
        XCTAssertEqual("testGDPR", consent)
    }
    
    func testPostDataWithGdprConsentWithoutGdprSubject() throws {

        //given
        let targeting = Targeting.shared
        targeting.subjectToGDPR = false

        targeting.gdprConsentString = "testGDPR"

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        var gdpr: Int? = nil
        var consent: String? = nil

        if let regs = jsonRequestBody["regs"] as? [String: Any],
            let regsExt = regs["ext"] as? [String: Any],
            let extGdpr = regsExt["gdpr"] as? Int,
            //consent
            let user = jsonRequestBody["user"] as? [String: Any],
            let userExt = user["ext"] as? [String: Any],
            let extConsent = userExt["consent"] as? String {

            gdpr = extGdpr
            consent = extConsent
        }

        //then
        XCTAssertNil(gdpr)
        XCTAssertNil(consent)

    }
    
    func testPostDataWithDeviceConsent() throws {

           //given
           let targeting = Targeting.shared
           targeting.subjectToGDPR = false

           targeting.gdprConsentString = "testGDPR"
        
            targeting.purposeConsents = "10"

           //when
           let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

           var idfa: String? = nil

           if let regs = jsonRequestBody["device"] as? [String: Any],
            let ifa = regs["ifa"] as? String {
                idfa = ifa
           }
           //then
            XCTAssertEqual(idfa, .kIFASentinelValue)
       }
    
    func testPostDataWithoutDeviceConsent() throws {

        //given
        let targeting = Targeting.shared
        targeting.subjectToGDPR = false

        targeting.gdprConsentString = "testGDPR"
     
         targeting.purposeConsents = "00"

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        var idfa: String? = nil

        if let regs = jsonRequestBody["device"] as? [String: Any],
         let ifa = regs["ifa"] as? String {
             idfa = ifa
        }
        //then
         XCTAssertNil(idfa)
    }
    
    func testPostDataWithInvalidDeviceConsent() throws {

        //given
        let targeting = Targeting.shared
        targeting.subjectToGDPR = true

        targeting.gdprConsentString = "testGDPR"
        
        targeting.purposeConsents = nil
     
        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        var idfa: String? = nil

        if let regs = jsonRequestBody["device"] as? [String: Any],
         let ifa = regs["ifa"] as? String {
             idfa = ifa
        }
        //then
         XCTAssertNil(idfa)
    }
    
    func testPostDataWithCCPA() throws {

        //given
        UserDefaults.standard.set("testCCPA", forKey: StorageUtils.IABUSPrivacy_StringKey)
        defer {
            UserDefaults.standard.removeObject(forKey: StorageUtils.IABUSPrivacy_StringKey)
        }

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let regs = jsonRequestBody["regs"] as? [String: Any],
            let regsExt = regs["ext"] as? [String: Any],
            let usPrivacy = regsExt["us_privacy"] as? String else {

                XCTFail("parsing error")
                return
        }

        //then
        XCTAssertEqual("testCCPA", usPrivacy)
    }
    
    func testPostDataWithEmptyCCPA() throws {

        //given
        UserDefaults.standard.set("", forKey: StorageUtils.IABUSPrivacy_StringKey)
        defer {
            UserDefaults.standard.removeObject(forKey: StorageUtils.IABUSPrivacy_StringKey)
        }

        var usPrivacy: String? = nil

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        if let regs = jsonRequestBody["regs"] as? [String: Any],
            let regsExt = regs["ext"] as? [String: Any],
            let extUsPrivacy = regsExt["us_privacy"] as? String {

            usPrivacy = extUsPrivacy
        }

        //then
        XCTAssertNil(usPrivacy)
    }
    
    func testPostDataWithoutCCPA() throws {

        //given
        UserDefaults.standard.removeObject(forKey: StorageUtils.IABUSPrivacy_StringKey)

        var usPrivacy: String? = nil

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        if let regs = jsonRequestBody["regs"] as? [String: Any],
            let regsExt = regs["ext"] as? [String: Any],
            let extUsPrivacy = regsExt["us_privacy"] as? String {

            usPrivacy = extUsPrivacy
        }

        //then
        XCTAssertNil(usPrivacy)
    }

    func testPostDataWithCustomKeyword() throws {

        //given
        adUnit.addUserKeyword(key: "key1", value: "value1")

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let user = jsonRequestBody["user"] as? [String: Any],
            let keywords = user["keywords"] as? String else {

                XCTFail("parsing error")
                return
        }

        //then
        XCTAssertEqual("value1", keywords)
    }

    func testPostDataWithoutTargetingKeys() throws {
        //given
        var keywords: String? = nil

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        if let user = jsonRequestBody["user"] as? [String: Any],
            let userKeywords = user["keywords"] as? String {

                keywords = userKeywords
        }

        //then
        XCTAssertNil(keywords)
    }
    
    func testPostDataWithGlobalUserKeyword() throws {

        //given
        let targeting = Targeting.shared
        targeting.addUserKeyword("value10")
        
        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let user = jsonRequestBody["user"] as? [String: Any],
            let keywords = user["keywords"] as? String else {
                
                XCTFail("parsing error")
                return
        }

        //then
        XCTAssertEqual("value10", keywords)
    }
    
    func testPostDataWithGlobalContextKeyword() throws {

        //given
        let targeting = Targeting.shared
        targeting.addContextKeyword("value10")
        
        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let user = jsonRequestBody["app"] as? [String: Any],
            let keywords = user["keywords"] as? String else {
                
                XCTFail("parsing error")
                return
        }

        //then
        XCTAssertEqual("value10", keywords)

    }
    
    func testPostDataWithAccessControlList() throws {

        //given
        let targeting = Targeting.shared
        targeting.addBidderToAccessControlList(Prebid.bidderNameRubiconProject)
        
        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let ext = jsonRequestBody["ext"] as? [String: Any],
            let prebid = ext["prebid"] as? [String: Any],
            let data = prebid["data"] as? [String: Any],
            let bidders = data["bidders"] as? [String] else {
                
                XCTFail("parsing fail")
                return
        }

        //then
        XCTAssertEqual(1, bidders.count)
        XCTAssertEqual(bidders[0], Prebid.bidderNameRubiconProject)
    }
    
    func testPostDataWithGlobalUserData() throws {

        //given
        let targeting = Targeting.shared
        targeting.addUserData(key: "key1", value: "value10")
        targeting.addUserData(key: "key2", value: "value20")
        targeting.addUserData(key: "key2", value: "value21")
        
        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let user = jsonRequestBody["user"] as? [String: Any],
            let ext = user["ext"] as? [String: Any],
            let data = ext["data"] as? [String: Any],
            let key1Set1 = data["key1"] as? [String],
            let key2Set1 = data["key2"] as? [String] else {
                XCTFail("parsing fail")
                return
        }

        //then
        XCTAssertEqual(2, data.count)
        XCTAssertEqual(Set(["value10"]), Set(key1Set1))
        XCTAssertEqual(Set(["value20", "value21"]), Set(key2Set1))
    }

    func testPostDataWithGlobalContextData() throws {

        //given
        let targeting = Targeting.shared
        targeting.addContextData(key: "key1", value: "value10")
        targeting.addContextData(key: "key2", value: "value20")
        targeting.addContextData(key: "key2", value: "value21")
        
        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let app = jsonRequestBody["app"] as? [String: Any],
            let ext = app["ext"] as? [String: Any],
            let data = ext["data"] as? [String: Any],
            let key1Set1 = data["key1"] as? [String],
            let key2Set1 = data["key2"] as? [String] else {
                XCTFail("parsing fail")
                return
        }

        //then
        XCTAssertEqual(2, data.count)
        XCTAssertEqual(Set(["value10"]), Set(key1Set1))
        XCTAssertEqual(Set(["value20", "value21"]), Set(key2Set1))

    }
    
    func testPostDataWithAdunitContextKeyword() throws {

        //given
        adUnit.addContextKeyword("value10")
        
        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let impArray = jsonRequestBody["imp"] as? [Any],
            let impDic = impArray[0] as? [String: Any],
            let ext = impDic["ext"] as? [String: Any],
            let context = ext["context"] as? [String: Any],
            let keywords = context["keywords"] as? String else {
                XCTFail("parsing fail")
                return
        }

        //then
        XCTAssertEqual("value10", keywords)
    }
    
    func testPostDataWithAdunitContextData() throws {

        //given
        adUnit.addContextData(key: "key1", value: "value10")
        adUnit.addContextData(key: "key2", value: "value20")
        adUnit.addContextData(key: "key2", value: "value21")
        
        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let impArray = jsonRequestBody["imp"] as? [Any],
            let impDic = impArray[0] as? [String: Any],
            let ext = impDic["ext"] as? [String: Any],
            let context = ext["context"] as? [String: Any],
            let data = context["data"] as? [String: Any],
            let key1Set1 = data["key1"] as? [String],
            let key2Set1 = data["key2"] as? [String] else {
                XCTFail("parsing fail")
                return
        }

        //then
        XCTAssertEqual(2, data.count)
        XCTAssertEqual(Set(["value10"]), Set(key1Set1))
        XCTAssertEqual(Set(["value20", "value21"]), Set(key2Set1))
    }

    func testPostDataWithStoredResponses() throws {
        //given
        Prebid.shared.storedAuctionResponse = "111122223333"
        Prebid.shared.addStoredBidResponse(bidder: "appnexus", responseId: "221144")
        Prebid.shared.addStoredBidResponse(bidder: "rubicon", responseId: "221155")

        defer {
            Prebid.shared.storedAuctionResponse = ""
            Prebid.shared.clearStoredBidResponses()
        }

        //when
        try RequestBuilder.shared.buildPrebidRequest(adUnit: adUnit) { (urlRequest) in
            let jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: urlRequest) as! [String: Any]

            guard let impArray = jsonRequestBody["imp"] as? [Any],
                let impDic = impArray[0] as? [String: Any],
                let ext = impDic["ext"] as? [String: Any],
                let prebid = ext["prebid"] as? [String: Any],
                let storedAuctionResponse = prebid["storedauctionresponse"] as? [String: String],
                let storedAuctionResponseId = storedAuctionResponse["id"],
                let storedBidResponses = prebid["storedbidresponse"] as? [Any] else {

                    XCTFail("parsing fail")
                    return
            }

            //then
            XCTAssertEqual("111122223333", storedAuctionResponseId)

            XCTAssertEqual(Set([["bidder":"appnexus", "id":"221144"], ["bidder":"rubicon", "id":"221155"]]), Set(storedBidResponses as! Array<Dictionary<String, String>>))
        }
    }

    func testPostDataWithShareLocationOn() {
        coreLocation = CLLocationManager()
        coreLocation?.delegate = self

        coreLocation!.swizzledStartLocation()

        coreLocation?.swizzedRequestLocation()

        Prebid.shared.shareGeoLocation = true
        do {
            sleep(10)
            try RequestBuilder.shared.buildPrebidRequest(adUnit: adUnit) { (urlRequest) in
                let jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: urlRequest) as! [String: Any]
                let device = jsonRequestBody["device"] as? [String: Any]
                XCTAssertNotNil(device!["geo"])
                let geo = device!["geo"] as? [String: Any]
                XCTAssertNotNil(geo!["accuracy"])
                XCTAssertNotNil(geo!["lastfix"])
                XCTAssertNotNil(geo!["lat"])
                XCTAssertNotNil(geo!["lon"])
            }
        } catch let error {
            print(error.localizedDescription)
        }

    }

    func testPostDataWithShareLocationOff() {
        Prebid.shared.shareGeoLocation = false
        do {
            sleep(10)
            try RequestBuilder.shared.buildPrebidRequest(adUnit: adUnit) { (urlRequest) in
                let jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: urlRequest) as! [String: Any]
                let device = jsonRequestBody["device"] as? [String: Any]
                XCTAssertNil(device!["geo"])
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func testPostDataWithAdvancedInterstitial() throws {

        //given
        let adUnit = InterstitialAdUnit(configId: Constants.configID1, minWidthPerc: 50, minHeightPerc: 70)
        
        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let device = jsonRequestBody["device"] as? [String: Any],
            let ext = device["ext"] as? [String: Any],
            let prebid = ext["prebid"] as? [String: Any],
            let interstitial = prebid["interstitial"] as? [String: Any],
            let minwidthperc = interstitial["minwidthperc"] as? Int,
            let minheightperc = interstitial["minheightperc"] as? Int else {

                XCTFail("parsing fail")
                return
        }

        guard let imp = jsonRequestBody["imp"] as? [Any],
            let imp0 = imp[0] as? [String: Any],

            let instl = imp0["instl"] as? Int,

            let banner = imp0["banner"] as? [String: Any],
            let formatArr = banner["format"] as? [Any],
            let format0 = formatArr[0] as? [String: Any],
            let w = format0["w"] as? Int,
            let h = format0["h"] as? Int else {

                XCTFail("parsing fail")
                return

        }

        //then
        XCTAssertEqual(1, instl)

        XCTAssertEqual(50, minwidthperc)
        XCTAssertEqual(70, minheightperc)

        XCTAssertNotNil(w)
        XCTAssertNotNil(h)

    }

    func testPostDataWithoutAdvancedInterstitial() throws {

        //given
        let adUnit = InterstitialAdUnit(configId: Constants.configID1)
        var interstitial: [String: Any]? = nil

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        if let device = jsonRequestBody["device"] as? [String: Any],
            let ext = device["ext"] as? [String: Any],
            let prebid = ext["prebid"] as? [String: Any],
            let prebidInterstitial = prebid["interstitial"] as? [String: Any] {

                interstitial = prebidInterstitial
        }

        guard let imp = jsonRequestBody["imp"] as? [Any],
            let imp0 = imp[0] as? [String: Any],

            let instl = imp0["instl"] as? Int,

            let banner = imp0["banner"] as? [String: Any],
            let formatArr = banner["format"] as? [Any],
            let format0 = formatArr[0] as? [String: Any],
            let w = format0["w"] as? Int,
            let h = format0["h"] as? Int else {

                XCTFail("parsing fail")
                return

        }

        //then
        XCTAssertEqual(1, instl)

        XCTAssertNil(interstitial)

        XCTAssertNotNil(w)
        XCTAssertNotNil(h)
    }

    func testPostDataWithoutAdvancedBannerInterstitial() throws {

        //given
        let adUnit = BannerAdUnit(configId: Constants.configID1, size: CGSize(width: 300, height: 250))
        var interstitial: [String: Any]? = nil
        var instl = 0

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        if let device = jsonRequestBody["device"] as? [String: Any],
            let ext = device["ext"] as? [String: Any],
            let prebid = ext["prebid"] as? [String: Any],
            let prebidInterstitial = prebid["interstitial"] as? [String: Any] {

            interstitial = prebidInterstitial


        }

        if let impArr = jsonRequestBody["imp"] as? [Any],
            let imp0 = impArr[0] as? [String: Any],
            let imp0instl = imp0["instl"] as? Int {

            instl = imp0instl
        }

        //then
        XCTAssert(interstitial == nil || interstitial!.count == 0)
        XCTAssertEqual(0, instl)
    }

    func testYearOfBirth() throws {

        let targeting = Targeting.shared
        try targeting.setYearOfBirth(yob: 1990)
        defer {
            targeting.clearYearOfBirth()
        }

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let user = jsonRequestBody["user"] as? [String: Any],
            let yob = user["yob"] as? Int else {

                XCTFail("parsing error")
                return
        }

        //then
        XCTAssertEqual(1990, yob)

    }

    func testYearOfBirthWrong() throws {

        //given
        let targeting = Targeting.shared
        XCTAssertThrowsError(try targeting.setYearOfBirth(yob: 1855))
        defer {
            targeting.clearYearOfBirth()
        }
        let value = Targeting.shared.yearOfBirth
        XCTAssertFalse(value == 1855)

        var yob: Int? = nil

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        if let user = jsonRequestBody["user"] as? [String: Any],
            let userYob = user["yob"] as? Int {

                yob = userYob
        }

        //then
        XCTAssertNil(yob)
    }

    func testYearOfBirthNegative() throws {

        //given
        let targeting = Targeting.shared
        XCTAssertThrowsError(try targeting.setYearOfBirth(yob: -1))
        defer {
            targeting.clearYearOfBirth()
        }
        let value = Targeting.shared.yearOfBirth
        XCTAssertFalse(value == -1)

        var yob: Int? = nil

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        if let user = jsonRequestBody["user"] as? [String: Any],
            let userYob = user["yob"] as? Int {

            yob = userYob
        }

        //then
        XCTAssertNil(yob)

    }
    
    func testOpenRTBAppObjectWithoutData() throws {

        //given
        Targeting.shared.storeURL = ""
        Targeting.shared.domain = nil
        
        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let app = jsonRequestBody["app"] as? [String: Any] else {
            XCTFail("parsing error")
            return
        }

        //then
        XCTAssertNil(app["storeurl"])
        XCTAssertNil(app["domain"])

    }
    
    func testVideoAdUnit() throws {
         //given
         Prebid.shared.prebidServerAccountId = "12345"
        let adUnit = VideoAdUnit(configId: Constants.configID1, size: CGSize(width: 300, height: 250), type: .inBanner)
         
         //when
         let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody
         
         guard let impArray = jsonRequestBody["imp"] as? [Any],
             let impDic = impArray[0] as? [String: Any],
             let video = impDic["video"] as? [String: Any],
             let w = video["w"] as? Int,
             let h = video["h"] as? Int,
             let linearity = video["linearity"] as? Int,
             let playbackMethods = video["playbackmethod"] as? [Int],
             let playbackMethods1 = playbackMethods[0] as? Int,
             let mimes = video["mimes"] as? [String],
             let mimes1 = mimes[0] as? String,
             let placement = video["placement"] as? Int,
         
             let ext = jsonRequestBody["ext"] as? [String: Any],
             let extPrebid = ext["prebid"] as? [String: Any],
             let cache = extPrebid["cache"] as? [String: Any],
             let vastXml = cache["vastxml"] as? [String: Any]
             else {
                 XCTFail("parsing fail")
                 return
             }
         
         //then
         XCTAssertEqual(300, w)
         XCTAssertEqual(250, h)
         XCTAssertEqual(1, linearity)
         XCTAssertEqual(2, playbackMethods1)
         XCTAssertEqual("video/mp4", mimes1)
         XCTAssertEqual(2, placement)
         
         XCTAssertNotNil(vastXml)
         
     }
     
     func testVideoInterstitialAdUnit() throws {
         //given
         Prebid.shared.prebidServerAccountId = "12345"
         let adUnit = VideoInterstitialAdUnit(configId: Constants.configID1)
         
         //when
         let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody
         
         guard let impArray = jsonRequestBody["imp"] as? [Any],
             let impDic = impArray[0] as? [String: Any],
             let video = impDic["video"] as? [String: Any],
             let w = video["w"] as? Int,
             let h = video["h"] as? Int,
             let placement = video["placement"] as? Int,
             let linearity = video["linearity"] as? Int,
             let playbackMethods = video["playbackmethod"] as? [Int],
             let playbackMethods1 = playbackMethods[0] as? Int,
             let mimes = video["mimes"] as? [String],
             let mimes1 = mimes[0] as? String,
             
             let ext = jsonRequestBody["ext"] as? [String: Any],
             let extPrebid = ext["prebid"] as? [String: Any],
             let cache = extPrebid["cache"] as? [String: Any],
             let vastXml = cache["vastxml"] as? [String: Any],
         
             let instl = impDic["instl"] as? Int
             else {
                 XCTFail("parsing fail")
                 return
         }
         
         //then
         XCTAssertEqual(5, placement)
         XCTAssertEqual(1, linearity)
         XCTAssertEqual(2, playbackMethods1)
         XCTAssertEqual("video/mp4", mimes1)
         
         XCTAssertNotNil(vastXml)
         
         XCTAssertEqual(1, instl)
         
     }

    private func getPostDataHelper(adUnit: AdUnit) throws -> (urlRequest: URLRequest, jsonRequestBody: [AnyHashable: Any]) {
        var resultUrlRequest: URLRequest? = nil
        var resultJsonRequestBody: [AnyHashable: Any]? = nil

        let exception = expectation(description: "\(#function)")

        try RequestBuilder.shared.buildPrebidRequest(adUnit: adUnit) { (urlRequest) in
            resultUrlRequest = urlRequest
            let jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: urlRequest) as! [String: Any]

            resultJsonRequestBody = jsonRequestBody
            exception.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)

        return (resultUrlRequest!, resultJsonRequestBody!)

    }

    func validationResponse(jsonRequestBody: [String: Any]) {

        XCTAssertNotNil(jsonRequestBody["id"])
        XCTAssertNotNil(jsonRequestBody["source"])
        XCTAssertNotNil(jsonRequestBody["imp"])
        XCTAssertNotNil(jsonRequestBody["device"])
        XCTAssertNotNil(jsonRequestBody["app"])
        XCTAssertNotNil(jsonRequestBody["user"])

        if let impArray = jsonRequestBody["imp"] as? [Any], let impDic = impArray[0] as? [String: Any] {
            XCTAssertEqual(1, impDic["secure"] as! Int)
            if let ext = impDic["ext"] as? [String: Any], let prebid = ext["prebid"] as? [String: Any], let storedrequest = prebid["storedrequest"] as? [String: Any] {
                XCTAssertEqual("6ace8c7d-88c0-4623-8117-75bc3f0a2e45", storedrequest["id"] as! String)
            }
            if let banner = impDic["banner"] as? [String: Any], let format = banner["format"] as? [Any], let size = format[0] as? [String: Any] {
                XCTAssertEqual(250, size["h"] as! Int)
                XCTAssertEqual(300, size["w"] as! Int)
            }
        }

        if let device = jsonRequestBody["device"] as? [String: Any] {
            let reachability: Reachability = Reachability()!
            var connectionType: Int = 0
            if (reachability.connection == .wifi) {
                connectionType = 1
            } else if (reachability.connection == .cellular) {
                connectionType = 2
            }
            XCTAssertEqual(connectionType, device["connectiontype"] as! Int)
            XCTAssertEqual("Apple", device["make"] as! String)
            XCTAssertEqual("iOS", device["os"] as! String)
            XCTAssertEqual(UIDevice.current.systemVersion, device["osv"] as! String)
            XCTAssertEqual(UIScreen.main.bounds.size.height, device["h"] as! CGFloat)
            XCTAssertEqual(UIScreen.main.bounds.size.width, device["w"] as! CGFloat)
            XCTAssertEqual(UIDevice.current.modelName, device["model"] as! String)
            let carrier: CTCarrier? = CTTelephonyNetworkInfo().subscriberCellularProvider
            if (carrier?.carrierName?.count ?? 0) > 0 {
                XCTAssertEqual(carrier?.carrierName ?? "", device["carrier"] as! String)
            }
            let ifa = device["ifa"] as? String ?? ""
            XCTAssertEqual(RequestBuilder.DeviceUUID(), ifa)
            let lmtAd: Bool = !ASIdentifierManager.shared().isAdvertisingTrackingEnabled
            XCTAssertEqual(NSNumber(value: lmtAd).intValue, device["lmt"] as! Int)
            XCTAssertEqual(UIScreen.main.scale, device["pxratio"] as! CGFloat)
        }

        if let ext = jsonRequestBody["ext"] as? [String: Any] {
            XCTAssertNotNil(ext["prebid"])
            if let prebid = ext["prebid"] as? [String: Any] {
                XCTAssertNotNil(prebid["cache"])
                if let cache = prebid["cache"] as? [String: Any] {
                    XCTAssertNotNil(cache["bids"])
                }

                XCTAssertNotNil(prebid["targeting"])
            }
        }

        if let app = jsonRequestBody["app"] as? [String: Any] {
            if let ext = app["ext"] as? [String: Any] {
                if let prebid = ext["prebid"] as? [String: Any] {
                    XCTAssertEqual("prebid-mobile", prebid["source"] as! String)
                    
                    let prebidSdkVersion = Bundle(for: RequestBuilder.self).infoDictionary?["CFBundleShortVersionString"] as? String
                    XCTAssertEqual(prebidSdkVersion, prebid["version"] as! String)
                }
            }
        }
        if let source = jsonRequestBody["source"] as? [String: Any] {
            let tid = source["tid"] as? String
            XCTAssertNotNil(tid)

        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Location.shared.location = locations.last!

    }
}
