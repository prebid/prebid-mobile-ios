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

@testable import PrebidMobile

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
        let ad = PBMVastAbstractAd()
        ad.creatives = [PBMVastCreativeAbstract()]
        
        //Set up an PBMVastParser
        let pbmVastParser = PBMVastParser()
        pbmVastParser.parsedResponse = PBMVastResponse()
        pbmVastParser.ad = ad
        pbmVastParser.adAttributes = ["id":"12345"]
        
        //Force the end of an "Ad" element
        pbmVastParser.parser(XMLParser(), didEndElement: "Ad", namespaceURI: nil, qualifiedName:nil)
        
        //The parser's PBMVastResponse should contain the ad we created with an appropriate sequence number.
        XCTAssert(pbmVastParser.parsedResponse!.vastAbstractAds.count == 1)
        XCTAssert(pbmVastParser.parsedResponse!.vastAbstractAds.firstObject as! PBMVastAbstractAd === ad)
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
        let pbmVastParser = PBMVastParser()
        
        XCTAssertNotNil(pbmVastParser.parseAdsResponse(xmlData))
    }
    
    // MARK: - Test Parse Resource
    
    func testParseResourceCreativeCompanionStaticType() {
        
        // Prepare
        let parser = PBMVastParser()
        let creative = PBMVastCreativeCompanionAds()
        
        creative.companions = [PBMVastCreativeCompanionAdsCompanion()]
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
        let parser = PBMVastParser()
        let creative = PBMVastCreativeCompanionAds()
        
        creative.companions = [PBMVastCreativeCompanionAdsCompanion()]
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
        let parser = PBMVastParser()
        let creative = PBMVastCreativeLinear()
        
        creative.icons = [PBMVastIcon()]
        
        parser.creative = creative
        
        // Run
        parser.parseResource(for: .staticResource)
        
        // Test
        let container = parser.extractCreativeContainer()!
        XCTAssertEqual(container.resourceType, .staticResource)
    }
    
    func testParseResourceCreativeNonLinearAds() {
        
        // Prepare
        let parser = PBMVastParser()
        let creative = PBMVastCreativeNonLinearAds()
        
        creative.nonLinears = [PBMVastCreativeNonLinearAdsNonLinear()]
        
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
            parser.creative = PBMVastCreativeAbstract()
            parser.parseResource(for: .staticResource)
        }, expectedLog: logErrorNAContainer)

        // Linear
        self.checkErrorLog( { parser in
            parser.creative = PBMVastCreativeLinear()
            parser.parseResource(for: .staticResource)
        }, expectedLog: logErrorNAContainer)
        
        // missmatch between creative and container
        // PBMVastCreativeCompanionAds
        self.checkErrorLog( { parser in
            let creative = PBMVastCreativeCompanionAds()
            
            creative.companions = [PBMVastCreativeNonLinearAds()]
            
            parser.creative = creative
            
            // Test
            parser.parseResource(for: .staticResource)

            XCTAssertNil(parser.extractCreativeContainer())
        }, expectedLog: logErrorNAContainer)
        
        // missmatch between creative and container
        // PBMVastCreativeLinear
        self.checkErrorLog( { parser in
            let creative = PBMVastCreativeLinear()
            
            creative.icons = [PBMVastCreativeNonLinearAds()]
            
            parser.creative = creative
            
            // Test
            parser.parseResource(for: .staticResource)
            
            XCTAssertNil(parser.extractCreativeContainer())
        }, expectedLog: logErrorNAContainer)
        
        // missmatch between creative and container
        // PBMVastCreativeNonLinearAds
        self.checkErrorLog( { parser in
            let creative = PBMVastCreativeNonLinearAds()
            
            creative.nonLinears = [PBMVastCreativeCompanionAdsCompanion()]
            
            parser.creative = creative
            
            // Test
            parser.parseResource(for: .staticResource)
            
            XCTAssertNil(parser.extractCreativeContainer())
        }, expectedLog: logErrorNAContainer)
    }
    
    // MARK: - Test Parse TimeInterval
    
    func testParseTimeInterval() {
        
        // Valid interval
        XCTAssertEqual(PBMVastParser().parseTimeInterval("00:00:00"), 0)
        XCTAssertEqual(PBMVastParser().parseTimeInterval("00:00:30"), 30)
        XCTAssertEqual(PBMVastParser().parseTimeInterval("00:00:60"), 60)
        XCTAssertEqual(PBMVastParser().parseTimeInterval("00:00:61"), 61)
        XCTAssertEqual(PBMVastParser().parseTimeInterval("00:00:99"), 99)
        XCTAssertEqual(PBMVastParser().parseTimeInterval("00:01:00"), 60)
        XCTAssertEqual(PBMVastParser().parseTimeInterval("00:01:60"), 120)
        XCTAssertEqual(PBMVastParser().parseTimeInterval("00:01:61"), 121)
        XCTAssertEqual(PBMVastParser().parseTimeInterval("00:60:00"), 3600)
        XCTAssertEqual(PBMVastParser().parseTimeInterval("00:99:00"), 5940)
        XCTAssertEqual(PBMVastParser().parseTimeInterval("01:00:00"), 3600)
        XCTAssertEqual(PBMVastParser().parseTimeInterval("01:01:00"), 3660)
        XCTAssertEqual(PBMVastParser().parseTimeInterval("01:01:01"), 3661)
        XCTAssertEqual(PBMVastParser().parseTimeInterval("99:99:99"), 362439)
        
        // Strange but also correct
        XCTAssertEqual(PBMVastParser().parseTimeInterval("00:30"), 30)
        XCTAssertEqual(PBMVastParser().parseTimeInterval(":30"), 30)
        XCTAssertEqual(PBMVastParser().parseTimeInterval("30"), 30)
        XCTAssertEqual(PBMVastParser().parseTimeInterval(""), 0)
        XCTAssertEqual(PBMVastParser().parseTimeInterval("0"), 0)

        // Invalid interval
        self.checkErrorLog({parser in
            XCTAssertEqual(parser.parseTimeInterval("00:00:00:30"), 0)
        }, expectedLog: "Unable to parse time string")
    }
    
    // MARK: - Helper Methods
    
    func checkErrorLog(_ parse: (PBMVastParser) -> Void, expectedLog: String, file: StaticString = #file, line: UInt = #line) {
        
        logToFile = .init()
        
        parse(PBMVastParser())
        
        let log = Log.getLogFileAsString() ?? ""
        
        XCTAssertTrue(log.contains(expectedLog), "Log: \"\(log)\" not contains: \"\(expectedLog)\"", file: file, line: line)
    }
}
