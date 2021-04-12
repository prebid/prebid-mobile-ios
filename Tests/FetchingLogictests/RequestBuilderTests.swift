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
#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif
import WebKit
@testable import PrebidMobile

class RequestBuilderTests: XCTestCase, CLLocationManagerDelegate {

    var app: XCUIApplication?
    var coreLocation: CLLocationManager?
    var adUnit: BannerAdUnit!
    override func setUp() {

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
        Targeting.shared.clearLocalStoredExternalUserIds()
        Prebid.shared.externalUserIdArray = []
    }

    func testPostData() throws {

        //given
        let targeting = Targeting.shared
        targeting.subjectToGDPR = true
        targeting.gdprConsentString = "testGDPR"
        targeting.purposeConsents = "100000000000000000000000"

        defer {
            targeting.subjectToGDPR = nil
            targeting.gdprConsentString = nil
            targeting.purposeConsents = nil
        }
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
    
    //MARK: - Prebid External UserId Array
    func testPostDataWithExternalUserIdsArray() throws {

        //given
        var externalUserIdArray = [ExternalUserId]()

        externalUserIdArray.append(ExternalUserId(source: "adserver.org", identifier: "111111111111", ext: ["rtiPartner" : "TDID"]))
        externalUserIdArray.append(ExternalUserId(source: "netid.de", identifier: "999888777"))
        externalUserIdArray.append(ExternalUserId(source: "criteo.com", identifier: "_fl7bV96WjZsbiUyQnJlQ3g4ckh5a1N"))
        externalUserIdArray.append(ExternalUserId(source: "liveramp.com", identifier: "AjfowMv4ZHZQJFM8TpiUnYEyA81Vdgg"))
        externalUserIdArray.append(ExternalUserId(source: "sharedid.org", identifier: "111111111111", atype: 1, ext: ["third" : "01ERJWE5FS4RAZKG6SKQ3ZYSKV"]))
        
        Prebid.shared.externalUserIdArray = externalUserIdArray

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let user = jsonRequestBody["user"] as? [String: Any],
            let ext = user["ext"] as? [String: Any], let eids = ext["eids"] as? [[String: AnyObject]] else {
            XCTFail("parsing error")
            return
        }

        //then
        XCTAssertEqual(5, eids.count)

        let adServerDic = eids[0]
        XCTAssertEqual("adserver.org", adServerDic["source"] as! String)
        let adServerUids = adServerDic["uids"] as! [[String : AnyObject]]
        XCTAssertEqual("111111111111", adServerUids[0]["id"] as! String)
        let adServerExt = adServerUids[0]["ext"] as! [String : AnyObject]
        XCTAssertEqual("TDID", adServerExt["rtiPartner"] as! String)


        let netIdDic = eids[1]
        XCTAssertEqual("netid.de", netIdDic["source"] as! String)
        let netIdUids = netIdDic["uids"] as! [[String : AnyObject]]
        XCTAssertEqual("999888777", netIdUids[0]["id"] as! String)


        let criteoDic = eids[2]
        XCTAssertEqual("criteo.com", criteoDic["source"] as! String)
        let criteoUids = criteoDic["uids"] as! [[String : AnyObject]]
        XCTAssertEqual("_fl7bV96WjZsbiUyQnJlQ3g4ckh5a1N", criteoUids[0]["id"] as! String)


        let liverampDic = eids[3]
        XCTAssertEqual("liveramp.com", liverampDic["source"] as! String)
        let liverampUids = liverampDic["uids"] as! [[String : AnyObject]]
        XCTAssertEqual("AjfowMv4ZHZQJFM8TpiUnYEyA81Vdgg", liverampUids[0]["id"] as! String)


        let sharedIdDic = eids[4]
        XCTAssertEqual("sharedid.org", sharedIdDic["source"] as! String)
        let sharedIdUids = sharedIdDic["uids"] as! [[String : AnyObject]]
        XCTAssertEqual("111111111111", sharedIdUids[0]["id"] as! String)
        XCTAssertEqual(1, sharedIdUids[0]["atype"] as! Int)
        let sharedIdExt = sharedIdUids[0]["ext"] as! [String : AnyObject]
        XCTAssertEqual("01ERJWE5FS4RAZKG6SKQ3ZYSKV", sharedIdExt["third"] as! String)
    }

    func testPostDataWithExternalUserIdsArrayForEmptySource() throws {

        //given
        var externalUserIdArray = [ExternalUserId]()
        externalUserIdArray.append(ExternalUserId(source: "", identifier: "999888777"))

        Prebid.shared.externalUserIdArray = externalUserIdArray

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let user = jsonRequestBody["user"] as? [String: Any] else {
            XCTFail("parsing error")
            return
        }

        let ext = user["ext"] as? [String: Any]
        let eids = ext?["eids"] as? [[String: AnyObject]]
        //then
        XCTAssertNil(eids)

    }

    func testPostDataWithExternalUserIdsArrayForEmptyUserId() throws {

        //given
        var externalUserIdArray = [ExternalUserId]()
        externalUserIdArray.append(ExternalUserId(source: "netid.de", identifier: ""))

        Prebid.shared.externalUserIdArray = externalUserIdArray

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let user = jsonRequestBody["user"] as? [String: Any] else {
            XCTFail("parsing error")
            return
        }

        let ext = user["ext"] as? [String: Any]
        let eids = ext?["eids"] as? [[String: AnyObject]]
        //then
        XCTAssertNil(eids)

    }
    
    //MARK: - Targeting External UserIds UserDefault
    func testPostDataWithTargetingExternalUserIds() throws {

        //given
        Targeting.shared.storeExternalUserId(ExternalUserId(source: "adserver.org", identifier: "111111111111", ext: ["rtiPartner" : "TDID"]))
        Targeting.shared.storeExternalUserId(ExternalUserId(source: "netid.de", identifier: "999888777"))
        Targeting.shared.storeExternalUserId(ExternalUserId(source: "criteo.com", identifier: "_fl7bV96WjZsbiUyQnJlQ3g4ckh5a1N"))
        Targeting.shared.storeExternalUserId(ExternalUserId(source: "liveramp.com", identifier: "AjfowMv4ZHZQJFM8TpiUnYEyA81Vdgg"))
        Targeting.shared.storeExternalUserId(ExternalUserId(source: "sharedid.org", identifier: "111111111111", atype: 1, ext: ["third" : "01ERJWE5FS4RAZKG6SKQ3ZYSKV"]))

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let user = jsonRequestBody["user"] as? [String: Any],
            let ext = user["ext"] as? [String: Any], let eids = ext["eids"] as? [[String: AnyObject]] else {
            XCTFail("parsing error")
            return
        }

        //then
        XCTAssertEqual(5, eids.count)

        let adServerDic = eids[0]
        XCTAssertEqual("adserver.org", adServerDic["source"] as! String)
        let adServerUids = adServerDic["uids"] as! [[String : AnyObject]]
        XCTAssertEqual("111111111111", adServerUids[0]["id"] as! String)
        let adServerExt = adServerUids[0]["ext"] as! [String : AnyObject]
        XCTAssertEqual("TDID", adServerExt["rtiPartner"] as! String)
        
        
        let netIdDic = eids[1]
        XCTAssertEqual("netid.de", netIdDic["source"] as! String)
        let netIdUids = netIdDic["uids"] as! [[String : AnyObject]]
        XCTAssertEqual("999888777", netIdUids[0]["id"] as! String)
        
        
        let criteoDic = eids[2]
        XCTAssertEqual("criteo.com", criteoDic["source"] as! String)
        let criteoUids = criteoDic["uids"] as! [[String : AnyObject]]
        XCTAssertEqual("_fl7bV96WjZsbiUyQnJlQ3g4ckh5a1N", criteoUids[0]["id"] as! String)
        
        
        let liverampDic = eids[3]
        XCTAssertEqual("liveramp.com", liverampDic["source"] as! String)
        let liverampUids = liverampDic["uids"] as! [[String : AnyObject]]
        XCTAssertEqual("AjfowMv4ZHZQJFM8TpiUnYEyA81Vdgg", liverampUids[0]["id"] as! String)
        
        
        let sharedIdDic = eids[4]
        XCTAssertEqual("sharedid.org", sharedIdDic["source"] as! String)
        let sharedIdUids = sharedIdDic["uids"] as! [[String : AnyObject]]
        XCTAssertEqual("111111111111", sharedIdUids[0]["id"] as! String)
        XCTAssertEqual(1, sharedIdUids[0]["atype"] as! Int)
        let sharedIdExt = sharedIdUids[0]["ext"] as! [String : AnyObject]
        XCTAssertEqual("01ERJWE5FS4RAZKG6SKQ3ZYSKV", sharedIdExt["third"] as! String)
    }
    
    func testPostDataWithTargetingExternalUserIdsForEmptySourceAndUserId() throws {

        //given
        Targeting.shared.storeExternalUserId(ExternalUserId(source: "", identifier: "", atype: nil, ext: nil))

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let user = jsonRequestBody["user"] as? [String: Any] else {
            XCTFail("parsing error")
            return
        }

        let ext = user["ext"] as? [String: Any]
        let eids = ext?["eids"] as? [[String: AnyObject]]
        //then
        XCTAssertNil(eids)
    }
    
    //MARK: - GDPR Subject
    func testPostDataGdprSubjectTrue() throws {

        //given
        let targeting = Targeting.shared
        targeting.subjectToGDPR = true
        defer {
            targeting.subjectToGDPR = nil
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

    func testPostDataGdprSubjectFalse() throws {

        //given
        let targeting = Targeting.shared
        targeting.subjectToGDPR = false
        defer {
            targeting.subjectToGDPR = nil
        }

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        let regs = jsonRequestBody["regs"] as? [String: Any]

        //then
        XCTAssertNil(regs)
    }

    func testPostDataGdprSubjectUndefined() throws {

        //given
        let targeting = Targeting.shared
        targeting.subjectToGDPR = nil

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        let regs = jsonRequestBody["regs"] as? [String: Any]

        //then
        XCTAssertNil(regs)
    }
    
    //MARK: - GDPR Consent
    func testPostDataGdprConsent() throws {

        //given
        let targeting = Targeting.shared
        targeting.subjectToGDPR = true
        targeting.gdprConsentString = "BOEFEAyOEFEAyAHABDENAI4AAAB9vABAASA"

        defer {
            targeting.subjectToGDPR = nil
            targeting.gdprConsentString = nil
        }

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
        XCTAssertEqual("BOEFEAyOEFEAyAHABDENAI4AAAB9vABAASA", consent)

    }

    func testPostDataGdprConsentAndGdprSubjectFalse() throws {

        //given
        let targeting = Targeting.shared
        targeting.subjectToGDPR = false
        targeting.gdprConsentString = "testGDPR"

        defer {
            targeting.subjectToGDPR = nil
            targeting.gdprConsentString = nil
        }

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        let gdpr: [String : Any]? = jsonRequestBody["regs"] as? [String: Any]

        guard let user = jsonRequestBody["user"] as? [String: Any] else {

            XCTFail("parsing error")
            return

        }

        let consent = user["ext"] as? [String: Any]

        //then
        XCTAssertNil(gdpr)
        XCTAssertNil(consent)

    }
    
    //MARK: - TCFv2
    func testPostDataIfa() throws {

        //given
        let targeting = Targeting.shared
        targeting.subjectToGDPR = false
        targeting.purposeConsents = "100000000000000000000000"

        defer {
            targeting.subjectToGDPR = nil
            targeting.purposeConsents = nil
        }

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

    //TCFv2 and gdpr
    //fetch advertising identifier based TCF 2.0 Purpose1 value
    //truth table
    /*
                           deviceAccessConsent=true  deviceAccessConsent=false  deviceAccessConsent undefined
     gdprApplies=false        (1)Yes, read IDFA       (2)No, don’t read IDFA           (3)Yes, read IDFA
     gdprApplies=true         (4)Yes, read IDFA       (5)No, don’t read IDFA           (6)No, don’t read IDFA
     gdprApplies=undefined    (7)Yes, read IDFA       (8)No, don’t read IDFA           (9)Yes, read IDFA
     */
    func testPostDataIfaPermission() throws {
        //(1)
        try! postDataIfaHelper(gdprApplies: false, purposeConsents: "100000000000000000000000", hasIfa: true)
        //(2)
        try! postDataIfaHelper(gdprApplies: false, purposeConsents: "000000000000000000000000", hasIfa: false)
        //(3)
        try! postDataIfaHelper(gdprApplies: false, purposeConsents: nil, hasIfa: true)
        //(4)
        try! postDataIfaHelper(gdprApplies: true, purposeConsents: "100000000000000000000000", hasIfa: true)
        //(5)
        try! postDataIfaHelper(gdprApplies: true, purposeConsents: "000000000000000000000000", hasIfa: false)
        //(6)
        try! postDataIfaHelper(gdprApplies: true, purposeConsents: nil, hasIfa: false)
        //(7)
        try! postDataIfaHelper(gdprApplies: nil, purposeConsents: "100000000000000000000000", hasIfa: true)
        //(8)
        try! postDataIfaHelper(gdprApplies: nil, purposeConsents: "000000000000000000000000", hasIfa: false)
        //(9)
        try! postDataIfaHelper(gdprApplies: nil, purposeConsents: nil, hasIfa: true)

    }

    func postDataIfaHelper(gdprApplies: Bool?, purposeConsents:String?, hasIfa: Bool) throws {
        //given
        let targeting = Targeting.shared
        targeting.subjectToGDPR = gdprApplies
        targeting.purposeConsents = purposeConsents

        defer {
            targeting.subjectToGDPR = nil
            targeting.purposeConsents = nil
        }

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let regs = jsonRequestBody["device"] as? [String: Any] else {

            XCTFail("parsing error")
            return
        }

        let ifa = regs["ifa"] as? String

        //then
        XCTAssertEqual(hasIfa, ifa != nil)
    }

    //MARK: - COPPA
    func testPostDataCoppaTrue() throws {

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
    
    func testPostDataCoppaFalse() throws {

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
    
    //MARK: - CCPA
    func testPostDataCcpa() throws {

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
    
    func testPostDataCcpaEmptyValue() throws {

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
    
    func testPostDataCcpaUndefined() throws {

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

    //MARK: - FirstPartyData

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
    
    func testBannerBaseAdUnit() throws {

        //given
        let adUnit = BannerAdUnit(configId: Constants.configID1, size: CGSize(width: 300, height: 250))
        
        let parameters = BannerAdUnit.Parameters()
        parameters.api = [Signals.Api.VPAID_1, Signals.Api.VPAID_2]
        
        adUnit.parameters = parameters
        
        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let imp = jsonRequestBody["imp"] as? [Any],
            let imp0 = imp[0] as? [String: Any],
            let banner = imp0["banner"] as? [String: Any],
            let api = banner["api"] as? [Int] else {

                XCTFail("parsing fail")
                return

        }

        //then
        XCTAssertEqual(2, api.count)
        XCTAssert(api.contains(1) && api.contains(2))

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
    
    func testPostDataWithOmidNameAndVersion() throws {
        
        //given
        let name = "PartnerName"
        let version = "1.0"
        
        var omidPartherName: String?
        var omidPartherVersion: String?
        
        Targeting.shared.omidPartnerName = name
        Targeting.shared.omidPartnerVersion = version
        
        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody
        
        if let source = jsonRequestBody["source"] as? [String: Any],
            let ext = source["ext"] as? [String: Any] {
            
            omidPartherName = ext["omidpn"] as? String
            omidPartherVersion = ext["omidpv"] as? String
            
        }
        
        //then
        XCTAssertEqual(name, omidPartherName)
        XCTAssertEqual(version, omidPartherVersion)
    }
    
    func testPostDataWithoutOmidNameAndVersion() throws {
        
        //given
        var omidPartherName: String?
        var omidPartherVersion: String?
        
        Targeting.shared.omidPartnerName = nil
        Targeting.shared.omidPartnerVersion = nil
        
        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody
        
        if let source = jsonRequestBody["source"] as? [String: Any],
            let ext = source["ext"] as? [String: Any] {
            
            omidPartherName = ext["omidpn"] as? String
            omidPartherVersion = ext["omidpv"] as? String
            
        }
        
        //then
        XCTAssertNil(omidPartherName)
        XCTAssertNil(omidPartherVersion)
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
    
    func testPbsDebug() throws {
        try pbsDebugHelper(pbsDebug: true, expectedTest: 1)
        try pbsDebugHelper(pbsDebug: false, expectedTest: nil)

    }

    func pbsDebugHelper(pbsDebug: Bool, expectedTest: Int?) throws {
        //given
        Prebid.shared.pbsDebug = pbsDebug

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        let test = jsonRequestBody["test"] as? Int

        //then
        XCTAssertEqual(expectedTest, test)
    }

    func testVideoAdUnit() throws {
        //given
        Prebid.shared.prebidServerAccountId = "12345"
        let adUnit = VideoAdUnit(configId: Constants.configID1, size: CGSize(width: 300, height: 250))

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let impArray = jsonRequestBody["imp"] as? [Any],
            let impDic = impArray[0] as? [String: Any],
            let video = impDic["video"] as? [String: Any],
            let w = video["w"] as? Int,
            let h = video["h"] as? Int,
            let linearity = video["linearity"] as? Int,

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
        XCTAssertNotNil(w)
        XCTAssertNotNil(h)

        XCTAssertEqual(5, placement)
        XCTAssertEqual(1, linearity)

        XCTAssertNotNil(vastXml)

        XCTAssertEqual(1, instl)

    }

    func testRewardedVideoAdUnit() throws {
        //given
        Prebid.shared.prebidServerAccountId = "12345"
        let adUnit = RewardedVideoAdUnit(configId: Constants.configID1)

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let impArray = jsonRequestBody["imp"] as? [Any],
            let impDic = impArray[0] as? [String: Any],
            let video = impDic["video"] as? [String: Any],
            let w = video["w"] as? Int,
            let h = video["h"] as? Int,
            let placement = video["placement"] as? Int,
            let linearity = video["linearity"] as? Int,

            let ext = jsonRequestBody["ext"] as? [String: Any],
            let extPrebid = ext["prebid"] as? [String: Any],
            let cache = extPrebid["cache"] as? [String: Any],
            let vastXml = cache["vastxml"] as? [String: Any],

            let instl = impDic["instl"] as? Int,

            let impExt = impDic["ext"] as? [String: Any],
            let prebid = impExt["prebid"] as? [String: Any],
            let isRewarded = prebid["is_rewarded_inventory"] as? Int

            else {
                XCTFail("parsing fail")
                return
        }

        //then
        XCTAssertNotNil(w)
        XCTAssertNotNil(h)

        XCTAssertEqual(5, placement)
        XCTAssertEqual(1, linearity)

        XCTAssertNotNil(vastXml)

        XCTAssertEqual(1, instl)

        XCTAssertEqual(1, isRewarded)

    }

    func testVideoBaseAdUnit() throws {
        //given
        Prebid.shared.prebidServerAccountId = "12345"
        let adUnit = VideoAdUnit(configId: Constants.configID1, size: CGSize(width: 300, height: 250))

        let parameters = VideoBaseAdUnit.Parameters()

        parameters.api = [Signals.Api.VPAID_1, Signals.Api.VPAID_2]
        parameters.maxBitrate = 1500
        parameters.minBitrate = 300
        parameters.maxDuration = 30
        parameters.minDuration = 5
        parameters.mimes = ["video/x-flv", "video/mp4"]
        parameters.playbackMethod = [Signals.PlaybackMethod.AutoPlaySoundOn, Signals.PlaybackMethod.ClickToPlay]
        parameters.protocols = [Signals.Protocols.VAST_2_0, Signals.Protocols.VAST_3_0]
        parameters.startDelay = Signals.StartDelay.PreRoll
        parameters.placement = Signals.Placement.InBanner

        adUnit.parameters = parameters

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let impArray = jsonRequestBody["imp"] as? [Any],
            let impDic = impArray[0] as? [String: Any],
            let video = impDic["video"] as? [String: Any],

            let api = video["api"] as? [Int],
            let maxBitrate = video["maxbitrate"] as? Int,
            let minBitrate = video["minbitrate"] as? Int,
            let maxDuration = video["maxduration"] as? Int,
            let minDuration = video["minduration"] as? Int,
            let mimes = video["mimes"] as? [String],
            let playbackMethod = video["playbackmethod"] as? [Int],
            let protocols = video["protocols"] as? [Int],
            let startDelay = video["startdelay"] as? Int,
            let placement = video["placement"] as? Int

            else {
                XCTFail("parsing fail")
                return
        }

        //then
        XCTAssertEqual(2, api.count)
        XCTAssert(api.contains(1) && api.contains(2))
        XCTAssertEqual(1500, maxBitrate)
        XCTAssertEqual(300, minBitrate)
        XCTAssertEqual(30, maxDuration)
        XCTAssertEqual(5, minDuration)
        XCTAssertEqual(2, mimes.count)
        XCTAssert(mimes.contains("video/x-flv") && mimes.contains("video/mp4"))
        XCTAssertEqual(2, playbackMethod.count)
        XCTAssert(playbackMethod.contains(1) && playbackMethod.contains(3))
        XCTAssertEqual(2, protocols.count)
        XCTAssert(protocols.contains(2) && protocols.contains(3))
        XCTAssertEqual(0, startDelay)
        XCTAssertEqual(2, placement)

    }

    func testPrebidAdSlot() throws {

        //given
        adUnit = BannerAdUnit(configId: Constants.configID1, size: CGSize(width: Constants.width2, height: Constants.height2))
        adUnit.pbAdSlot = "/1111111/homepage/med-rect-2"

        //when
        let jsonRequestBody = try getPostDataHelper(adUnit: adUnit).jsonRequestBody

        guard let impArray = jsonRequestBody["imp"] as? [Any],
            let impDic = impArray[0] as? [String: Any],
            let ext = impDic["ext"] as? [String: Any],
            let context = ext["context"] as? [String: Any],
            let data = context["data"] as? [String: Any],
            let adslot = data["adslot"] as? String else {
                XCTFail("parsing fail")
                return
        }

        //then
        XCTAssertEqual("/1111111/homepage/med-rect-2", adslot)
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
            
            let deviceExt = device["ext"] as? [String: Any]
            #if canImport(AppTrackingTransparency)
            if #available(iOS 14, *) {
                let atts = deviceExt!["atts"] as! Int
                XCTAssertEqual(Int(ATTrackingManager.trackingAuthorizationStatus.rawValue), atts)
            }
            
            let lmtAd: Bool = !ASIdentifierManager.shared().isAdvertisingTrackingEnabled
            XCTAssertEqual(NSNumber(value: lmtAd).intValue, device["lmt"] as! Int)
            
            #else
                let lmtAd: Bool = !ASIdentifierManager.shared().isAdvertisingTrackingEnabled
                XCTAssertEqual(NSNumber(value: lmtAd).intValue, device["lmt"] as! Int)
            #endif
            
            
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
                    XCTAssertEqual(prebidSdkVersion, prebid["version"] as? String)
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
