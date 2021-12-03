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
import UIKit
import XCTest

//Serves as a root view controller to present from.
class MockViewController : UIViewController {
    
    var expectationDidPresentViewController:XCTestExpectation?
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Swift.Void)? = nil) {
        if flag {
            //Wait 1 second to simulate the VC animating into place
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute:{
                completion?()
                self.expectationDidPresentViewController?.fulfill()
            })
        } else {
            completion?()
            self.expectationDidPresentViewController?.fulfill()
        }
    }
}

class MockPresentedViewController: MockViewController {
    var presentVC: UIViewController?
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        presentVC = viewControllerToPresent
    }
    
    override var presentedViewController: UIViewController? {
        return presentVC
    }
}
