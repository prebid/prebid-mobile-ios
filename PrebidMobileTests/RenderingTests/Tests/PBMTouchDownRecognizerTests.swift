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

import Foundation
import XCTest
@testable import PrebidMobile

class PBMTouchDownRecognizerTests : XCTestCase {
    
    func testBasic() {
        //Note: GestureRecognizers are notoriously difficult to test.
        //They are tightly coupled to the views they are attached to
        //and intercept touch events from them. Unless they are "real" events they don't call their completion selector on their
        //target and don't reset back to .Possible (their default state) on the next run of the run loop.
        //For security purposes, these touch events can't be instantiated without hitting a private API that changes rapidly
        //between release of iOS. For more information, see:
        //http://blog.lazerwalker.com/objective-c/code/2013/10/16/faking-touch-events-on-ios-for-fun-and-profit.html
        
        // Should start as Possible
        let recognizer = TestablePBMTouchDownRecognizer()
        PBMAssertEq(recognizer.state, .possible)
        
        // Trigger touch down logic
        recognizer.handleTouch()
        
        // Should transition to Ended
        PBMAssertEq(recognizer.state.rawValue, UIGestureRecognizer.State.ended.rawValue)
    }
    
    func testDoesNotTransitionIfNotPossible() {
        let recognizer = TestablePBMTouchDownRecognizer()
        recognizer.mockState = .failed
        
        recognizer.handleTouch()
        
        // State should remain unchanged since it wasn't .possible
        PBMAssertEq(recognizer.state, .failed)
    }
    
    func testTransitionsOnlyOnce() {
        let recognizer = TestablePBMTouchDownRecognizer()
        
        recognizer.handleTouch()
        PBMAssertEq(recognizer.state, .ended)
        
        // Calling again should not change state (already .ended, not .possible)
        recognizer.handleTouch()
        PBMAssertEq(recognizer.state, .ended)
    }
    
    // MARK: - Test Helpers

    private class TestablePBMTouchDownRecognizer: PBMTouchDownRecognizer {
        var mockState: UIGestureRecognizer.State = .possible
        
        override var state: UIGestureRecognizer.State {
            get { mockState }
            set { mockState = newValue }
        }
    }
}
