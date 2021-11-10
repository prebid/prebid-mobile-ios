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

@testable import PrebidMobile

class MockModalManager: PBMModalManager {
    
    var mock_pushModalClosure: ((PBMModalState, UIViewController, Bool, Bool, PBMVoidBlock?) -> Void)?
    override func pushModal(_ state:PBMModalState, fromRootViewController:UIViewController, animated:Bool, shouldReplace:Bool, completionHandler:PBMVoidBlock?) -> PBMVoidBlock? {
        modalStateStack.add(state)
        
        mock_pushModalClosure?(state, fromRootViewController, animated, shouldReplace, completionHandler)
        return { [weak self, weak state] in
            if let self = self, let state = state {
                self.removeModal(state)
            }
        }
    }
    
    var mock_popModalClosure: (() -> Void)?
    override func popModal() {
        modalStateStack.removeLastObject()
        mock_popModalClosure?()
    }
    
    var mock_interstitialClosed: (() -> Void)?
    
    var mock_forceOrientation: ((UIInterfaceOrientation) -> Void)?
    override func forceOrientation(_ forcedOrientation:UIInterfaceOrientation) {
        mock_forceOrientation?(forcedOrientation)
    }
}
