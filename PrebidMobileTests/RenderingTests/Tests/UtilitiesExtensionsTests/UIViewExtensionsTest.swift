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

class UIViewExtensionsTest: XCTestCase {
    
    func testPBMIsVisible() {
        
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 560, height: 420))
        let root = UIView(frame: CGRect(x: 10, y: 10, width: 240, height: 400))
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 80))
        
        XCTAssertFalse(view.pbmIsVisible())
        
        window.addSubview(root)
        root.addSubview(view)
        
        XCTAssertTrue(view.pbmIsVisible())
        
        view.isHidden = true
        XCTAssertFalse(view.pbmIsVisible())
        
        view.isHidden = false
        view.alpha = 0
        XCTAssertFalse(view.pbmIsVisible())
        
        view.alpha = 0.5
        view.frame = CGRect(origin: CGPoint(x: view.frame.origin.x - view.frame.size.width, y: view.frame.origin.y), size: view.frame.size);
        XCTAssertFalse(view.pbmIsVisible())
        
        view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: view.frame.size);
        XCTAssertTrue(view.pbmIsVisible())
    }
    
    func testIsVisibleInView() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 560, height: 420))
        
        //a view below the tested one - should not impact
        let root0 = UIView(frame: CGRect(x: 10, y: 10, width: 240, height: 400))
        window.addSubview(root0)
        
        //the tested view
        let root = UIView(frame: CGRect(x: 10, y: 10, width: 240, height: 400))
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 80))
        root.addSubview(view)
        window.addSubview(root)
        XCTAssertTrue(view.pbmIsVisible(inViewLegacy: view.superview))
        
        //a visible view above the tested one
        let root2 = UIView(frame: CGRect(x: 10, y: 10, width: 240, height: 400))
        window.addSubview(root2)
        XCTAssertFalse(view.pbmIsVisible(inViewLegacy: view.superview))
        
        //the invisble above view
        root2.isHidden = true
        XCTAssertTrue(view.pbmIsVisible(inViewLegacy: view.superview))
        
        //the invisible above view but with a visible suvbiew
        root2.addSubview(UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200)))
        XCTAssertFalse(view.pbmIsVisible(inViewLegacy: view.superview))
    }
    
}
