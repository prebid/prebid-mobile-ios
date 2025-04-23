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
    

import Foundation
import UIKit

@_spi(PBMInternal) public typealias
DeferredModalStateResolutionHandler = (_ success: Bool) -> Void

@_spi(PBMInternal) public typealias
DeferredModalStatePreparationBlock = (_ completionBlock: @escaping DeferredModalStateResolutionHandler) -> Void

@_spi(PBMInternal) public typealias
DeferredModalStatePushStartHandler = (_ stateRemovalBlock: @escaping VoidBlock) -> Void

@objc(PBMDeferredModalState) @_spi(PBMInternal) public
protocol DeferredModalState {
    
    var modalState: ModalState { get }
    
    init(modalState: ModalState,
         fromRootViewController: UIViewController,
         animated: Bool,
         shouldReplace: Bool,
         preparationBlock: @escaping DeferredModalStatePreparationBlock,
         onWillBePushed: VoidBlock?,
         onPushStarted: DeferredModalStatePushStartHandler?,
         onPushCompleted: VoidBlock?,
         onPushCancelled: VoidBlock?)
    
    func prepareAndPush(modalManager: PBMModalManager, discardBlock: @escaping VoidBlock)
}
