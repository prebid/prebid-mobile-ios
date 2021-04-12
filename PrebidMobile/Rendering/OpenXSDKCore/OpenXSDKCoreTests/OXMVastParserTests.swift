import XCTest

@testable import OpenXApolloSDK

class OXMVastParserTests: XCTestCase {
    
    private var logToFile: LogToFileLock?
    
    override func setUp() {
        self.continueAfterFailure = true
        MockServer.singleton().reset()
    }
    
    override func tearDown() {
        logToFile = nil
        MockServer.singleton().reset()
        super.tearDown()
    }
    // MARK: - Tests
    
    func testVastParserDidEndElementAd() {

        //Create an ad
        let ad = OXMVastAbstractAd()
        ad.creatives = [OXMVastCreativeAbstract()]
        
        //Set up an OXMVastParser
        let oxmVastParser = OXMVastParser()
        oxmVastParser.parsedResponse = OXMVastResponse()
        oxmVastParser.ad = ad
        oxmVastParser.adAttributes = ["id":"12345"]
        
        //Force the end of an "Ad" element
        oxmVastParser.parser(XMLParser(), didEndElement: "Ad", namespaceURI: nil, qualifiedName:nil)
        
        //The parser's OXMVastResponse should contain the ad we created with an appropriate sequence number.
        XCTAssert(oxmVastParser.parsedResponse!.vastAbstractAds.count == 1)
        XCTAssert(oxmVastParser.parsedResponse!.vastAbstractAds.firstObject as! OXMVastAbstractAd === ad)
        XCTAssert(ad.sequence == 0)
        
        //The parser should tidy up after the Ad tag is done parsing.
        XCTAssert(oxmVastParser.ad == nil)
        XCTAssert(oxmVastParser.inlineAd == nil)
        XCTAssert(oxmVastParser.wrapperAd == nil)
        XCTAssert(oxmVastParser.adAttributes == nil)
    }

    //Confirm we can parse a VAST 3.0 response
    func testVastParserFromFile() {

        guard let xmlData = UtilitiesForTesting.loadFileAsDataFromBundle("vast.3.0.xml") else {
            XCTFail("Could not load video")
            return
        }
        let oxmVastParser = OXMVastParser()
        
        XCTAssertNotNil(oxmVastParser.parseAdsResponse(xmlData))
    }
    
    // MARK: - Test Parse Resource
    
    func testParseResourceCreativeCompanionStaticType() {
        
        // Prepare
        let parser = OXMVastParser()
        let creative = OXMVastCreativeCompanionAds()
        
        creative.companions = [OXMVastCreativeCompanionAdsCompanion()]
        parser.currentElementAttributes = ["creativeType" : "test"]
        
        parser.creative = creative
        
        // Run
        parser.parseResource(for: .staticResource)
        
        // Test
        let container = parser.extractCreativeContainer()!
        XCTAssertEqual(container.resourceType, .staticResource)
        XCTAssertEqual(container.staticType, "test")
    }
    
    func testParseResourceCreativeCompanionFrameType() {
        
        // Prepare
        let parser = OXMVastParser()
        let creative = OXMVastCreativeCompanionAds()
        
        creative.companions = [OXMVastCreativeCompanionAdsCompanion()]
        parser.currentElementAttributes = ["creativeType" : "test"]
        
        parser.creative = creative
        
        // Run
        parser.parseResource(for: .iFrameResource)
        
        // Test
        let container = parser.extractCreativeContainer()!
        XCTAssertEqual(container.resourceType, .iFrameResource)
        XCTAssertNil(container.staticType)
    }
    
    func testParseResourceCreativeLinear() {
        
        // Prepare
        let parser = OXMVastParser()
        let creative = OXMVastCreativeLinear()
        
        creative.icons = [OXMVastIcon()]
        
        parser.creative = creative
        
        // Run
        parser.parseResource(for: .staticResource)
        
        // Test
        let container = parser.extractCreativeContainer()!
        XCTAssertEqual(container.resourceType, .staticResource)
    }
    
    func testParseResourceCreativeNonLinearAds() {
        
        // Prepare
        let parser = OXMVastParser()
        let creative = OXMVastCreativeNonLinearAds()
        
        creative.nonLinears = [OXMVastCreativeNonLinearAdsNonLinear()]
        
        parser.creative = creative
        
        // Run
        parser.parseResource(for: .staticResource)
        
        // Test
        let container = parser.extractCreativeContainer()!
        XCTAssertEqual(container.resourceType, .staticResource)
    }
    
    func testParseResourceWithError() {
        
        let logErrorNAContainer = "No applicable container to apply"
        
        // nil creative
        self.checkErrorLog( { parser in
            parser.creative = nil
            parser.parseResource(for: .iFrameResource)
        }, expectedLog: "No applicable creative")

        // not particular creative
        self.checkErrorLog( { parser in
            parser.creative = OXMVastCreativeAbstract()
            parser.parseResource(for: .staticResource)
        }, expectedLog: logErrorNAContainer)

        // Linear
        self.checkErrorLog( { parser in
            parser.creative = OXMVastCreativeLinear()
            parser.parseResource(for: .staticResource)
        }, expectedLog: logErrorNAContainer)
        
        // missmatch between creative and container
        // OXMVastCreativeCompanionAds
        self.checkErrorLog( { parser in
            let creative = OXMVastCreativeCompanionAds()
            
            creative.companions = [OXMVastCreativeNonLinearAds()]
            
            parser.creative = creative
            
            // Test
            parser.parseResource(for: .staticResource)

            XCTAssertNil(parser.extractCreativeContainer())
        }, expectedLog: logErrorNAContainer)
        
        // missmatch between creative and container
        // OXMVastCreativeLinear
        self.checkErrorLog( { parser in
            let creative = OXMVastCreativeLinear()
            
            creative.icons = [OXMVastCreativeNonLinearAds()]
            
            parser.creative = creative
            
            // Test
            parser.parseResource(for: .staticResource)
            
            XCTAssertNil(parser.extractCreativeContainer())
        }, expectedLog: logErrorNAContainer)
        
        // missmatch between creative and container
        // OXMVastCreativeNonLinearAds
        self.checkErrorLog( { parser in
            let creative = OXMVastCreativeNonLinearAds()
            
            creative.nonLinears = [OXMVastCreativeCompanionAdsCompanion()]
            
            parser.creative = creative
            
            // Test
            parser.parseResource(for: .staticResource)
            
            XCTAssertNil(parser.extractCreativeContainer())
        }, expectedLog: logErrorNAContainer)
    }
    
    // MARK: - Test Parse TimeInterval
    
    func testParseTimeInterval() {
        
        // Valid interval
        XCTAssertEqual(OXMVastParser().parseTimeInterval("00:00:00"), 0)
        XCTAssertEqual(OXMVastParser().parseTimeInterval("00:00:30"), 30)
        XCTAssertEqual(OXMVastParser().parseTimeInterval("00:00:60"), 60)
        XCTAssertEqual(OXMVastParser().parseTimeInterval("00:00:61"), 61)
        XCTAssertEqual(OXMVastParser().parseTimeInterval("00:00:99"), 99)
        XCTAssertEqual(OXMVastParser().parseTimeInterval("00:01:00"), 60)
        XCTAssertEqual(OXMVastParser().parseTimeInterval("00:01:60"), 120)
        XCTAssertEqual(OXMVastParser().parseTimeInterval("00:01:61"), 121)
        XCTAssertEqual(OXMVastParser().parseTimeInterval("00:60:00"), 3600)
        XCTAssertEqual(OXMVastParser().parseTimeInterval("00:99:00"), 5940)
        XCTAssertEqual(OXMVastParser().parseTimeInterval("01:00:00"), 3600)
        XCTAssertEqual(OXMVastParser().parseTimeInterval("01:01:00"), 3660)
        XCTAssertEqual(OXMVastParser().parseTimeInterval("01:01:01"), 3661)
        XCTAssertEqual(OXMVastParser().parseTimeInterval("99:99:99"), 362439)
        
        // Strange but also correct
        XCTAssertEqual(OXMVastParser().parseTimeInterval("00:30"), 30)
        XCTAssertEqual(OXMVastParser().parseTimeInterval(":30"), 30)
        XCTAssertEqual(OXMVastParser().parseTimeInterval("30"), 30)
        XCTAssertEqual(OXMVastParser().parseTimeInterval(""), 0)
        XCTAssertEqual(OXMVastParser().parseTimeInterval("0"), 0)

        // Invalid interval
        self.checkErrorLog({parser in
            XCTAssertEqual(parser.parseTimeInterval("00:00:00:30"), 0)
        }, expectedLog: "Unable to parse time string")
    }
    
    // MARK: - Helper Methods
    
    func checkErrorLog(_ parse: (OXMVastParser) -> Void, expectedLog: String, file: StaticString = #file, line: UInt = #line) {
        
        logToFile = .init()
        
        parse(OXMVastParser())
        
        let log = OXMLog.singleton.getLogFileAsString()
        
        XCTAssertTrue(log.contains(expectedLog), "Log: \"\(log)\" not contains: \"\(expectedLog)\"", file: file, line: line)
    }
}
