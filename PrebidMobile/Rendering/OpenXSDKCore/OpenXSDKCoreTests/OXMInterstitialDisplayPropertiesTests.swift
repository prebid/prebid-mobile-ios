//
//  OXMInterstitialDisplayPropertiesTests.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2017 OpenX. All rights reserved.
//

import XCTest
@testable import OpenXApolloSDK

class OXMInterstitialDisplayPropertiesTests: XCTestCase {
        
    func testCopy() {
        let displayProps = OXMInterstitialDisplayProperties()
        
        let displayProps2 = displayProps
        XCTAssertEqual(displayProps, displayProps2)
        
        let copiedProps = displayProps.copy() as! OXMInterstitialDisplayProperties
        XCTAssertNotEqual(copiedProps, displayProps)
    }
    
    func testSetCloseButtonImage() {
        let displayProps = OXMInterstitialDisplayProperties()
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
