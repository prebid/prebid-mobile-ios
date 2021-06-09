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
@testable import PrebidMobileRendering

class PBMLegalButtonDecoratorTests: XCTestCase {
    
    let buttonDecorator = PBMLegalButtonDecorator(position: .topRight)

    func testClickthroughBrowserView() {
        XCTAssertNotNil(buttonDecorator)
        let clickthroughBrowserView = buttonDecorator.clickthroughBrowserView()
        XCTAssertNotNil(clickthroughBrowserView)
        
        XCTAssertEqual(clickthroughBrowserView?.webView?.url?.absoluteString,
                       PBMPrivacyPolicyUrlString)
    }
    
    func testButtonTappedAction() {
        XCTAssertNotNil(buttonDecorator)
        
        let expectation = self.expectation(description: "buttonTappedAction")
        buttonDecorator.buttonTouchUpInsideBlock = {
            expectation.fulfill()
        }
        
        // Setup superview
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        buttonDecorator.addButton(to: view, display: view)
        buttonDecorator.updateButtonConstraints()
        buttonDecorator.bringButtonToFront()
        
        var imgSize = buttonDecorator.button.currentImage?.size
        XCTAssertEqual(imgSize?.width, 20.0, "Button image should be collapsed")
        XCTAssertEqual(imgSize?.height, 20.0, "Wrong button image height: \(String(describing: imgSize?.height))")
        
        // First tap make button Expanded
        buttonDecorator.buttonTappedAction()

        imgSize = buttonDecorator.button.currentImage?.size
        XCTAssertEqual(imgSize?.width, 88.0, "Button image should be expanded")
        XCTAssertEqual(imgSize?.height, 20.0, "Wrong button image height: \(String(describing: imgSize?.height))")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute:{
            // Second tap make button Minimized and execute block
            self.buttonDecorator.buttonTappedAction()
        })
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testGetButtonConstraintConstant() {
        XCTAssertNotNil(buttonDecorator)
        XCTAssertEqual(buttonDecorator.getButtonConstraintConstant(), 0)
    }

    func testSetButtonPosition() {
        XCTAssertEqual(buttonDecorator.buttonPosition.rawValue, PBMPosition.topRight.rawValue,
                  "Wrong position, got \(String(describing: buttonDecorator.buttonPosition.rawValue))")
        
        buttonDecorator.buttonPosition = PBMPosition.bottomRight
        XCTAssertEqual(buttonDecorator.buttonPosition.rawValue, PBMPosition.bottomRight.rawValue,
                  "Wrong position, got \(String(describing: buttonDecorator.buttonPosition.rawValue))")
    }
}
