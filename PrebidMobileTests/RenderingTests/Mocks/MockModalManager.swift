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

@testable @_spi(PBMInternal) import PrebidMobile

class MockModalManager: ModalManager {
    
    var mock_pushModalClosure: ((ModalState, UIViewController, Bool, Bool, VoidBlock?) -> Void)?
    override func pushModal(_ state:ModalState, fromRootViewController:UIViewController, animated:Bool, shouldReplace:Bool, completionHandler:VoidBlock?) -> VoidBlock? {
        modalStateStack.append(state)
        
        mock_pushModalClosure?(state, fromRootViewController, animated, shouldReplace, completionHandler)
        return { [weak self, weak state] in
            if let self = self, let state = state {
                self.removeModal(state)
            }
        }
    }
    
    var mock_popModalClosure: (() -> Void)?
    override func popModal() {
        modalStateStack.removeLast()
        mock_popModalClosure?()
    }
    
    var mock_interstitialClosed: (() -> Void)?
    
    var mock_forceOrientation: ((UIInterfaceOrientation) -> Void)?
    override func forceOrientation(_ forcedOrientation:UIInterfaceOrientation) {
        mock_forceOrientation?(forcedOrientation)
    }
}
