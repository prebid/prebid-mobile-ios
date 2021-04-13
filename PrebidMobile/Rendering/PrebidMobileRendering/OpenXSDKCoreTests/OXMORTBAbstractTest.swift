//
//  OXMORTBBidRequestTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2017 OpenX. All rights reserved.
//

import Foundation
import XCTest
@testable import PrebidMobileRendering

class OXMORTBAbstractTest : XCTestCase {

    private var sdkVersion: String {
        let infoDic = Bundle(for: OXABannerView.self).infoDictionary
        return infoDic!["CFBundleShortVersionString"] as! String
    }
    
    private var omidVersion: String {
        return OXMFunctions.omidVersion();
    }
    
    private let userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 OpenXSDK/\(OXASDKConfiguration.sdkVersion)"
    
    private var logToFile: LogToFileLock?
    
    override func tearDown() {
        logToFile = nil
        super.tearDown()
    }

    //Check default values of all objects decending from OXMORTBAbstract
    func testDefaultToJsonString() {

        codeAndDecode(abstract:OXMORTBBidRequest(), expectedString: "{\"app\":{},\"device\":{\"geo\":{}},\"imp\":[{\"clickbrowser\":0,\"displaymanager\":\"openx\",\"ext\":{\"dlp\":1},\"instl\":0,\"secure\":0}],\"source\":{\"ext\":{\"omidpn\":\"Openx\",\"omidpv\":\"\(omidVersion)\"}},\"user\":{}}")
        
        //Source not implemented
        codeAndDecode(abstract:OXMORTBRegs(), expectedString: "{}")
        codeAndDecode(abstract:OXMORTBImp(), expectedString: "{\"clickbrowser\":0,\"displaymanager\":\"openx\",\"ext\":{\"dlp\":1},\"instl\":0,\"secure\":0}")
        
        //Metric not implemented
        codeAndDecode(abstract:OXMORTBBanner(), expectedString: "{\"api\":[]}")
        codeAndDecode(abstract:OXMORTBVideo(), expectedString: "{\"delivery\":[3],\"mimes\":[\"video\\/mp4\",\"video\\/quicktime\",\"video\\/x-m4v\",\"video\\/3gpp\",\"video\\/3gpp2\"],\"playbackend\":2,\"pos\":7,\"protocols\":[2,5]}")
        
        //Audio not implemented
        //Native not implemented
        codeAndDecode(abstract:OXMORTBFormat(), expectedString: "{}")
        codeAndDecode(abstract:OXMORTBPmp(), expectedString: "{}")
        codeAndDecode(abstract:OXMORTBDeal(), expectedString: "{\"bidfloor\":0,\"bidfloorcur\":\"USD\",\"wadomain\":[],\"wseat\":[]}")

        //Site not implemented
        codeAndDecode(abstract:OXMORTBApp(), expectedString: "{}")
        //Publisher not implemented
        //Content not implemented
        //Producer not implemented
        codeAndDecode(abstract:OXMORTBDevice(), expectedString: "{\"geo\":{}}")
        codeAndDecode(abstract:OXMORTBGeo(), expectedString: "{}")
        codeAndDecode(abstract:OXMORTBUser(), expectedString: "{}")
        //Data not implemented
        //Segment not implemented
        
        codeAndDecode(abstract:OXMORTBBidRequestExtPrebid(), expectedString: "{}")
        codeAndDecode(abstract:OXMORTBImpExtPrebid(), expectedString: "{}")
    }
    
    func testAbstractMethods() {
        logToFile = .init()
        
        let abstract = try! OXMORTBAbstract.from(jsonString: "")
        let _ = try! abstract.toJsonString()
        
        let log = OXMLog.singleton.getLogFileAsString()
        XCTAssert(log.contains("You should not initialize abstract class directly"))
        XCTAssert(log.contains("You must override toJsonDictionary in a subclass"))
    }
    
    func testCopying() {
        let initial = OXMORTBBidRequest()
        
        initial.imp[0].banner = OXMORTBBanner()
        initial.imp[0].video = OXMORTBVideo()
        initial.imp[0].pmp.deals = [OXMORTBDeal()]
        
        initial.imp[0].banner?.format = [OXMORTBFormat()]
        initial.imp[0].banner?.format[0].w = 640
        initial.imp[0].banner?.format[0].h = 480
        initial.imp[0].banner?.format[0].wratio = 4
        initial.imp[0].banner?.format[0].hratio = 3
        initial.imp[0].banner?.format[0].wmin = 160
        
        initial.extPrebid.storedRequestID = "testAccID"
        initial.imp[0].extPrebid.storedRequestID = "testCfgID"
        
        XCTAssertFalse(initial.imp[0].extPrebid.isRewardedInventory)
        initial.imp[0].extPrebid.isRewardedInventory = true
        
        let copy = initial.copy() as! OXMORTBBidRequest
        
        XCTAssertNotEqual(initial, copy)
        
        XCTAssertNotEqual(initial.imp, copy.imp)
        XCTAssertEqual(initial.imp.count, 1)
        XCTAssertEqual(initial.imp.count, copy.imp.count)
        for i in (0 ..< initial.imp.count) {
        
            let impInitial = initial.imp[i]
            let impCopy = copy.imp[i]
        
            XCTAssertNotEqual(impInitial, impCopy)
        
            XCTAssertNotEqual(impInitial.banner, impCopy.banner)
            
            XCTAssertNotEqual(impInitial.banner?.format, impCopy.banner?.format)
            XCTAssertNotEqual(impInitial.banner?.format[0], impCopy.banner?.format[0])
            XCTAssertEqual(impInitial.banner?.format[0].w, impCopy.banner?.format[0].w)
            XCTAssertEqual(impInitial.banner?.format[0].h, impCopy.banner?.format[0].h)
            XCTAssertEqual(impInitial.banner?.format[0].wratio, impCopy.banner?.format[0].wratio)
            XCTAssertEqual(impInitial.banner?.format[0].hratio, impCopy.banner?.format[0].hratio)
            XCTAssertEqual(impInitial.banner?.format[0].wmin, impCopy.banner?.format[0].wmin)
            
            XCTAssertNotEqual(impInitial.video, impCopy.video)
            
            XCTAssertNotEqual(impInitial.extPrebid, impCopy.extPrebid)
            XCTAssertEqual(impInitial.extPrebid.storedRequestID, impCopy.extPrebid.storedRequestID)
            XCTAssertEqual(impInitial.extPrebid.isRewardedInventory, impCopy.extPrebid.isRewardedInventory)

            XCTAssertNotEqual(impInitial.pmp, impCopy.pmp)
        
            XCTAssertNotEqual(impInitial.pmp.deals, impCopy.pmp.deals)
            XCTAssertEqual(impInitial.pmp.deals.count, 1)
            XCTAssertEqual(impInitial.pmp.deals.count, impCopy.pmp.deals.count)
        
            for j in (0 ..< impInitial.pmp.deals.count) {
                XCTAssertNotEqual(impInitial.pmp.deals[j], impCopy.pmp.deals[j])
            }
        }
        
        XCTAssertNotEqual(initial.app, copy.app)
        
        XCTAssertNotEqual(initial.device, copy.device)
        XCTAssertNotEqual(initial.device.geo, copy.device.geo)
        
        XCTAssertNotEqual(initial.user, copy.user)
        XCTAssertNotEqual(initial.user.geo, copy.user.geo)
        
        XCTAssertNotEqual(initial.regs, copy.regs)
        
        XCTAssertNotEqual(initial.extPrebid, copy.extPrebid)
        XCTAssertEqual(initial.extPrebid.storedRequestID, copy.extPrebid.storedRequestID)
    }
    
    func testBidRequestToJsonString() {
        let oxmORTBBidRequest = OXMORTBBidRequest()
        let uuid = UUID().uuidString
        oxmORTBBidRequest.requestID = uuid
        
        codeAndDecode(abstract: oxmORTBBidRequest, expectedString: "{\"app\":{},\"device\":{\"geo\":{}},\"id\":\"\(uuid)\",\"imp\":[{\"clickbrowser\":0,\"displaymanager\":\"openx\",\"ext\":{\"dlp\":1},\"instl\":0,\"secure\":0}],\"source\":{\"ext\":{\"omidpn\":\"Openx\",\"omidpv\":\"\(omidVersion)\"}},\"user\":{}}")
        
        oxmORTBBidRequest.tmax = 2000
        
        codeAndDecode(abstract: oxmORTBBidRequest, expectedString: "{\"app\":{},\"device\":{\"geo\":{}},\"id\":\"\(uuid)\",\"imp\":[{\"clickbrowser\":0,\"displaymanager\":\"openx\",\"ext\":{\"dlp\":1},\"instl\":0,\"secure\":0}],\"source\":{\"ext\":{\"omidpn\":\"Openx\",\"omidpv\":\"\(omidVersion)\"}},\"tmax\":2000,\"user\":{}}")
        
        oxmORTBBidRequest.test = 2
        
        codeAndDecode(abstract: oxmORTBBidRequest, expectedString: "{\"app\":{},\"device\":{\"geo\":{}},\"id\":\"\(uuid)\",\"imp\":[{\"clickbrowser\":0,\"displaymanager\":\"openx\",\"ext\":{\"dlp\":1},\"instl\":0,\"secure\":0}],\"source\":{\"ext\":{\"omidpn\":\"Openx\",\"omidpv\":\"\(omidVersion)\"}},\"test\":2,\"tmax\":2000,\"user\":{}}")
    }
    
    func testBidRequestExtPrebidToJsonString() {
        let extPrebid = OXMORTBBidRequestExtPrebid()
        extPrebid.storedRequestID = "b4eb1475-4e3d-4186-97b7-25b6a6cf8618"
        extPrebid.dataBidders = ["openx", "apollo", "thanatos"]
        
        codeAndDecode(abstract: extPrebid, expectedString: "{\"cache\":{\"bids\":{},\"vastxml\":{}},\"data\":{\"bidders\":[\"openx\",\"apollo\",\"thanatos\"]},\"storedrequest\":{\"id\":\"b4eb1475-4e3d-4186-97b7-25b6a6cf8618\"},\"targeting\":{}}")
        
        let oxmORTBBidRequest = OXMORTBBidRequest()
        oxmORTBBidRequest.extPrebid = extPrebid
        
        codeAndDecode(abstract: oxmORTBBidRequest, expectedString: "{\"app\":{},\"device\":{\"geo\":{}},\"ext\":{\"prebid\":{\"cache\":{\"bids\":{},\"vastxml\":{}},\"data\":{\"bidders\":[\"openx\",\"apollo\",\"thanatos\"]},\"storedrequest\":{\"id\":\"b4eb1475-4e3d-4186-97b7-25b6a6cf8618\"},\"targeting\":{}}},\"imp\":[{\"clickbrowser\":0,\"displaymanager\":\"openx\",\"ext\":{\"dlp\":1},\"instl\":0,\"secure\":0}],\"source\":{\"ext\":{\"omidpn\":\"Openx\",\"omidpv\":\"\(omidVersion)\"}},\"user\":{}}")
    }
    
    func testSourceToJsonString() {
        let oxmORTBSource = OXMORTBSource()
        
        let tid = UUID().uuidString
        let pchain = "some_pchain_string"
        
        oxmORTBSource.fd = 0
        oxmORTBSource.tid = tid
        oxmORTBSource.pchain = pchain
        
        codeAndDecode(abstract: oxmORTBSource, expectedString: "{\"ext\":{\"omidpn\":\"Openx\",\"omidpv\":\"\(omidVersion)\"},\"fd\":0,\"pchain\":\"\(pchain)\",\"tid\":\"\(tid)\"}")
    }
    
    func testRegsToJsonString() {
        let oxmORTBRegs = OXMORTBRegs()
        oxmORTBRegs.coppa = 1
        XCTAssertEqual(oxmORTBRegs.coppa, 1)
        codeAndDecode(abstract:oxmORTBRegs, expectedString:"{\"coppa\":1}")
        
        oxmORTBRegs.coppa = 0
        XCTAssertEqual(oxmORTBRegs.coppa, 0)
        codeAndDecode(abstract:oxmORTBRegs, expectedString:"{\"coppa\":0}")

        oxmORTBRegs.coppa = -1
        XCTAssertEqual(oxmORTBRegs.coppa, nil)
        codeAndDecode(abstract:oxmORTBRegs, expectedString:"{}")

        oxmORTBRegs.coppa = 1.5
        XCTAssertEqual(oxmORTBRegs.coppa, nil)
        codeAndDecode(abstract:oxmORTBRegs, expectedString:"{}")
    }

    func testImpToJsonString() {
        let oxmORTBImp = OXMORTBImp()
        
        let uuid = UUID().uuidString
        oxmORTBImp.impID = uuid
        oxmORTBImp.banner = OXMORTBBanner()
        oxmORTBImp.video = OXMORTBVideo()
        oxmORTBImp.native = OXMORTBNative()
        oxmORTBImp.pmp = OXMORTBPmp()
        oxmORTBImp.displaymanager = "MOCK_SDK_NAME"
        oxmORTBImp.displaymanagerver = "MOCK_SDK_VERSION"
        oxmORTBImp.instl = 1
        oxmORTBImp.tagid = "tagid"
        oxmORTBImp.secure = 1
        oxmORTBImp.extContextData = ["lookup_words": ["dragon", "flame"]]
        
        codeAndDecode(abstract: oxmORTBImp, expectedString: "{\"banner\":{\"api\":[]},\"clickbrowser\":0,\"displaymanager\":\"MOCK_SDK_NAME\",\"displaymanagerver\":\"MOCK_SDK_VERSION\",\"ext\":{\"context\":{\"data\":{\"lookup_words\":[\"dragon\",\"flame\"]}},\"dlp\":1},\"id\":\"\(uuid)\",\"instl\":1,\"native\":{\"ver\":\"1.2\"},\"secure\":1,\"tagid\":\"tagid\",\"video\":{\"delivery\":[3],\"mimes\":[\"video\\/mp4\",\"video\\/quicktime\",\"video\\/x-m4v\",\"video\\/3gpp\",\"video\\/3gpp2\"],\"playbackend\":2,\"pos\":7,\"protocols\":[2,5]}}")
    }
    
    func testNativeToJsonString() {
        let oxmORTBNative = OXMORTBNative()
        
        XCTAssertEqual(oxmORTBNative.ver, "1.2")
        XCTAssertNil(oxmORTBNative.request as NSString?)
        XCTAssertNil(oxmORTBNative.api)
        XCTAssertNil(oxmORTBNative.battr)
        
        codeAndDecode(abstract: oxmORTBNative, expectedString: "{\"ver\":\"1.2\"}")
        
        oxmORTBNative.request = "some request string goes here"
        oxmORTBNative.api = [42]
        oxmORTBNative.battr = [1, 3, 13]
        
        codeAndDecode(abstract: oxmORTBNative, expectedString: "{\"api\":[42],\"battr\":[1,3,13],\"request\":\"some request string goes here\",\"ver\":\"1.2\"}")
    }
    
    func testImpExtPrebidToJsonString() {
        let extPrebid = OXMORTBImpExtPrebid()
        extPrebid.storedRequestID = "b4eb1475-4e3d-4186-97b7-25b6a6cf8618"
        XCTAssertFalse(extPrebid.isRewardedInventory)
        
        codeAndDecode(abstract: extPrebid, expectedString: "{\"storedrequest\":{\"id\":\"b4eb1475-4e3d-4186-97b7-25b6a6cf8618\"}}")
        
        let oxmORTBImp = OXMORTBImp()
        oxmORTBImp.extPrebid = extPrebid
        
        codeAndDecode(abstract: oxmORTBImp, expectedString: "{\"clickbrowser\":0,\"displaymanager\":\"openx\",\"ext\":{\"prebid\":{\"storedrequest\":{\"id\":\"b4eb1475-4e3d-4186-97b7-25b6a6cf8618\"}}},\"instl\":0,\"secure\":0}")
    }
    
    func testImpExtPrebidToJsonStringRewarded() {
        let extPrebid = OXMORTBImpExtPrebid()
        extPrebid.storedRequestID = "b4eb1475-4e3d-4186-97b7-25b6a6cf8618"
        extPrebid.isRewardedInventory = true
        
        codeAndDecode(abstract: extPrebid, expectedString: "{\"is_rewarded_inventory\":1,\"storedrequest\":{\"id\":\"b4eb1475-4e3d-4186-97b7-25b6a6cf8618\"}}")
        
        let oxmORTBImp = OXMORTBImp()
        oxmORTBImp.extPrebid = extPrebid
        
        codeAndDecode(abstract: oxmORTBImp, expectedString: "{\"clickbrowser\":0,\"displaymanager\":\"openx\",\"ext\":{\"prebid\":{\"is_rewarded_inventory\":1,\"storedrequest\":{\"id\":\"b4eb1475-4e3d-4186-97b7-25b6a6cf8618\"}}},\"instl\":0,\"secure\":0}")
    }
    
    func testBannerToJsonString() {
        let oxmORTBBanner = OXMORTBBanner()
        oxmORTBBanner.pos = 1                   //Above the fold
        oxmORTBBanner.api = [2,5]

        codeAndDecode(abstract: oxmORTBBanner, expectedString: "{\"api\":[2,5],\"pos\":1}")
        
        oxmORTBBanner.format = [OXMORTBFormat()]
        oxmORTBBanner.format[0].w = 728
        oxmORTBBanner.format[0].h = 90

        codeAndDecode(abstract: oxmORTBBanner, expectedString: "{\"api\":[2,5],\"format\":[{\"h\":90,\"w\":728}],\"pos\":1}")
    }
    
    func testVideoToJsonString() {
        let oxmORTBVideo = OXMORTBVideo()
        
        oxmORTBVideo.minduration = 10
        oxmORTBVideo.maxduration = 100
        oxmORTBVideo.w = 100
        oxmORTBVideo.h = 200
        oxmORTBVideo.startdelay = 5
        oxmORTBVideo.linearity = 1
        oxmORTBVideo.minbitrate = 20
        oxmORTBVideo.maxbitrate = 40
 
        codeAndDecode(abstract: oxmORTBVideo, expectedString: "{\"delivery\":[3],\"h\":200,\"linearity\":1,\"maxbitrate\":40,\"maxduration\":100,\"mimes\":[\"video\\/mp4\",\"video\\/quicktime\",\"video\\/x-m4v\",\"video\\/3gpp\",\"video\\/3gpp2\"],\"minbitrate\":20,\"minduration\":10,\"playbackend\":2,\"pos\":7,\"protocols\":[2,5],\"startdelay\":5,\"w\":100}")
    }
    
    func testFormatToJsonString() {
        let oxmORTBFormat = OXMORTBFormat()
        oxmORTBFormat.w = 320
        oxmORTBFormat.h = 50
        codeAndDecode(abstract: oxmORTBFormat, expectedString: "{\"h\":50,\"w\":320}")
        
        oxmORTBFormat.w = nil
        oxmORTBFormat.h = nil
        oxmORTBFormat.wratio = 16
        oxmORTBFormat.hratio = 9
        oxmORTBFormat.wmin = 60
        codeAndDecode(abstract: oxmORTBFormat, expectedString: "{\"hratio\":9,\"wmin\":60,\"wratio\":16}")
    }

    func testPmpToJsonString() {
        let oxmORTBPmp = OXMORTBPmp()
        oxmORTBPmp.private_auction = 1
        oxmORTBPmp.deals.append(OXMORTBDeal())
        oxmORTBPmp.deals.first?.bidfloor = 1.0
        
        codeAndDecode(abstract: oxmORTBPmp, expectedString: "{\"deals\":[{\"bidfloor\":1,\"bidfloorcur\":\"USD\",\"wadomain\":[],\"wseat\":[]}],\"private_auction\":1}")
    }
    
    func testDealToJsonString() {
        let oxmORTBDeal = OXMORTBDeal()
        
        oxmORTBDeal.id = "id"
        oxmORTBDeal.bidfloor = 100.0
        oxmORTBDeal.bidfloorcur = "GBP"
        oxmORTBDeal.at = 1
        oxmORTBDeal.wseat = ["seat1", "seat2", "seat3"]
        oxmORTBDeal.wadomain = ["advertiser1.com", "advertiser2.com", "advertiser3.com"]
        
        codeAndDecode(abstract: oxmORTBDeal, expectedString: "{\"at\":1,\"bidfloor\":100,\"bidfloorcur\":\"GBP\",\"id\":\"id\",\"wadomain\":[\"advertiser1.com\",\"advertiser2.com\",\"advertiser3.com\"],\"wseat\":[\"seat1\",\"seat2\",\"seat3\"]}")
    }
    
    func testAppToJsonString() {
        
        let oxmORTBApp = OXMORTBApp()
        
        oxmORTBApp.id = "foo"
        oxmORTBApp.name = "PubApp"
        oxmORTBApp.bundle = "com.PubApp"
        oxmORTBApp.domain = "pubapp.com"
        oxmORTBApp.storeurl = "itunes.com?pubapp"
        oxmORTBApp.ver = "1.2"
        oxmORTBApp.privacypolicy = 1
        oxmORTBApp.paid = 1
        oxmORTBApp.keywords = "foo,bar,baz"
        
        codeAndDecode(abstract: oxmORTBApp, expectedString: "{\"bundle\":\"com.PubApp\",\"domain\":\"pubapp.com\",\"id\":\"foo\",\"keywords\":\"foo,bar,baz\",\"name\":\"PubApp\",\"paid\":1,\"privacypolicy\":1,\"storeurl\":\"itunes.com?pubapp\",\"ver\":\"1.2\"}")
    }
    
    func testAppExtPrebidToJsonString() {
        let oxmORTBApp = OXMORTBApp()
        let appExtPrebid = oxmORTBApp.extPrebid
        
        codeAndDecode(abstract: appExtPrebid, expectedString: "{}")
        
        appExtPrebid.source = "openx"
        appExtPrebid.version = sdkVersion
        appExtPrebid.data = ["app_categories": ["news", "movies"]]
        
        codeAndDecode(abstract: appExtPrebid, expectedString: "{\"data\":{\"app_categories\":[\"news\",\"movies\"]},\"source\":\"openx\",\"version\":\"\(sdkVersion)\"}")
        
        codeAndDecode(abstract: oxmORTBApp, expectedString: "{\"ext\":{\"prebid\":{\"data\":{\"app_categories\":[\"news\",\"movies\"]},\"source\":\"openx\",\"version\":\"\(sdkVersion)\"}}}")
    }
    
    func testDeviceWithIfaToJsonString() {
        let oxmORTBPDevice = initORTBDevice(ifa: "ifa")
        oxmORTBPDevice.ua = userAgent
        let userAgentEscaped = userAgent.replacingOccurrences(of: "/", with: "\\/")
        codeAndDecode(abstract: oxmORTBPDevice, expectedString: "{\"carrier\":\"AT&T\",\"connectiontype\":6,\"devicetype\":1,\"didmd5\":\"didmd5\",\"didsha1\":\"didsha1\",\"geo\":{},\"geofetch\":1,\"h\":100,\"ifa\":\"ifa\",\"js\":1,\"language\":\"en\",\"lmt\":1,\"make\":\"Apple\",\"mccmnc\":\"310-680\",\"model\":\"iPhone\",\"os\":\"iOS\",\"osv\":\"11.1\",\"ppi\":100,\"pxratio\":1.5,\"ua\":\"\(userAgentEscaped)\",\"w\":200}")
    }
    
    func testDeviceWithoutIfaToJsonString() {
        let oxmORTBPDevice = initORTBDevice(ifa: nil)
        oxmORTBPDevice.ua = userAgent
        let userAgentEscaped = userAgent.replacingOccurrences(of: "/", with: "\\/")
        codeAndDecode(abstract: oxmORTBPDevice, expectedString: "{\"carrier\":\"AT&T\",\"connectiontype\":6,\"devicetype\":1,\"didmd5\":\"didmd5\",\"didsha1\":\"didsha1\",\"dpidmd5\":\"dpidmd5\",\"dpidsha1\":\"dpidsha1\",\"geo\":{},\"geofetch\":1,\"h\":100,\"js\":1,\"language\":\"en\",\"lmt\":1,\"macmd5\":\"macmd5\",\"macsha1\":\"macsha1\",\"make\":\"Apple\",\"mccmnc\":\"310-680\",\"model\":\"iPhone\",\"os\":\"iOS\",\"osv\":\"11.1\",\"ppi\":100,\"pxratio\":1.5,\"ua\":\"\(userAgentEscaped)\",\"w\":200}")
    }
    
    func testDeviceWithExtAttsToJsonString() {
        let oxmORTBPDevice = initORTBDevice(ifa: nil)
        oxmORTBPDevice.ua = userAgent
        oxmORTBPDevice.extAtts.atts = 3
        oxmORTBPDevice.extAtts.ifv = "ifv"
        
        let userAgentEscaped = userAgent.replacingOccurrences(of: "/", with: "\\/")
        codeAndDecode(abstract: oxmORTBPDevice, expectedString: "{\"carrier\":\"AT&T\",\"connectiontype\":6,\"devicetype\":1,\"didmd5\":\"didmd5\",\"didsha1\":\"didsha1\",\"dpidmd5\":\"dpidmd5\",\"dpidsha1\":\"dpidsha1\",\"ext\":{\"atts\":3,\"ifv\":\"ifv\"},\"geo\":{},\"geofetch\":1,\"h\":100,\"js\":1,\"language\":\"en\",\"lmt\":1,\"macmd5\":\"macmd5\",\"macsha1\":\"macsha1\",\"make\":\"Apple\",\"mccmnc\":\"310-680\",\"model\":\"iPhone\",\"os\":\"iOS\",\"osv\":\"11.1\",\"ppi\":100,\"pxratio\":1.5,\"ua\":\"\(userAgentEscaped)\",\"w\":200}")
    }
    
    func testGeoToJsonString() {
        let oxmORTBGeo = OXMORTBGeo()
        
        oxmORTBGeo.lat = 34.1477849
        oxmORTBGeo.lon = -118.1445155
        oxmORTBGeo.type = 1
        oxmORTBGeo.accuracy = 200
        oxmORTBGeo.lastfix = 5
        oxmORTBGeo.country = "USA"
        oxmORTBGeo.region = "CA"
        oxmORTBGeo.regionfips104 = "US"
        oxmORTBGeo.metro = "foo"
        oxmORTBGeo.city = "Pasadena"
        oxmORTBGeo.zip = "91101"
        oxmORTBGeo.utcoffset = -480
        
        codeAndDecode(abstract: oxmORTBGeo, expectedString: "{\"accuracy\":200,\"city\":\"Pasadena\",\"country\":\"USA\",\"lastfix\":5,\"lat\":34.1477849,\"lon\":-118.1445155,\"metro\":\"foo\",\"region\":\"CA\",\"regionfips104\":\"US\",\"type\":1,\"utcoffset\":-480,\"zip\":\"91101\"}")
    }
    
    func testUserToJsonString() {
        let oxmORTBUser = OXMORTBUser()
        
        oxmORTBUser.yob = 1981
        oxmORTBUser.gender = "M"
        oxmORTBUser.keywords = "key1,key2,key3"
        oxmORTBUser.geo.lat = 34.1477849
        oxmORTBUser.geo.lon = -118.1445155
        oxmORTBUser.ext!["data"] = ["registration_date": "31.02.2021"]
        
        codeAndDecode(abstract:oxmORTBUser, expectedString:"{\"ext\":{\"data\":{\"registration_date\":\"31.02.2021\"}},\"gender\":\"M\",\"geo\":{\"lat\":34.1477849,\"lon\":-118.1445155},\"keywords\":\"key1,key2,key3\",\"yob\":1981}")
    }
    
    func testUserEidsToJsonString() {
        
        let user = OXMORTBUser()
        
        user.yob = 1981
        user.gender = "M"
        
        user.appendEids([["key": ["key":"value"]]])
     
        codeAndDecode(abstract:user, expectedString:"{\"ext\":{\"eids\":[{\"key\":{\"key\":\"value\"}}]},\"gender\":\"M\",\"yob\":1981}")
    }
    
    func testUserEidsInExtToJsonString() {
        
        let user = OXMORTBUser()
        
        user.yob = 1981
        user.gender = "M"
        
        user.ext = ["eids":[["key": ["key":"value"]]]]
             
        codeAndDecode(abstract:user, expectedString:"{\"ext\":{\"eids\":[{\"key\":{\"key\":\"value\"}}]},\"gender\":\"M\",\"yob\":1981}")
    }
    
    func testUserEidsAndExtToJsonString() {
        
        let user = OXMORTBUser()
        
        user.yob = 1981
        user.gender = "M"
        
        user.ext = ["eids":[["key": ["key":"value"]]]]
        
        user.appendEids([["key2": ["key2":"value2"]]])

        codeAndDecode(abstract:user, expectedString:"{\"ext\":{\"eids\":[{\"key\":{\"key\":\"value\"}},{\"key2\":{\"key2\":\"value2\"}}]},\"gender\":\"M\",\"yob\":1981}")
    }
    
    //MARK: - Utility
    
    func initORTBDevice(ifa: String?) -> OXMORTBDevice {
        let oxmORTBPDevice = OXMORTBDevice()
        oxmORTBPDevice.lmt = 1
        oxmORTBPDevice.devicetype = 1
        oxmORTBPDevice.make = "Apple"
        oxmORTBPDevice.model = "iPhone"
        oxmORTBPDevice.os = "iOS"
        oxmORTBPDevice.osv = "11.1"
        oxmORTBPDevice.hwv = "X"
        oxmORTBPDevice.h = 100
        oxmORTBPDevice.w = 200
        oxmORTBPDevice.ppi = 100
        oxmORTBPDevice.pxratio = 1.5
        oxmORTBPDevice.js = 1
        oxmORTBPDevice.geofetch = 1
        oxmORTBPDevice.language = "en"
        oxmORTBPDevice.carrier = "AT&T"
        oxmORTBPDevice.mccmnc = "310-680"
        oxmORTBPDevice.connectiontype = 6
        oxmORTBPDevice.ifa = ifa
        oxmORTBPDevice.didsha1 = "didsha1"
        oxmORTBPDevice.didmd5 = "didmd5"
        oxmORTBPDevice.dpidsha1 = "dpidsha1"
        oxmORTBPDevice.dpidmd5 = "dpidmd5"
        oxmORTBPDevice.macsha1 = "macsha1"
        oxmORTBPDevice.macmd5 = "macmd5"
        return oxmORTBPDevice
    }
    
    func codeAndDecode<T : OXMORTBAbstract>(abstract:T, expectedString:String, file: StaticString = #file, line: UInt = #line) {

        guard #available(iOS 11.0, *) else {
            OXMLog.warn("iOS 11 or higher is needed to support the .sortedKeys option for JSONEncoding which puts keys in the order that they appear in the class. Before that, string encoding results are unpredictable.")
            return
        }
        
        do {
            //Make a copy of the object
            let newCodable = abstract.copy() as! OXMORTBAbstract
            
            //Convert it to json
            let newJsonString = try newCodable.toJsonString()
            
            //Strings should match
            OXMAssertEq(newJsonString, expectedString, file:file, line:line)
        } catch {
            XCTFail("\(error)", file:file, line:line)
        }
    }
}
