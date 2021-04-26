//
//  OpenXSDKCoreTests
//
//  Copyright © 2018 OpenX. All rights reserved.
//
import XCTest

@testable import PrebidMobileRendering

class PBMAdRequestResponseVASTTests: XCTestCase {
    
    func testAds() {
        
        let response = PBMAdRequestResponseVAST()
        XCTAssertNotNil(response)
        XCTAssertNil(response.ads)
        
        response.ads = [PBMVastAbstractAd]()
        XCTAssertNotNil(response.ads)
        XCTAssertTrue(response.ads!.isEmpty)
        
        response.ads?.append(PBMVastInlineAd())
        XCTAssertFalse(response.ads!.isEmpty)
        
        XCTAssert(response.ads!.first?.superclass === PBMVastAbstractAd.self)
    }
}
