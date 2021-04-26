//
//  PBMMRAIDControllerTest.swift
//  OpenXSDKCoreTests
//
//  Copyright © 2019 OpenX. All rights reserved.
//

import Foundation
import XCTest

@testable import PrebidMobileRendering

// MARK - TestCase

class PBMMRAIDControllerTest : PBMMRAIDControllerTest_Base {
    
    func testStringIsMRAIDLink() {
        XCTAssertFalse(PBMMRAIDController.isMRAIDLink("ThisIsNotAnMRAIDLink"))
        XCTAssertFalse(PBMMRAIDController.isMRAIDLink("MRAID:ThisIsNOTAnMRAIDLink"))
        XCTAssertFalse(PBMMRAIDController.isMRAIDLink("mRaid:ThisIsNOTAnMRAIDLink"))
        XCTAssertFalse(PBMMRAIDController.isMRAIDLink("mraid :ThisIsNOTAnMRAIDLink"))
        XCTAssertFalse(PBMMRAIDController.isMRAIDLink("mraidThisIsNOTAnMRAIDLink"))
        
        XCTAssertTrue(PBMMRAIDController.isMRAIDLink("mraid:ThisIsAnMRAIDLink"))
    }
    
    func testCommandFromURL() {
        
        let urlToCmdMap = [
            "mraid:open/": PBMMRAIDAction.open,
            "mraid:expand/": PBMMRAIDAction.expand,
            "mraid:resize/": PBMMRAIDAction.resize,
            "mraid:close/": PBMMRAIDAction.close,
            "mraid:storepicture/": PBMMRAIDAction.storePicture,
            "mraid:createCalendarevent/": PBMMRAIDAction.createCalendarEvent,
            "mraid:playVideo/": PBMMRAIDAction.playVideo,
        ]
        
        let MRAIDController = PBMMRAIDController(creative:self.mockHtmlCreative,
                                                 viewControllerForPresenting:UIViewController(),
                                                 webView:self.mockWebView,
                                                 creativeViewDelegate:self,
                                                 downloadBlock:createLoader(connection: self.serverConnection))
        
        for (url, cmd) in urlToCmdMap {
            guard let expandURL = URL.init(string: url) else {
                return
            }
            
            let expandCmd = MRAIDController.command(from: expandURL)
            XCTAssertEqual(expandCmd.command, cmd)
        }
    }
}

// TODO: How to fix this test
// Previous behavior was to return `nil` for invalid `CGRect`s. Should we revert to that or accept
// current strategy of catching the error internally?
class PBMMRAIDControllerCGRectForResizePropertiesTest: XCTestCase {
     func testCGRectForResizeProperties() {
     
     let testView = UIView(frame: CGRect(x: 25, y: 25, width: 320, height: 50))
     
     
     let propertiesTooSmallX = MRAIDResizeProperties(width: 49, height: 50, offsetX: 0, offsetY: 0, allowOffscreen: false)
     let propertiesTooSmallY = MRAIDResizeProperties(width: 50, height: 49, offsetX: 0, offsetY: 0, allowOffscreen: false)
     let propertiesGood = MRAIDResizeProperties(width: 320, height: 250, offsetX: 0, offsetY: 0, allowOffscreen: false)
     let propertiesTooBig = MRAIDResizeProperties(width: 700, height: 1500, offsetX: 0, offsetY: 0, allowOffscreen: false)
     
        XCTAssertEqual(PBMMRAIDController.cgRect(for: propertiesGood, from:testView), CGRect.infinite, "Expected a resize to 0,0 to fail")
        XCTAssertEqual(PBMMRAIDController.cgRect(for: propertiesTooSmallX, from:testView), CGRect.infinite, "Expected a resize to 49,50 to fail")
        XCTAssertEqual(PBMMRAIDController.cgRect(for: propertiesTooSmallY, from:testView), CGRect.infinite, "Expected a resize to 50,49 to fail")
        XCTAssertEqual(PBMMRAIDController.cgRect(for: propertiesTooBig, from:testView), CGRect.infinite, "Expected a resize to 700,1500 to fail")
     
     }
 }

