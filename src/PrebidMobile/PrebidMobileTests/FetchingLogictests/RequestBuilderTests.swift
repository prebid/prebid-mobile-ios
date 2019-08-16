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
        Prebid.shared.prebidServerAccountId = "bfa84af2-bd16-4d35-96ad-31c6bb888df0"
        Prebid.shared.prebidServerHost = PrebidHost.Appnexus

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

        let targeting = Targeting.shared
        targeting.gender = Gender.male
        targeting.subjectToGDPR = true
        targeting.itunesID = "12345"
        targeting.gdprConsentString = "testGDPR"
        targeting.storeURL = "https://itunes.apple.com/app/id123456789"
        targeting.domain = "appdomain.com"

        adUnit = BannerAdUnit(configId: Constants.configID1, size: CGSize(width: Constants.width2, height: Constants.height2))
        adUnit.identifier = "PrebidMobile"
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

    func testPostData() {
        let targeting = Targeting.shared
        try! targeting.setYearOfBirth(yob: 1990)
        defer {
            targeting.clearYearOfBirth()
        }

        do {
            try RequestBuilder.shared.buildPrebidRequest(adUnit: adUnit) { (urlRequest) in
                let jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: urlRequest) as! [String: Any]
                XCTAssertNotNil(jsonRequestBody["regs"])
                if let regs = jsonRequestBody["regs"] as? [String: Any] {
                    if let ext = regs["ext"] as? [String: Any] {
                        XCTAssertEqual(1, ext["gdpr"] as! Int)
                    }
                }
                if let user = jsonRequestBody["user"] as? [String: Any] {
                    if let ext = user["ext"] as? [String: Any] {
                        XCTAssertEqual("testGDPR", ext["consent"] as! String)
                    }
                    XCTAssertEqual("M", user["gender"] as! String)
                    XCTAssertEqual(1990, user["yob"] as! Int)
                }
                self.validationResponse(jsonRequestBody: jsonRequestBody)

            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func testPostDataWithCustomHost() {
        let targeting = Targeting.shared
        try! targeting.setYearOfBirth(yob: 1990)
        defer {
            targeting.clearYearOfBirth()
        }

        XCTAssertThrowsError(try Prebid.shared.setCustomPrebidServer(url: "http://www.rubicon.org"))
        Prebid.shared.prebidServerAccountId = "bfa84af2-bd16-4d35-96ad-31c6bb888df0"
        Prebid.shared.prebidServerHost = PrebidHost.Custom

        do {
            try RequestBuilder.shared.buildPrebidRequest(adUnit: adUnit) { (urlRequest) in
                let jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: urlRequest) as! [String: Any]
                self.validationResponse(jsonRequestBody: jsonRequestBody)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func testPostDataWithCOPPA() {
        let targeting = Targeting.shared
        targeting.subjectToCOPPA = true
        defer {
            targeting.subjectToCOPPA = false
        }
        
        do {
            try RequestBuilder.shared.buildPrebidRequest(adUnit: adUnit) { (urlRequest) in
                let jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: urlRequest) as! [String: Any]
                XCTAssertNotNil(jsonRequestBody["regs"])
                if let coppa = jsonRequestBody["coppa"] as? Int {
                    XCTAssertEqual(1, coppa)
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func testPostDataWithoutCOPPA() {
        let targeting = Targeting.shared
        targeting.subjectToCOPPA = false
        targeting.subjectToGDPR = false
        defer {
            targeting.subjectToCOPPA = false
        }
        
        do {
            try RequestBuilder.shared.buildPrebidRequest(adUnit: adUnit) { (urlRequest) in
                let jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: urlRequest) as! [String: Any]
                XCTAssertNil(jsonRequestBody["regs"])
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func testPostDataWithNoGDPR() {
        let targeting = Targeting.shared
        targeting.subjectToGDPR = false
        try! targeting.setYearOfBirth(yob: 1990)
        defer {
            targeting.clearYearOfBirth()
        }

        do {
            try RequestBuilder.shared.buildPrebidRequest(adUnit: adUnit) { (urlRequest) in
                let jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: urlRequest) as! [String: Any]
                XCTAssertNil(jsonRequestBody["regs"])
                if let user = jsonRequestBody["user"] as? [String: Any] {
                    XCTAssertNil(user["ext"])
                    XCTAssertEqual("M", user["gender"] as! String)
                    XCTAssertEqual(1990, user["yob"] as! Int)
                }
                self.validationResponse(jsonRequestBody: jsonRequestBody)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func testPostDataWithNoTargetingKeys() {
        let targeting = Targeting.shared
        targeting.gender = Gender.unknown
        targeting.subjectToGDPR = false
        targeting.itunesID = nil
        targeting.clearYearOfBirth()

        do {
            try RequestBuilder.shared.buildPrebidRequest(adUnit: adUnit) { (urlRequest) in
                let jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: urlRequest) as! [String: Any]
                print(jsonRequestBody)
                XCTAssertNil(jsonRequestBody["regs"])
                if let user = jsonRequestBody["user"] as? [String: Any] {
                    XCTAssertNil(user["ext"])
                    XCTAssertEqual("O", user["gender"] as! String)
                    XCTAssertNil(user["yob"])
                }
                self.validationResponse(jsonRequestBody: jsonRequestBody)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func testPostDataWithCustomKeyword() {
        let targeting = Targeting.shared
        targeting.gender = Gender.unknown
        targeting.subjectToGDPR = false
        targeting.itunesID = nil
        targeting.clearYearOfBirth()
        adUnit.addUserKeyword(key: "key1", value: "value1")
        do {
            try RequestBuilder.shared.buildPrebidRequest(adUnit: adUnit) { (urlRequest) in
                let jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: urlRequest) as! [String: Any]
                XCTAssertNil(jsonRequestBody["regs"])
                if let user = jsonRequestBody["user"] as? [String: Any] {
                    XCTAssertNil(user["ext"])
                    XCTAssertEqual("O", user["gender"] as! String)
                    XCTAssertNil(user["yob"])
                    XCTAssertNotNil(user["keywords"])
                    XCTAssertEqual("key1=value1", user["keywords"] as! String)

                }
                self.validationResponse(jsonRequestBody: jsonRequestBody)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func testPostDataWithGlobalUserKeyword() {
        let targeting = Targeting.shared
      
        targeting.addUserKeyword("value10")
        
        do {
            try RequestBuilder.shared.buildPrebidRequest(adUnit: adUnit) { (urlRequest) in
                let jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: urlRequest) as! [String: Any]
                
                guard let user = jsonRequestBody["user"] as? [String: Any]  else {
                    XCTFail("parcing fail")
                    return
                }
                
                XCTAssertNotNil(user["keywords"])
                XCTAssertEqual(user["keywords"] as! String, "value10")
                
                self.validationResponse(jsonRequestBody: jsonRequestBody)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func testPostDataWithGlobalContextKeyword() {
        let targeting = Targeting.shared
        
        targeting.addContextKeyword("value10")
        
        do {
            try RequestBuilder.shared.buildPrebidRequest(adUnit: adUnit) { (urlRequest) in
                let jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: urlRequest) as! [String: Any]
                
                guard let app = jsonRequestBody["app"] as? [String: Any]  else {
                    XCTFail("parcing fail")
                    return
                }
                
                XCTAssertNotNil(app["keywords"])
                XCTAssertEqual(app["keywords"] as! String, "value10")
                
                self.validationResponse(jsonRequestBody: jsonRequestBody)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func testPostDataWithAccessControlList() {
        let targeting = Targeting.shared
        targeting.addBidderToAccessControlList(Prebid.bidderNameRubiconProject)
        
        do {
            try RequestBuilder.shared.buildPrebidRequest(adUnit: adUnit) { (urlRequest) in
                let jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: urlRequest) as! [String: Any]
                
                guard let ext = jsonRequestBody["ext"] as? [String: Any], let prebid = ext["prebid"] as? [String: Any], let data = prebid["data"] as? [String: Any], let bidders = data["bidders"] as? [String] else {
                    XCTFail("parcing fail")
                    return
                }
                
                XCTAssertNotNil(bidders.count == 1)
                XCTAssertEqual(bidders[0], Prebid.bidderNameRubiconProject)
                
                self.validationResponse(jsonRequestBody: jsonRequestBody)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func testPostDataWithGlobalUserData() {
        let targeting = Targeting.shared
        targeting.addUserData(key: "key1", value: "value10")
        targeting.addUserData(key: "key2", value: "value20")
        targeting.addUserData(key: "key2", value: "value21")
        
        do {
            try RequestBuilder.shared.buildPrebidRequest(adUnit: adUnit) { (urlRequest) in
                let jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: urlRequest) as! [String: Any]
                
                guard let user = jsonRequestBody["user"] as? [String: Any], let ext = user["ext"] as? [String: Any], let data = ext["data"] as? [String: Any] else {
                    XCTFail("parcing fail")
                    return
                }
                
                XCTAssert(data.count == 2)
                
                guard let key1Set1 = data["key1"] as? [String] else {
                    XCTFail("set is nil")
                    return
                }
                XCTAssert(key1Set1.contains("value10"))
                
                guard let key2Set1 = data["key2"] as? [String] else {
                    XCTFail("set is nil")
                    return
                }
                XCTAssert(key2Set1.contains("value20") && key2Set1.contains("value21"))
                
                self.validationResponse(jsonRequestBody: jsonRequestBody)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func testPostDataWithGlobalContextData() {
        let targeting = Targeting.shared
        targeting.addContextData(key: "key1", value: "value10")
        targeting.addContextData(key: "key2", value: "value20")
        targeting.addContextData(key: "key2", value: "value21")
        
        do {
            try RequestBuilder.shared.buildPrebidRequest(adUnit: adUnit) { (urlRequest) in
                let jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: urlRequest) as! [String: Any]
                
                guard let app = jsonRequestBody["app"] as? [String: Any], let ext = app["ext"] as? [String: Any], let data = ext["data"] as? [String: Any] else {
                    XCTFail("parcing fail")
                    return
                }
                
                XCTAssert(data.count == 2)
                
                guard let key1Set1 = data["key1"] as? [String] else {
                    XCTFail("set is nil")
                    return
                }
                XCTAssert(key1Set1.contains("value10"))
                
                guard let key2Set1 = data["key2"] as? [String] else {
                    XCTFail("set is nil")
                    return
                }
                XCTAssert(key2Set1.contains("value20") && key2Set1.contains("value21"))
                
                self.validationResponse(jsonRequestBody: jsonRequestBody)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func testPostDataWithAdunitContextKeyword() {
        adUnit.addContextKeyword("value10")
        
        do {
            try RequestBuilder.shared.buildPrebidRequest(adUnit: adUnit) { (urlRequest) in
                let jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: urlRequest) as! [String: Any]
                
                guard let impArray = jsonRequestBody["imp"] as? [Any], let impDic = impArray[0] as? [String: Any], let ext = impDic["ext"] as? [String: Any], let context = ext["context"] as? [String: Any] else {
                    XCTFail("parcing fail")
                    return
                }
                
                XCTAssertNotNil(context["keywords"])
                XCTAssertEqual(context["keywords"] as! String, "value10")
                
                self.validationResponse(jsonRequestBody: jsonRequestBody)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func testPostDataWithAdunitContextData() {
        adUnit.addContextData(key: "key1", value: "value10")
        adUnit.addContextData(key: "key2", value: "value20")
        adUnit.addContextData(key: "key2", value: "value21")
        
        do {
            try RequestBuilder.shared.buildPrebidRequest(adUnit: adUnit) { (urlRequest) in
                let jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: urlRequest) as! [String: Any]
                
                guard let impArray = jsonRequestBody["imp"] as? [Any], let impDic = impArray[0] as? [String: Any], let ext = impDic["ext"] as? [String: Any], let context = ext["context"] as? [String: Any], let data = context["data"] as? [String: Any] else {
                    XCTFail("parcing fail")
                    return
                }
                
                XCTAssert(data.count == 2)
                
                guard let key1Set1 = data["key1"] as? [String] else {
                    XCTFail("set is nil")
                    return
                }
                XCTAssert(key1Set1.contains("value10"))
                
                guard let key2Set1 = data["key2"] as? [String] else {
                    XCTFail("set is nil")
                    return
                }
                XCTAssert(key2Set1.contains("value20") && key2Set1.contains("value21"))
            }
        } catch let error {
            print(error.localizedDescription)
        }
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
    
    func testPostDataWithAdvancedInterstitial() {
        let adUnit = InterstitialAdUnit(configId: Constants.configID1, minWidthPerc: 50, minHeightPerc: 70)
        
        do {
            try RequestBuilder.shared.buildPrebidRequest(adUnit: adUnit) { (urlRequest) in
                let jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: urlRequest) as! [String: Any]
                print(jsonRequestBody)
                
                if let device = jsonRequestBody["device"] as? [String: Any],
                    let ext = device["ext"] as? [String: Any],
                    let prebid = ext["prebid"] as? [String: Any],
                    let interstitial = prebid["interstitial"] as? [String: Any],
                    let minwidthperc = interstitial["minwidthperc"] as? Int,
                    let minheightperc = interstitial["minheightperc"] as? Int {
                    
                    XCTAssertEqual(50, minwidthperc)
                    XCTAssertEqual(70, minheightperc)
                    
                } else {
                    XCTFail("Can not find minSizePerc")
                }
                
                if let imp = jsonRequestBody["imp"] as? [Any],
                    let imp0 = imp[0] as? [String: Any] {
                    
                    if let banner = imp0["banner"] as? [String: Any],
                        let formatArr = banner["format"] as? [Any],
                        let format0 = formatArr[0] as? [String: Any],
                        let w = format0["w"] as? Int,
                        let h = format0["h"] as? Int {
                        
                        XCTAssertNotNil(w)
                        XCTAssertNotNil(h)
                    } else {
                        XCTFail("Can not find width and height")
                    }
                    
                    if let instl = imp0["instl"] as? Int {
                        XCTAssertEqual(1, instl)
                    } else {
                        XCTFail("Can not find instl")
                    }
                    
                } else {
                    XCTFail("Can not find imp")
                    
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func testPostDataWithoutAdvancedInterstitial() {
        let adUnit = InterstitialAdUnit(configId: Constants.configID1)
        
        do {
            try RequestBuilder.shared.buildPrebidRequest(adUnit: adUnit) { (urlRequest) in
                let jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: urlRequest) as! [String: Any]
                print(jsonRequestBody)
                
                if let device = jsonRequestBody["device"] as? [String: Any],
                    let ext = device["ext"] as? [String: Any],
                    let prebid = ext["prebid"] as? [String: Any],
                    let interstitial = prebid["interstitial"] as? [String: Any] {
                    
                    XCTAssertEqual(0, interstitial.count)
                    
                }
                
                if let imp = jsonRequestBody["imp"] as? [Any],
                    let imp0 = imp[0] as? [String: Any] {
                    
                    if let banner = imp0["banner"] as? [String: Any],
                        let formatArr = banner["format"] as? [Any],
                        let format0 = formatArr[0] as? [String: Any],
                        let w = format0["w"] as? Int,
                        let h = format0["h"] as? Int {
                        
                        XCTAssertNotNil(w)
                        XCTAssertNotNil(h)
                    } else {
                        XCTFail("Can not find width and height")
                    }
                    
                    if let instl = imp0["instl"] as? Int {
                        XCTAssertEqual(1, instl)
                    } else {
                        XCTFail("Can not find instl")
                    }
                    
                } else {
                    XCTFail("Can not find imp")
                    
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func testPostDataWithoutAdvancedBannerInterstitial() {
        let adUnit = BannerAdUnit(configId: Constants.configID1, size: CGSize(width: 300, height: 250))
        
        do {
            try RequestBuilder.shared.buildPrebidRequest(adUnit: adUnit) { (urlRequest) in
                let jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: urlRequest) as! [String: Any]
                print(jsonRequestBody)
                
                if let device = jsonRequestBody["device"] as? [String: Any],
                    let ext = device["ext"] as? [String: Any],
                    let prebid = ext["prebid"] as? [String: Any],
                    let interstitial = prebid["interstitial"] as? [String: Any] {

                    XCTAssertEqual(0, interstitial.count)

                }
                
                if let impArr = jsonRequestBody["imp"] as? [Any],
                    let imp0 = impArr[0] as? [String: Any],
                    let instl = imp0["instl"] as? Int {
                    
                    XCTAssertEqual(0, instl)
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func testYOBWith1855() {
        let targeting = Targeting.shared
        XCTAssertThrowsError(try targeting.setYearOfBirth(yob: 1855))
        let value = Targeting.shared.yearOfBirth
        XCTAssertFalse(value == 1855)

        do {
            try RequestBuilder.shared.buildPrebidRequest(adUnit: adUnit) { (urlRequest) in
                let jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: urlRequest) as! [String: Any]
                let user = jsonRequestBody["user"] as? [String: Any]
                XCTAssertNil(user!["yob"])
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func testYOBWithNegative1() {
        let targeting = Targeting.shared
        XCTAssertThrowsError(try targeting.setYearOfBirth(yob: -1))
        let value = Targeting.shared.yearOfBirth
        XCTAssertFalse(value == -1)

        do {
            try RequestBuilder.shared.buildPrebidRequest(adUnit: adUnit) { (urlRequest) in
                let jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: urlRequest) as! [String: Any]
                let user = jsonRequestBody["user"] as? [String: Any]
                XCTAssertNil(user!["yob"])
            }
        } catch let error {
            print(error.localizedDescription)
        }

    }
    
    func testOpenRTBAppObjectWithoutData() {
        Targeting.shared.storeURL = ""
        Targeting.shared.domain = nil
        
        do {
            try RequestBuilder.shared.buildPrebidRequest(adUnit: adUnit) { (urlRequest) in
                let jsonRequestBody = PBHTTPStubbingManager.jsonBodyOfURLRequest(asDictionary: urlRequest) as! [String: Any]
                
                guard let app = jsonRequestBody["app"] as? [String: Any] else {
                    XCTFail("app object was not found")
                    return;
                }
                
                XCTAssertNil(app["storeurl"])
                XCTAssertNil(app["domain"])
            }
        } catch let error {
            print(error.localizedDescription)
        }
        
    }

    func validationResponse(jsonRequestBody: [String: Any]) {

        XCTAssertNotNil(jsonRequestBody["id"])
        XCTAssertNotNil(jsonRequestBody["source"])
        XCTAssertNotNil(jsonRequestBody["imp"])
        XCTAssertNotNil(jsonRequestBody["device"])
        XCTAssertNotNil(jsonRequestBody["app"])
        XCTAssertNotNil(jsonRequestBody["user"])
        XCTAssertNotNil(jsonRequestBody["ext"])

        if let impArray = jsonRequestBody["imp"] as? [Any], let impDic = impArray[0] as? [String: Any] {
            XCTAssertEqual("PrebidMobile", impDic["id"] as! String)
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
            XCTAssertEqual(RequestBuilder.DeviceUUID(), device["ifa"] as! String)
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
                if let storedrequest = prebid["storedrequest"] as? [String: Any] {
                    if let id = storedrequest["id"] as? String {
                        XCTAssertEqual("bfa84af2-bd16-4d35-96ad-31c6bb888df0", id)
                    }
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
            if let publisher = app["publisher"] as? [String: Any] {
                if let id = publisher["id"] as? String {
                    XCTAssertEqual("bfa84af2-bd16-4d35-96ad-31c6bb888df0", id)
                }
            }
            if let storeUrl = app["storeurl"] as? String {
                XCTAssertEqual(storeUrl, "https://itunes.apple.com/app/id123456789")
            } else {
                XCTFail("storeurl was not fount")
            }
            if let domain = app["domain"] as? String {
                XCTAssertEqual(domain, "appdomain.com")
            } else {
                XCTFail("domain was not fount")
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
