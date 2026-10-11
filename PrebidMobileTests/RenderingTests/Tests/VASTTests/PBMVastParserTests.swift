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

import XCTest

@_spi(PBMInternal) @testable import PrebidMobile

class PBMVastParserTests: XCTestCase {
    
    private var logToFile: LogToFileLock?
    
    override func setUp() {
        self.continueAfterFailure = true
        MockServer.shared.reset()
    }
    
    override func tearDown() {
        logToFile = nil
        MockServer.shared.reset()
        super.tearDown()
    }
    // MARK: - Tests
    
    func testVastParserDidEndElementAd() {

        //Create an ad
        let ad = VastAbstractAd()
        ad.creatives = [VastCreativeAbstract()]
        
        //Set up an VastParser
        let pbmVastParser = VastParser()
        pbmVastParser.parsedResponse = VastResponse()
        pbmVastParser.ad = ad
        pbmVastParser.adAttributes = ["id":"12345"]
        
        //Force the end of an "Ad" element
        pbmVastParser.parser(XMLParser(), didEndElement: "Ad", namespaceURI: nil, qualifiedName:nil)
        
        //The parser's VastResponse should contain the ad we created with an appropriate sequence number.
        XCTAssert(pbmVastParser.parsedResponse!.vastAbstractAds.count == 1)
        XCTAssert(pbmVastParser.parsedResponse!.vastAbstractAds.firstObject as! VastAbstractAd === ad)
        XCTAssert(ad.sequence == 0)
        
        //The parser should tidy up after the Ad tag is done parsing.
        XCTAssert(pbmVastParser.ad == nil)
        XCTAssert(pbmVastParser.inlineAd == nil)
        XCTAssert(pbmVastParser.wrapperAd == nil)
        XCTAssert(pbmVastParser.adAttributes == nil)
    }

    //Confirm we can parse a VAST 3.0 response
    func testVastParserFromFile() {

        guard let xmlData = UtilitiesForTesting.loadFileAsDataFromBundle("vast.3.0.xml") else {
            XCTFail("Could not load video")
            return
        }
        let pbmVastParser = VastParser()
        
        XCTAssertNotNil(pbmVastParser.parseAdsResponse(xmlData))
    }
    
    // MARK: - Test Parse Resource
    
    func testParseResourceCreativeCompanionStaticType() {
        
        // Prepare
        let parser = VastParser()
        let creative = VastCreativeCompanionAds()
        
        creative.companions = [VastCreativeCompanionAdsCompanion()]
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
        let parser = VastParser()
        let creative = VastCreativeCompanionAds()
        
        creative.companions = [VastCreativeCompanionAdsCompanion()]
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
        let parser = VastParser()
        let creative = VastCreativeLinear()
        
        creative.icons = [VastIcon()]
        
        parser.creative = creative
        
        // Run
        parser.parseResource(for: .staticResource)
        
        // Test
        let container = parser.extractCreativeContainer()!
        XCTAssertEqual(container.resourceType, .staticResource)
    }
    
    func testParseResourceCreativeNonLinearAds() {
        
        // Prepare
        let parser = VastParser()
        let creative = VastCreativeNonLinearAds()
        
        creative.nonLinears = [VastCreativeNonLinearAdsNonLinear()]
        
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
            parser.creative = VastCreativeAbstract()
            parser.parseResource(for: .staticResource)
        }, expectedLog: logErrorNAContainer)

        // Linear
        self.checkErrorLog( { parser in
            parser.creative = VastCreativeLinear()
            parser.parseResource(for: .staticResource)
        }, expectedLog: logErrorNAContainer)
        
        // missmatch between creative and container
        // VastCreativeCompanionAds
        self.checkErrorLog( { parser in
            let creative = VastCreativeCompanionAds()
            
            creative.companions = [VastCreativeNonLinearAds()]
            
            parser.creative = creative
            
            // Test
            parser.parseResource(for: .staticResource)

            XCTAssertNil(parser.extractCreativeContainer())
        }, expectedLog: logErrorNAContainer)
        
        // missmatch between creative and container
        // VastCreativeLinear
        self.checkErrorLog( { parser in
            let creative = VastCreativeLinear()
            
            creative.icons = [VastCreativeNonLinearAds()]
            
            parser.creative = creative
            
            // Test
            parser.parseResource(for: .staticResource)
            
            XCTAssertNil(parser.extractCreativeContainer())
        }, expectedLog: logErrorNAContainer)
        
        // missmatch between creative and container
        // VastCreativeNonLinearAds
        self.checkErrorLog( { parser in
            let creative = VastCreativeNonLinearAds()
            
            creative.nonLinears = [VastCreativeCompanionAdsCompanion()]
            
            parser.creative = creative
            
            // Test
            parser.parseResource(for: .staticResource)
            
            XCTAssertNil(parser.extractCreativeContainer())
        }, expectedLog: logErrorNAContainer)
    }
    
    // MARK: - Test Parse TimeInterval
    
    func testParseTimeInterval() {
        
        // Valid interval
        XCTAssertEqual(VastParser().parseTimeInterval("00:00:00"), 0)
        XCTAssertEqual(VastParser().parseTimeInterval("00:00:30"), 30)
        XCTAssertEqual(VastParser().parseTimeInterval("00:00:60"), 60)
        XCTAssertEqual(VastParser().parseTimeInterval("00:00:61"), 61)
        XCTAssertEqual(VastParser().parseTimeInterval("00:00:99"), 99)
        XCTAssertEqual(VastParser().parseTimeInterval("00:01:00"), 60)
        XCTAssertEqual(VastParser().parseTimeInterval("00:01:60"), 120)
        XCTAssertEqual(VastParser().parseTimeInterval("00:01:61"), 121)
        XCTAssertEqual(VastParser().parseTimeInterval("00:60:00"), 3600)
        XCTAssertEqual(VastParser().parseTimeInterval("00:99:00"), 5940)
        XCTAssertEqual(VastParser().parseTimeInterval("01:00:00"), 3600)
        XCTAssertEqual(VastParser().parseTimeInterval("01:01:00"), 3660)
        XCTAssertEqual(VastParser().parseTimeInterval("01:01:01"), 3661)
        XCTAssertEqual(VastParser().parseTimeInterval("99:99:99"), 362439)
        
        // Strange but also correct
        XCTAssertEqual(VastParser().parseTimeInterval("00:30"), 30)
        XCTAssertEqual(VastParser().parseTimeInterval(":30"), 30)
        XCTAssertEqual(VastParser().parseTimeInterval("30"), 30)
        XCTAssertEqual(VastParser().parseTimeInterval(""), 0)
        XCTAssertEqual(VastParser().parseTimeInterval("0"), 0)

        // Invalid interval
        self.checkErrorLog({parser in
            XCTAssertEqual(parser.parseTimeInterval("00:00:00:30"), 0)
        }, expectedLog: "Unable to parse time string")
    }
    
    // MARK: - Helper Methods
    
    func checkErrorLog(_ parse: (VastParser) -> Void, expectedLog: String, file: StaticString = #file, line: UInt = #line) {
        
        logToFile = .init()
        
        parse(VastParser())
        
        let log = Log.getLogFileAsString() ?? ""
        
        XCTAssertTrue(log.contains(expectedLog), "Log: \"\(log)\" not contains: \"\(expectedLog)\"", file: file, line: line)
    }
}
