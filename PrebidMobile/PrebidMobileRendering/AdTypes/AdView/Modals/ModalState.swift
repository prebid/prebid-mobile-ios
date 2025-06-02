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

@_spi(PBMInternal) public typealias ModalStatePopHandler = (_ poppedState: ModalState?) -> Void
@_spi(PBMInternal) public typealias ModalStateAppLeavingHandler = (_ leavingState: ModalState?) -> Void

@objc(PBMModalState) @_spi(PBMInternal) public
protocol ModalState {
    
    var adConfiguration: AdConfiguration? { get }
    var displayProperties: InterstitialDisplayProperties? { get }
    var view: UIView? { get }
    
    var mraidState: PBMMRAIDState { get set }
    
    var onStatePopFinished: ModalStatePopHandler? { get }
    var onStateHasLeftApp: ModalStateAppLeavingHandler? { get }
    
    var nextOnStatePopFinished: ModalStatePopHandler? { get }
    var nextOnStateHasLeftApp: ModalStateAppLeavingHandler? { get }
    
    var onModalPushedBlock: VoidBlock? { get set }
    
    var isRotationEnabled: Bool { get }
    
    init(view: UIView,
         adConfiguration: AdConfiguration?,
         displayProperties: InterstitialDisplayProperties?,
         onStatePopFinished: ModalStatePopHandler?,
         onStateHasLeftApp: ModalStateAppLeavingHandler?,
         nextOnStatePopFinished: ModalStatePopHandler?,
         nextOnStateHasLeftApp: ModalStateAppLeavingHandler?,
         onModalPushedBlock: VoidBlock?)
}
