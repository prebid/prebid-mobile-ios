//
// Copyright 2018-2025 Prebid.org, Inc.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    

import UIKit

class TouchForwardingView: UIView {
    
    var passThroughViews = [UIView]()
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var hit = super.hitTest(point, with: event)
        if hit === self {
            for passthroughView in passThroughViews {
                hit = passthroughView.hitTest(convert(point, to: passthroughView.coordinateSpace), with: event)
                if hit != nil {
                    break
                }
            }
        }
        return hit;
    }
    
}
