//
//  PBMInterstitialDisplayPropertiesTests.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2017 OpenX. All rights reserved.
//

import XCTest
@testable import PrebidMobileRendering

class PBMInterstitialDisplayPropertiesTests: XCTestCase {
        
    func testCopy() {
        let displayProps = PBMInterstitialDisplayProperties()
        
        let displayProps2 = displayProps
        XCTAssertEqual(displayProps, displayProps2)
        
        let copiedProps = displayProps.copy() as! PBMInterstitialDisplayProperties
        XCTAssertNotEqual(copiedProps, displayProps)
    }
    
    func testSetCloseButtonImage() {
        let displayProps = PBMInterstitialDisplayProperties()
        //the default button
        var closeButtonImage = displayProps.getCloseButtonImage();
        XCTAssertNotNil(closeButtonImage)
        XCTAssertEqual(closeButtonImage?.size, CGSize(width: 38, height: 38))
        
        displayProps.setButtonImageHidden()
        closeButtonImage = displayProps.getCloseButtonImage();
        XCTAssertNotNil(closeButtonImage)
        XCTAssertEqual(closeButtonImage?.size, CGSize(width: 0, height: 0))
        
    }
}
