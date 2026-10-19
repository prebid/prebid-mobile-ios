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

// MARK - TestCase

class PBMMRAIDControllerTest : PBMMRAIDControllerTest_Base {
    
    func testStringIsMRAIDLink() {
        XCTAssertFalse(MRAIDController.isMRAIDLink("ThisIsNotAnMRAIDLink"))
        XCTAssertFalse(MRAIDController.isMRAIDLink("MRAID:ThisIsNOTAnMRAIDLink"))
        XCTAssertFalse(MRAIDController.isMRAIDLink("mRaid:ThisIsNOTAnMRAIDLink"))
        XCTAssertFalse(MRAIDController.isMRAIDLink("mraid :ThisIsNOTAnMRAIDLink"))
        XCTAssertFalse(MRAIDController.isMRAIDLink("mraidThisIsNOTAnMRAIDLink"))
        
        XCTAssertTrue(MRAIDController.isMRAIDLink("mraid:ThisIsAnMRAIDLink"))
    }
    
    // Ported from PBMMRAIDControllerObjCTest.m: the ObjC controller raised an NSException, the Swift one throws.
    func testCommandWithBadParams() {
        let controller = MRAIDController(creative: nil,
                                         viewControllerForPresenting: nil,
                                         webView: nil,
                                         creativeViewDelegate: nil,
                                         downloadBlock: nil)
        XCTAssertThrowsError(try controller.command(from: nil))
    }

    func testCommandFromURL() {
        
        let urlToCmdMap = [
            "mraid:open/": PBMMRAIDAction.open,
            "mraid:expand/": PBMMRAIDAction.expand,
            "mraid:resize/": PBMMRAIDAction.resize,
            "mraid:close/": PBMMRAIDAction.close,
            "mraid:playVideo/": PBMMRAIDAction.playVideo,
        ]
        
        let controller = MRAIDController(creative:self.mockHtmlCreative,
                                         viewControllerForPresenting:UIViewController(),
                                         webView:self.mockWebView,
                                         creativeViewDelegate:self,
                                         downloadBlock:createLoader(connection: self.serverConnection))
        
        for (url, cmd) in urlToCmdMap {
            guard let expandURL = URL.init(string: url) else {
                return
            }
            
            let expandCmd = try? controller.command(from: expandURL)
            XCTAssertEqual(expandCmd?.command, cmd.rawValue)
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
        
        XCTAssertEqual(MRAIDController.cgRect(for: propertiesGood, from:testView), CGRect.infinite, "Expected a resize to 0,0 to fail")
        XCTAssertEqual(MRAIDController.cgRect(for: propertiesTooSmallX, from:testView), CGRect.infinite, "Expected a resize to 49,50 to fail")
        XCTAssertEqual(MRAIDController.cgRect(for: propertiesTooSmallY, from:testView), CGRect.infinite, "Expected a resize to 50,49 to fail")
        XCTAssertEqual(MRAIDController.cgRect(for: propertiesTooBig, from:testView), CGRect.infinite, "Expected a resize to 700,1500 to fail")
        
    }

    func testResizeTallerThanScreenFailsWhenOffscreenIsNotAllowed() {
        let screenSize = Functions.deviceScreenSize
        let parent = UIView(frame: CGRect(origin: .zero, size: screenSize))
        let testView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        parent.addSubview(testView)

        let screenHeight = Int(screenSize.height)
        let propertiesScreenHeight = MRAIDResizeProperties(width: 50, height: screenHeight, offsetX: 0, offsetY: 0, allowOffscreen: false)
        let propertiesTooTall = MRAIDResizeProperties(width: 50, height: screenHeight + 1, offsetX: 0, offsetY: 0, allowOffscreen: false)

        XCTAssertEqual(MRAIDController.cgRect(for: propertiesScreenHeight, from: testView),
                       CGRect(x: 0, y: 0, width: 50, height: screenHeight),
                       "Expected a resize to the screen height to fit")
        XCTAssertEqual(MRAIDController.cgRect(for: propertiesTooTall, from: testView), CGRect.infinite,
                       "Expected a resize taller than the screen to fail")
    }
}
