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

class InterstitialDisplayPropertiesTests: XCTestCase {
        
    func testCopy() {
        let displayProps = InterstitialDisplayProperties()
        
        let displayProps2 = displayProps
        XCTAssertEqual(displayProps, displayProps2)
        
        let copiedProps = displayProps.copy() as! InterstitialDisplayProperties
        XCTAssertNotEqual(copiedProps, displayProps)
    }
    
    func testSetCloseButtonImage() {
        let displayProps = InterstitialDisplayProperties()
        //the default button
        var closeButtonImage = displayProps.getCloseButtonImage();
        XCTAssertNotNil(closeButtonImage)
        XCTAssertEqual(closeButtonImage?.size, CGSize(width: 114, height: 114))
        
        displayProps.setButtonImageHidden()
        closeButtonImage = displayProps.getCloseButtonImage();
        XCTAssertNotNil(closeButtonImage)
        XCTAssertEqual(closeButtonImage?.size, CGSize(width: 0, height: 0))
        
    }
}
