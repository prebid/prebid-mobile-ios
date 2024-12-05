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

public class RewardedEventHandlerStandalone: NSObject, RewardedEventHandlerProtocol {
    
    public weak var loadingDelegate: InterstitialEventLoadingDelegate?
    public weak var interactionDelegate: RewardedEventInteractionDelegate?
    
    public var isReady: Bool {
        false
    }
    
    public func show(from controller: UIViewController?) {
        assertionFailure("should never be called, as PBM SDK always wins")
    }
    
    public func requestAd(with bidResponse: BidResponse?) {
        loadingDelegate?.prebidDidWin()
    }
}
