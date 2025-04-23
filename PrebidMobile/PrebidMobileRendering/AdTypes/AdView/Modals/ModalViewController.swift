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

@_spi(PBMInternal) public typealias ModalViewController = (ModalViewController_Protocol & UIViewController)

@objc(PBMModalViewController_Protocol) @_spi(PBMInternal) public
protocol ModalViewController_Protocol {
    
    weak var modalViewControllerDelegate: ModalViewControllerDelegate? { get set }
    weak var modalManager: ModalManager? { get set }
    
    var modalState: ModalState? { get set }
    
    var contentView: UIView? { get set }
    var displayView: UIView? { get }
    var displayProperties: InterstitialDisplayProperties? { get }
    var isRotationEnabled: Bool { get set }
    
    func setupState(_ modalState: ModalState)
    func creativeDisplayCompleted(_ creative: PBMAbstractCreative)
    
    func addFriendlyObstructions(toMeasurementSession: PBMOpenMeasurementSession)
    
    func configureDisplayView()
    
#if DEBUG
    // Expose for tests
    var closeButtonDecorator: AdViewButtonDecorator? { get }
    var showCloseButtonBlock: VoidBlock? { get set }
    var startCloseDelay: Date? { get }
    var preferAppStatusBarHidden: Bool { get set }
    
    func configureSubView()
    func closeButtonTapped()
    
    func setupCloseButtonDelay()
    func onCloseDelayInterrupted()
#endif
}


