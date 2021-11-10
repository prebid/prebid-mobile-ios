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

class PBMCreativeViewabilityTrackerTest: XCTestCase {
    
    var expectationOnExposureChange: XCTestExpectation!
    
    override func tearDown() {
        self.expectationOnExposureChange = nil
    }
    
    func testCheckExposure() {
        
        let parentWindow = UIWindow()
        let parentView = UIView()
        let view = UIView()
        
        parentWindow.isHidden = false
        
        parentWindow.frame  = CGRect(x: 0.0, y: 0.0, width: 100, height: 100)
        parentView.frame = CGRect(x: 0.0, y: 0.0, width: 100, height: 100)
        view.frame = CGRect(x: 0.0, y: 0.0, width: 100, height: 100)
        
        parentView.addSubview(view)
        parentWindow.addSubview(parentView)
        
        self.expectationOnExposureChange = self.expectation(description: "Expected onExposureChange to be called")
        
        let viewabilityTracker = PBMCreativeViewabilityTracker(view: view, pollingTimeInterval: 10, onExposureChange:{ _, _ in
            self.expectationOnExposureChange.fulfill()
        });
        
        viewabilityTracker.checkExposure(withForce: false)
        self.waitForExpectations(timeout: 1)
        
        // exposure didn't change and isForce is false - onExposureChange should not be called
        self.expectationOnExposureChange = self.expectation(description: "Expected onExposureChange to be called")
        self.expectationOnExposureChange.isInverted = true
        viewabilityTracker.checkExposure(withForce: false)
        self.waitForExpectations(timeout: 1)
        
        // exposure didn't change BUT isForce is true - onExposureChange should be called
        self.expectationOnExposureChange = self.expectation(description: "Expected onExposureChange to be called")
        viewabilityTracker.checkExposure(withForce: true)
        self.waitForExpectations(timeout: 1)
        
    }
}
