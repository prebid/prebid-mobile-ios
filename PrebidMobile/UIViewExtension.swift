/*   Copyright 2019-2020 Prebid.org, Inc.

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

import UIKit

extension UIView {
    
    func pb_isAtLeastHalfViewable() -> Bool{
        if isHidden {
            return false
        }
        if (window == nil) {
            return false
        }
        var isInHiddenSuperview = false
        var currentView = self
        while let ancestorView = currentView.superview {
            if ancestorView.isHidden {
                isInHiddenSuperview = true
                break
            }
            currentView = ancestorView
        }
        
        if isInHiddenSuperview {
            return false
        }
        
        let screenRect = UIScreen.main.bounds
        let normalizedSelfRect = convert(self.bounds, to: nil)
        let intersection = screenRect.intersection(normalizedSelfRect)
        if intersection.equalTo(.null) {
            return false
        }
        
        let intersectionArea = intersection.width * intersection.height
        let selfArea = normalizedSelfRect.width * normalizedSelfRect.height
        return intersectionArea >= 0.5 * selfArea
        
    }
    
}
