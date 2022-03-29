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

class PBMCloseButtonDecoratorTest: XCTestCase {
    
    var buttonDecorator: PBMCloseButtonDecorator!
    
    override func setUp() {
        super.setUp()
        buttonDecorator = PBMCloseButtonDecorator()
    }
    
    override func tearDown() {
        buttonDecorator = nil
        super.tearDown()
    }
    
    func testGetButtonSize() {
        //There is no image by default
        let constant = 0.25
        XCTAssertNil(buttonDecorator.button.currentImage)
        buttonDecorator.closeButtonArea = NSNumber(value: constant)
        let sizeValue: CGFloat = (UIScreen.main.bounds.width - 40) * constant
        let buttonSize = CGSize(width: sizeValue, height: sizeValue)
        let resultButtonSize = buttonDecorator.getButtonSize()
        
        XCTAssertEqual(resultButtonSize, buttonSize)
        
        let image = UIImage(named: "PBM_closeButton",
                            in: Bundle(for: type(of: self)), compatibleWith: nil)
        buttonDecorator.setImage(image!)
        XCTAssertEqual(buttonDecorator.button.currentImage, image)
    }
}
