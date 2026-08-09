/*   Copyright 2018-2021 Prebid.org, Inc.
 
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
import XCTest

@_spi(PBMInternal) @testable import PrebidMobile

class ORTBAbstractTest : XCTestCase {
    
    private var sdkVersion: String {
        let infoDic = Bundle(for: BannerView.self).infoDictionary
        return infoDic!["CFBundleShortVersionString"] as! String
    }
    
    private var omidVersion: String {
        return Functions.sdkVersion;
    }
    
    private let userAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 OpenXSDK/\(Prebid.shared.version)"
    
    private var logToFile: LogToFileLock?
    
    override func tearDown() {
        logToFile = nil
        super.tearDown()
    }
    
    //Check default values of all ORTB request objects
    func testDefaultToJsonString() {
        
        codeAndDecode(abstract:ORTBBidRequest(), expectedString: "{\"imp\":[{\"clickbrowser\":1,\"ext\":{\"dlp\":1},\"instl\":0,\"secure\":0}]}")
        
        //Source not implemented
        codeAndDecode(abstract:ORTBRegs(), expectedString: "{}")
        codeAndDecode(abstract:ORTBImp(), expectedString: "{\"clickbrowser\":1,\"ext\":{\"dlp\":1},\"instl\":0,\"secure\":0}")
        
        //Metric not implemented
        codeAndDecode(abstract:ORTBBanner(), expectedString: "{}")
        codeAndDecode(abstract:ORTBVideo(), expectedString: "{}")
        
        //Audio not implemented
        //Native not implemented
        codeAndDecode(abstract:ORTBFormat(), expectedString: "{}")
        codeAndDecode(abstract:ORTBPmp(), expectedString: "{}")
        codeAndDecode(abstract:ORTBDeal(), expectedString: "{\"bidfloor\":0,\"bidfloorcur\":\"USD\",\"wadomain\":[],\"wseat\":[]}")
        
        //Site not implemented
        codeAndDecode(abstract:ORTBApp(), expectedString: "{}")
        //Publisher not implemented
        //Content not implemented
        //Producer not implemented
        codeAndDecode(abstract:ORTBDevice(), expectedString: "{}")
        codeAndDecode(abstract:ORTBGeo(), expectedString: "{}")
        codeAndDecode(abstract:ORTBUser(), expectedString: "{}")
        //Data not implemented
        //Segment not implemented
        
        codeAndDecode(abstract:ORTBBidRequestExtPrebid(), expectedString: "{}")
        codeAndDecode(abstract:ORTBImpExtPrebid(), expectedString: "{}")
        
        codeAndDecode(abstract: ORTBImpExtSkadn(), expectedString: "{}")
    }

    // MARK: - Decode/encode parity (playbook Gap S2.5-C)

    /// Fully-populated fixtures: decode → encode must be idempotent.
    func testORTBParityOnFullFixtures() {
        assertORTBParity(jsonString: ORTBFixtures.format, swiftType: ORTBFormat.self)
        assertORTBParity(jsonString: ORTBFixtures.publisher, swiftType: ORTBPublisher.self)
        assertORTBParity(jsonString: ORTBFixtures.geo, swiftType: ORTBGeo.self)
        assertORTBParity(jsonString: ORTBFixtures.deal, swiftType: ORTBDeal.self)
        assertORTBParity(jsonString: ORTBFixtures.sourceExtOMID, swiftType: ORTBSourceExtOMID.self)
        assertORTBParity(jsonString: ORTBFixtures.impExtSkadn, swiftType: ORTBImpExtSkadn.self)
        assertORTBParity(jsonString: ORTBFixtures.deviceExtAtts, swiftType: ORTBDeviceExtAtts.self)
    }

    /// Partial payloads: an absent key must stay absent on re-encode. The ObjC
    /// `initWithJsonDictionary:` assigned ivars directly, clearing the defaults seeded by
    /// `init`; a Swift port that falls back to the default would invent wire keys.
    func testDecodingPartialJSONDoesNotResurrectDefaults() {
        assertORTBNoResurrectedDefaults(jsonString: ORTBFixtures.partialDeal,
                                        swiftType: ORTBDeal.self,
                                        expectedKeys: ["id"])

        // `ext` is expected: ORTBImp always writes `dlp` when extPrebid is empty.
        assertORTBNoResurrectedDefaults(jsonString: ORTBFixtures.partialImp,
                                        swiftType: ORTBImp.self,
                                        expectedKeys: ["id", "ext"])
    }

    /// A request decoded without `imp` (or with an empty one) must not re-encode the
    /// one-element default impression `ORTBBidRequest.init` seeds.
    func testDecodingRequestWithoutImpKeepsImpEmpty() {
        for fixture in [ORTBFixtures.partialBidRequest, ORTBFixtures.emptyImpBidRequest] {
            guard let request = try? ORTBBidRequest(jsonString: fixture) else {
                XCTFail("ORTBBidRequest init?(jsonString:) returned nil for \(fixture)")
                continue
            }
            XCTAssertTrue(request.imp.isEmpty, "phantom impression decoded from \(fixture)")
            XCTAssertEqual((request.jsonDictionary["imp"] as? [Any])?.count, 0)
            XCTAssertEqual(Set(request.jsonDictionary.keys), ["id", "imp"])
        }
    }

    func testCopying() {
        let initial = ORTBBidRequest()
        
        initial.imp[0].banner = ORTBBanner()
        initial.imp[0].video = ORTBVideo()
        initial.imp[0].pmp.deals = [ORTBDeal()]
        
        initial.imp[0].banner?.format = [ORTBFormat()]
        initial.imp[0].banner?.format[0].w = 640
        initial.imp[0].banner?.format[0].h = 480
        initial.imp[0].banner?.format[0].wratio = 4
        initial.imp[0].banner?.format[0].hratio = 3
        initial.imp[0].banner?.format[0].wmin = 160
        
        initial.extPrebid.storedRequestID = "testAccID"
        initial.imp[0].extPrebid.storedRequestID = "testCfgID"
        
        XCTAssertFalse(initial.imp[0].extPrebid.isRewardedInventory)
        initial.imp[0].extPrebid.isRewardedInventory = true
        
        let copy = initial.copy() as! ORTBBidRequest
        
        XCTAssertNotEqual(initial, copy)
        
        XCTAssertNotEqual(initial.imp, copy.imp)
        XCTAssertEqual(initial.imp.count, 1)
        XCTAssertEqual(initial.imp.count, copy.imp.count)
        for i in (0 ..< initial.imp.count) {
            
            let impInitial = initial.imp[i]
            let impCopy = copy.imp[i]
            
            XCTAssertNotEqual(impInitial, impCopy)
            
            XCTAssertNotEqual(impInitial.banner, impCopy.banner)
            
            XCTAssertFalse(impInitial.banner!.format as AnyObject === impCopy.banner!.format as AnyObject)
            XCTAssertFalse(impInitial.banner!.format[0] === impCopy.banner!.format[0])
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
        let pbmORTBBidRequest = ORTBBidRequest()
        let uuid = UUID().uuidString
        pbmORTBBidRequest.requestID = uuid
        
        codeAndDecode(abstract: pbmORTBBidRequest, expectedString: "{\"id\":\"\(uuid)\",\"imp\":[{\"clickbrowser\":1,\"ext\":{\"dlp\":1},\"instl\":0,\"secure\":0}]}")
        
        pbmORTBBidRequest.tmax = 2000
        
        codeAndDecode(abstract: pbmORTBBidRequest, expectedString: "{\"id\":\"\(uuid)\",\"imp\":[{\"clickbrowser\":1,\"ext\":{\"dlp\":1},\"instl\":0,\"secure\":0}],\"tmax\":2000}")
        
        pbmORTBBidRequest.test = 2
        
        codeAndDecode(abstract: pbmORTBBidRequest, expectedString: "{\"id\":\"\(uuid)\",\"imp\":[{\"clickbrowser\":1,\"ext\":{\"dlp\":1},\"instl\":0,\"secure\":0}],\"test\":2,\"tmax\":2000}")
    }
    
    func testBidRequestExtPrebidToJsonString() {
        let extPrebid = ORTBBidRequestExtPrebid()
        extPrebid.storedRequestID = "b4eb1475-4e3d-4186-97b7-25b6a6cf8618"
        extPrebid.dataBidders = ["openx", "prebid", "thanatos"]
        extPrebid.storedAuctionResponse = "stored-auction-response-test"
        extPrebid.sdkRenderers = [["name": "MockRenderer1", "version": "0.0.1"], ["name": "MockRenderer2", "version": "0.0.2"]]
        
        codeAndDecode(abstract: extPrebid, expectedString: "{\"data\":{\"bidders\":[\"openx\",\"prebid\",\"thanatos\"]},\"sdk\":{\"renderers\":[{\"name\":\"MockRenderer1\",\"version\":\"0.0.1\"},{\"name\":\"MockRenderer2\",\"version\":\"0.0.2\"}]},\"storedauctionresponse\":{\"id\":\"stored-auction-response-test\"},\"storedrequest\":{\"id\":\"b4eb1475-4e3d-4186-97b7-25b6a6cf8618\"},\"targeting\":{}}")
        
        let pbmORTBBidRequest = ORTBBidRequest()
        pbmORTBBidRequest.extPrebid = extPrebid
        
        codeAndDecode(abstract: pbmORTBBidRequest, expectedString: "{\"ext\":{\"prebid\":{\"data\":{\"bidders\":[\"openx\",\"prebid\",\"thanatos\"]},\"sdk\":{\"renderers\":[{\"name\":\"MockRenderer1\",\"version\":\"0.0.1\"},{\"name\":\"MockRenderer2\",\"version\":\"0.0.2\"}]},\"storedauctionresponse\":{\"id\":\"stored-auction-response-test\"},\"storedrequest\":{\"id\":\"b4eb1475-4e3d-4186-97b7-25b6a6cf8618\"},\"targeting\":{}}},\"imp\":[{\"clickbrowser\":1,\"ext\":{\"dlp\":1},\"instl\":0,\"secure\":0}]}")
    }
    
    func testSourceToJsonString() {
        let pbmORTBSource = ORTBSource()
        
        let tid = UUID().uuidString
        let pchain = "some_pchain_string"
        
        pbmORTBSource.fd = 0
        pbmORTBSource.tid = tid
        pbmORTBSource.pchain = pchain
        
        codeAndDecode(abstract: pbmORTBSource, expectedString: "{\"fd\":0,\"pchain\":\"\(pchain)\",\"tid\":\"\(tid)\"}")
    }
    
    func testRegsToJsonString() {
        let pbmORTBRegs = ORTBRegs()
        pbmORTBRegs.coppa = 1
        XCTAssertEqual(pbmORTBRegs.coppa, 1)
        codeAndDecode(abstract:pbmORTBRegs, expectedString:"{\"coppa\":1}")
        
        pbmORTBRegs.coppa = 0
        XCTAssertEqual(pbmORTBRegs.coppa, 0)
        codeAndDecode(abstract:pbmORTBRegs, expectedString:"{\"coppa\":0}")
        
        pbmORTBRegs.coppa = -1
        XCTAssertEqual(pbmORTBRegs.coppa, nil)
        codeAndDecode(abstract:pbmORTBRegs, expectedString:"{}")
        
        pbmORTBRegs.coppa = 1.5
        XCTAssertEqual(pbmORTBRegs.coppa, nil)
        codeAndDecode(abstract:pbmORTBRegs, expectedString:"{}")
    }

    func testRegsGppToJsonString() {
        let regs = ORTBRegs()
        regs.gpp = "DBACNYA~CPXxRfAPXxRfAAfKABENB-CgAAAAAAAAAAYgAAAAAAAA~1YNN"
        regs.gppSID = [2, 6]
        codeAndDecode(abstract: regs, expectedString: "{\"gpp\":\"DBACNYA~CPXxRfAPXxRfAAfKABENB-CgAAAAAAAAAAYgAAAAAAAA~1YNN\",\"gpp_sid\":[2,6]}")

        let decoded = try! ORTBRegs.from(jsonString: try! regs.toJsonString())
        XCTAssertEqual(decoded.gpp, regs.gpp)
        XCTAssertEqual(decoded.gppSID, regs.gppSID)
    }

    // MARK: PBMORTBImp
    
    func testImpToJsonString() {
        let pbmORTBImp = ORTBImp()
        
        let uuid = UUID().uuidString
        pbmORTBImp.impID = uuid
        pbmORTBImp.banner = ORTBBanner()
        pbmORTBImp.video = ORTBVideo()
        pbmORTBImp.native = ORTBNative()
        pbmORTBImp.pmp = ORTBPmp()
        pbmORTBImp.displaymanager = "MOCK_SDK_NAME"
        pbmORTBImp.displaymanagerver = "MOCK_SDK_VERSION"
        pbmORTBImp.instl = 1
        pbmORTBImp.rewarded = 1
        pbmORTBImp.tagid = "tagid"
        pbmORTBImp.secure = 1
        pbmORTBImp.extData = ["lookup_words": ["dragon", "flame"]]
        
        codeAndDecode(abstract: pbmORTBImp, expectedString: "{\"clickbrowser\":1,\"displaymanager\":\"MOCK_SDK_NAME\",\"displaymanagerver\":\"MOCK_SDK_VERSION\",\"ext\":{\"data\":{\"lookup_words\":[\"dragon\",\"flame\"]},\"dlp\":1},\"id\":\"\(uuid)\",\"instl\":1,\"native\":{\"ver\":\"1.2\"},\"rwdd\":1,\"secure\":1,\"tagid\":\"tagid\"}")
    }
    
    func testPBMORTBImpExtSkadnToJsonString() { 
        let skadn = ORTBImpExtSkadn()
        skadn.sourceapp = "12345678"
        skadn.skadnetids = ["1", "2", "3"]
        
        var expectedString = "{\"skadnetids\":[\"1\",\"2\",\"3\"],\"sourceapp\":\"12345678\",\"versions\":\(Functions.supportedSKAdNetworkVersions)}"
        expectedString.removeAll(where: { $0 == " "})
        
        codeAndDecode(abstract: skadn, expectedString: expectedString)
    }
    
    func testNativeToJsonString() {
        let pbmORTBNative = ORTBNative()
        
        XCTAssertEqual(pbmORTBNative.ver, "1.2")
        XCTAssertNil(pbmORTBNative.request as NSString?)
        XCTAssertNil(pbmORTBNative.api)
        XCTAssertNil(pbmORTBNative.battr)
        
        codeAndDecode(abstract: pbmORTBNative, expectedString: "{\"ver\":\"1.2\"}")
        
        pbmORTBNative.request = "some request string goes here"
        pbmORTBNative.api = [42]
        pbmORTBNative.battr = [1, 3, 13]
        
        codeAndDecode(abstract: pbmORTBNative, expectedString: "{\"api\":[42],\"battr\":[1,3,13],\"request\":\"some request string goes here\",\"ver\":\"1.2\"}")
    }
    
    func testImpExtPrebidToJsonString() {
        let extPrebid = ORTBImpExtPrebid()
        extPrebid.storedRequestID = "b4eb1475-4e3d-4186-97b7-25b6a6cf8618"
        XCTAssertFalse(extPrebid.isRewardedInventory)
        
        codeAndDecode(abstract: extPrebid, expectedString: "{\"storedrequest\":{\"id\":\"b4eb1475-4e3d-4186-97b7-25b6a6cf8618\"}}")
        
        let pbmORTBImp = ORTBImp()
        pbmORTBImp.extPrebid = extPrebid
        
        codeAndDecode(abstract: pbmORTBImp, expectedString: "{\"clickbrowser\":1,\"ext\":{\"prebid\":{\"storedrequest\":{\"id\":\"b4eb1475-4e3d-4186-97b7-25b6a6cf8618\"}}},\"instl\":0,\"secure\":0}")
    }
    
    func testImpExtPrebidToJsonStringRewarded() {
        let extPrebid = ORTBImpExtPrebid()
        extPrebid.storedRequestID = "b4eb1475-4e3d-4186-97b7-25b6a6cf8618"
        extPrebid.isRewardedInventory = true
        
        codeAndDecode(abstract: extPrebid, expectedString: "{\"is_rewarded_inventory\":1,\"storedrequest\":{\"id\":\"b4eb1475-4e3d-4186-97b7-25b6a6cf8618\"}}")
        
        let pbmORTBImp = ORTBImp()
        pbmORTBImp.extPrebid = extPrebid
        
        codeAndDecode(abstract: pbmORTBImp, expectedString: "{\"clickbrowser\":1,\"ext\":{\"prebid\":{\"is_rewarded_inventory\":1,\"storedrequest\":{\"id\":\"b4eb1475-4e3d-4186-97b7-25b6a6cf8618\"}}},\"instl\":0,\"secure\":0}")
    }
    
    func testImpExtGPID() {
        let gpid = "/12345/home_screen#identifier"
        
        let imp = ORTBImp()
        imp.extGPID = gpid
        
        codeAndDecode(abstract: imp, expectedString: "{\"clickbrowser\":1,\"ext\":{\"dlp\":1,\"gpid\":\"\\/12345\\/home_screen#identifier\"},\"instl\":0,\"secure\":0}")
    }
    
    func testBannerToJsonString() {
        let pbmORTBBanner = ORTBBanner()
        pbmORTBBanner.pos = 1                   //Above the fold
        pbmORTBBanner.api = [2,5]
        
        codeAndDecode(abstract: pbmORTBBanner, expectedString: "{\"api\":[2,5],\"pos\":1}")
        
        pbmORTBBanner.format = [ORTBFormat()]
        pbmORTBBanner.format[0].w = 728
        pbmORTBBanner.format[0].h = 90
        
        codeAndDecode(abstract: pbmORTBBanner, expectedString: "{\"api\":[2,5],\"format\":[{\"h\":90,\"w\":728}],\"pos\":1}")
    }
    
    func testVideoToJsonString() {
        let pbmORTBVideo = ORTBVideo()
        
        pbmORTBVideo.minduration = 10
        pbmORTBVideo.maxduration = 100
        pbmORTBVideo.w = 100
        pbmORTBVideo.h = 200
        pbmORTBVideo.startdelay = 5
        pbmORTBVideo.linearity = 1
        pbmORTBVideo.minbitrate = 20
        pbmORTBVideo.maxbitrate = 40
        pbmORTBVideo.mimes = PrebidConstants.SUPPORTED_VIDEO_MIME_TYPES
        pbmORTBVideo.protocols = [2, 5]
        pbmORTBVideo.pos = 7
        pbmORTBVideo.delivery = [3]
        pbmORTBVideo.playbackend = 2
        
        codeAndDecode(abstract: pbmORTBVideo, expectedString: "{\"delivery\":[3],\"h\":200,\"linearity\":1,\"maxbitrate\":40,\"maxduration\":100,\"mimes\":[\"video\\/mp4\",\"video\\/quicktime\",\"video\\/x-m4v\",\"video\\/3gpp\",\"video\\/3gpp2\"],\"minbitrate\":20,\"minduration\":10,\"playbackend\":2,\"pos\":7,\"protocols\":[2,5],\"startdelay\":5,\"w\":100}")
    }
    
    func testFormatToJsonString() {
        let pbmORTBFormat = ORTBFormat()
        pbmORTBFormat.w = 320
        pbmORTBFormat.h = 50
        codeAndDecode(abstract: pbmORTBFormat, expectedString: "{\"h\":50,\"w\":320}")
        
        pbmORTBFormat.w = nil
        pbmORTBFormat.h = nil
        pbmORTBFormat.wratio = 16
        pbmORTBFormat.hratio = 9
        pbmORTBFormat.wmin = 60
        codeAndDecode(abstract: pbmORTBFormat, expectedString: "{\"hratio\":9,\"wmin\":60,\"wratio\":16}")
    }
    
    func testPmpToJsonString() {
        let pbmORTBPmp = ORTBPmp()
        pbmORTBPmp.private_auction = 1
        pbmORTBPmp.deals.append(ORTBDeal())
        pbmORTBPmp.deals.first?.bidfloor = 1.0
        
        codeAndDecode(abstract: pbmORTBPmp, expectedString: "{\"deals\":[{\"bidfloor\":1,\"bidfloorcur\":\"USD\",\"wadomain\":[],\"wseat\":[]}],\"private_auction\":1}")
    }
    
    func testDealToJsonString() {
        let pbmORTBDeal = ORTBDeal()
        
        pbmORTBDeal.id = "id"
        pbmORTBDeal.bidfloor = 100.0
        pbmORTBDeal.bidfloorcur = "GBP"
        pbmORTBDeal.at = 1
        pbmORTBDeal.wseat = ["seat1", "seat2", "seat3"]
        pbmORTBDeal.wadomain = ["advertiser1.com", "advertiser2.com", "advertiser3.com"]
        
        codeAndDecode(abstract: pbmORTBDeal, expectedString: "{\"at\":1,\"bidfloor\":100,\"bidfloorcur\":\"GBP\",\"id\":\"id\",\"wadomain\":[\"advertiser1.com\",\"advertiser2.com\",\"advertiser3.com\"],\"wseat\":[\"seat1\",\"seat2\",\"seat3\"]}")
    }
    
    func testAppToJsonString() {
        
        let pbmORTBApp = ORTBApp()
        
        pbmORTBApp.id = "foo"
        pbmORTBApp.name = "PubApp"
        pbmORTBApp.bundle = "com.PubApp"
        pbmORTBApp.domain = "pubapp.com"
        pbmORTBApp.storeurl = "itunes.com?pubapp"
        pbmORTBApp.ver = "1.2"
        pbmORTBApp.privacypolicy = 1
        pbmORTBApp.paid = 1
        pbmORTBApp.keywords = "foo,bar,baz"
        pbmORTBApp.content = ORTBAppContent()
        pbmORTBApp.content.url = "https://corresponding.section.publishers.website"
        
        codeAndDecode(abstract: pbmORTBApp, expectedString: "{\"bundle\":\"com.PubApp\",\"content\":{\"url\":\"https:\\/\\/corresponding.section.publishers.website\"},\"domain\":\"pubapp.com\",\"id\":\"foo\",\"keywords\":\"foo,bar,baz\",\"name\":\"PubApp\",\"paid\":1,\"privacypolicy\":1,\"storeurl\":\"itunes.com?pubapp\",\"ver\":\"1.2\"}")
    }
    
    func testAppContentToJsonString() {
        let appContent = ORTBAppContent()
        appContent.episode = 2
        appContent.title = "title"
        appContent.series = "series"
        appContent.season = "season"
        appContent.artist = "artist"
        appContent.genre = "genre"
        appContent.album = "album"
        appContent.isrc = "isrc"
        
        let producer = ORTBContentProducer()
        producer.name = "producerName"
        producer.cat = ["producerCat"]
        producer.domain = "domain"
        
        appContent.producer = producer
        appContent.cat = ["cat"]
        appContent.prodq = 1
        appContent.context = 1
        appContent.contentrating = "contentrating"
        appContent.userrating = "userrating"
        appContent.qagmediarating = 1
        appContent.keywords = "keywords"
        appContent.livestream = 0
        appContent.sourcerelationship = 0
        appContent.len = 1
        appContent.language = "language"
        appContent.embeddable = 0
        
        let data = ORTBContentData()
        data.name = "dataName"
        
        let segment = ORTBContentSegment()
        segment.name = "segmentName"
        segment.value = "segmentValue"
        data.segment = [segment]
        
        appContent.data = [data]
        appContent.url = "https://www.url.com"
        
        codeAndDecode(abstract: appContent, expectedString: "{\"album\":\"album\",\"artist\":\"artist\",\"cat\":[\"cat\"],\"contentrating\":\"contentrating\",\"context\":1,\"data\":[{\"name\":\"dataName\",\"segment\":[{\"name\":\"segmentName\",\"value\":\"segmentValue\"}]}],\"embeddable\":0,\"episode\":2,\"genre\":\"genre\",\"isrc\":\"isrc\",\"keywords\":\"keywords\",\"language\":\"language\",\"len\":1,\"livestream\":0,\"prodq\":1,\"producer\":{\"cat\":[\"producerCat\"],\"domain\":\"domain\",\"name\":\"producerName\"},\"qagmediarating\":1,\"season\":\"season\",\"series\":\"series\",\"sourcerelationship\":0,\"title\":\"title\",\"url\":\"https:\\/\\/www.url.com\",\"userrating\":\"userrating\"}")
    }
    
    func testAppExtPrebidToJsonString() {
        let pbmORTBApp = ORTBApp()
        let appExtPrebid = pbmORTBApp.ext.prebid
        
        codeAndDecode(abstract: appExtPrebid, expectedString: "{}")
        
        appExtPrebid.source = "openx"
        appExtPrebid.version = sdkVersion
        pbmORTBApp.ext.data = ["app_categories": ["news", "movies"]]
        
        codeAndDecode(abstract: appExtPrebid, expectedString: "{\"source\":\"openx\",\"version\":\"\(sdkVersion)\"}")
        
        codeAndDecode(abstract: pbmORTBApp, expectedString: "{\"ext\":{\"data\":{\"app_categories\":[\"news\",\"movies\"]},\"prebid\":{\"source\":\"openx\",\"version\":\"\(sdkVersion)\"}}}")
    }
    
    func testDeviceWithIfaToJsonString() {
        let pbmORTBPDevice = initORTBDevice(ifa: "ifa")
        pbmORTBPDevice.ua = userAgent
        let userAgentEscaped = userAgent.replacingOccurrences(of: "/", with: "\\/")
        codeAndDecode(abstract: pbmORTBPDevice, expectedString: "{\"carrier\":\"AT&T\",\"connectiontype\":6,\"devicetype\":1,\"didmd5\":\"didmd5\",\"didsha1\":\"didsha1\",\"geofetch\":1,\"h\":100,\"hwv\":\"X\",\"ifa\":\"ifa\",\"js\":1,\"language\":\"en\",\"lmt\":1,\"make\":\"Apple\",\"mccmnc\":\"310-680\",\"model\":\"iPhone\",\"os\":\"iOS\",\"osv\":\"11.1\",\"ppi\":100,\"pxratio\":1.5,\"ua\":\"\(userAgentEscaped)\",\"w\":200}")
    }
    
    func testDeviceWithoutIfaToJsonString() {
        let pbmORTBPDevice = initORTBDevice(ifa: nil)
        pbmORTBPDevice.ua = userAgent
        let userAgentEscaped = userAgent.replacingOccurrences(of: "/", with: "\\/")
        codeAndDecode(abstract: pbmORTBPDevice, expectedString: "{\"carrier\":\"AT&T\",\"connectiontype\":6,\"devicetype\":1,\"didmd5\":\"didmd5\",\"didsha1\":\"didsha1\",\"dpidmd5\":\"dpidmd5\",\"dpidsha1\":\"dpidsha1\",\"geofetch\":1,\"h\":100,\"hwv\":\"X\",\"js\":1,\"language\":\"en\",\"lmt\":1,\"macmd5\":\"macmd5\",\"macsha1\":\"macsha1\",\"make\":\"Apple\",\"mccmnc\":\"310-680\",\"model\":\"iPhone\",\"os\":\"iOS\",\"osv\":\"11.1\",\"ppi\":100,\"pxratio\":1.5,\"ua\":\"\(userAgentEscaped)\",\"w\":200}")
    }
    
    func testDeviceWithExtAttsToJsonString() {
        let pbmORTBPDevice = initORTBDevice(ifa: nil)
        pbmORTBPDevice.ua = userAgent
        pbmORTBPDevice.extAtts.atts = 3
        pbmORTBPDevice.extAtts.ifv = "ifv"
        
        let userAgentEscaped = userAgent.replacingOccurrences(of: "/", with: "\\/")
        codeAndDecode(abstract: pbmORTBPDevice, expectedString: "{\"carrier\":\"AT&T\",\"connectiontype\":6,\"devicetype\":1,\"didmd5\":\"didmd5\",\"didsha1\":\"didsha1\",\"dpidmd5\":\"dpidmd5\",\"dpidsha1\":\"dpidsha1\",\"ext\":{\"atts\":3,\"ifv\":\"ifv\"},\"geofetch\":1,\"h\":100,\"hwv\":\"X\",\"js\":1,\"language\":\"en\",\"lmt\":1,\"macmd5\":\"macmd5\",\"macsha1\":\"macsha1\",\"make\":\"Apple\",\"mccmnc\":\"310-680\",\"model\":\"iPhone\",\"os\":\"iOS\",\"osv\":\"11.1\",\"ppi\":100,\"pxratio\":1.5,\"ua\":\"\(userAgentEscaped)\",\"w\":200}")
    }
    
    func testGeoToJsonString() {
        let pbmORTBGeo = ORTBGeo()
        
        pbmORTBGeo.lat = 34.1477849
        pbmORTBGeo.lon = -118.1445155
        pbmORTBGeo.type = 1
        pbmORTBGeo.accuracy = 200
        pbmORTBGeo.lastfix = 5
        pbmORTBGeo.country = "USA"
        pbmORTBGeo.region = "CA"
        pbmORTBGeo.regionfips104 = "US"
        pbmORTBGeo.metro = "foo"
        pbmORTBGeo.city = "Pasadena"
        pbmORTBGeo.zip = "91101"
        pbmORTBGeo.utcoffset = -480
        
        codeAndDecode(abstract: pbmORTBGeo, expectedString: "{\"accuracy\":200,\"city\":\"Pasadena\",\"country\":\"USA\",\"lastfix\":5,\"lat\":34.1477849,\"lon\":-118.1445155,\"metro\":\"foo\",\"region\":\"CA\",\"regionfips104\":\"US\",\"type\":1,\"utcoffset\":-480,\"zip\":\"91101\"}")
    }
    
    func testUserToJsonString() {
        let pbmORTBUser = ORTBUser()
        
        pbmORTBUser.keywords = "key1,key2,key3"
        pbmORTBUser.geo.lat = 34.1477849
        pbmORTBUser.geo.lon = -118.1445155
        pbmORTBUser.ext!["data"] = ["registration_date": "31.02.2021"]
        pbmORTBUser.userid = "userid"
        
        codeAndDecode(
            abstract: pbmORTBUser,
            expectedString: "{\"ext\":{\"data\":{\"registration_date\":\"31.02.2021\"}},\"geo\":{\"lat\":34.1477849,\"lon\":-118.1445155},\"id\":\"userid\",\"keywords\":\"key1,key2,key3\"}"
        )
    }
    
    func testUserEidsToJsonString() {
        let user = ORTBUser()
        
        user.appendEids([["key": ["key":"value"]]])
        
        codeAndDecode(
            abstract: user,
            expectedString: "{\"ext\":{\"eids\":[{\"key\":{\"key\":\"value\"}}]}}"
        )
    }
    
    func testUserEidsInExtToJsonString() {
        let user = ORTBUser()
        
        user.ext = ["eids":[["key": ["key":"value"]]]]
        
        codeAndDecode(
            abstract: user,
            expectedString: "{\"ext\":{\"eids\":[{\"key\":{\"key\":\"value\"}}]}}"
        )
    }
    
    func testUserEidsAndExtToJsonString() {
        let user = ORTBUser()
        
        user.ext = ["eids":[["key": ["key":"value"]]]]
        user.appendEids([["key2": ["key2":"value2"]]])
        
        codeAndDecode(
            abstract: user,
            expectedString: "{\"ext\":{\"eids\":[{\"key\":{\"key\":\"value\"}},{\"key2\":{\"key2\":\"value2\"}}]}}"
        )
    }
    
    // MARK: - Utility
    
    func initORTBDevice(ifa: String?) -> ORTBDevice {
        let pbmORTBPDevice = ORTBDevice()
        pbmORTBPDevice.lmt = 1
        pbmORTBPDevice.devicetype = 1
        pbmORTBPDevice.make = "Apple"
        pbmORTBPDevice.model = "iPhone"
        pbmORTBPDevice.os = "iOS"
        pbmORTBPDevice.osv = "11.1"
        pbmORTBPDevice.hwv = "X"
        pbmORTBPDevice.h = 100
        pbmORTBPDevice.w = 200
        pbmORTBPDevice.ppi = 100
        pbmORTBPDevice.pxratio = 1.5
        pbmORTBPDevice.js = 1
        pbmORTBPDevice.geofetch = 1
        pbmORTBPDevice.language = "en"
        pbmORTBPDevice.carrier = "AT&T"
        pbmORTBPDevice.mccmnc = "310-680"
        pbmORTBPDevice.connectiontype = 6
        pbmORTBPDevice.ifa = ifa
        pbmORTBPDevice.didsha1 = "didsha1"
        pbmORTBPDevice.didmd5 = "didmd5"
        pbmORTBPDevice.dpidsha1 = "dpidsha1"
        pbmORTBPDevice.dpidmd5 = "dpidmd5"
        pbmORTBPDevice.macsha1 = "macsha1"
        pbmORTBPDevice.macmd5 = "macmd5"
        return pbmORTBPDevice
    }
    
    func codeAndDecode<T : PBMJsonCodable>(abstract:T, expectedString:String, file: StaticString = #file, line: UInt = #line) {
        
        guard #available(iOS 11.0, *) else {
            Log.warn("iOS 11 or higher is needed to support the .sortedKeys option for JSONEncoding which puts keys in the order that they appear in the class. Before that, string encoding results are unpredictable.")
            return
        }
        
        do {
            //Convert it to json
            let newJsonString = try abstract.toJsonString()
            
            //Strings should match
            PBMAssertEq(newJsonString, expectedString, file:file, line:line)
        } catch {
            XCTFail("\(error)", file:file, line:line)
        }
    }
}
