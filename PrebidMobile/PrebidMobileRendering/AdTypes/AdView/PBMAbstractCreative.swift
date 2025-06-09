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

/**
 *  `PBMAbstractCreative`'s purpose is a bundling of a model and a view. It acts as an adapter between
 *  the view and the SDK, it's essentially the C in MVC.
 *
 *  All `Creatives` must conform to this protocol. Each creative has-a model which contains the
 *  creative info, and must implement a few methods for handling display of the creative.
 */
@objc @_spi(PBMInternal) public
protocol PBMAbstractCreative: NSObjectProtocol {
    
    weak var transaction: Transaction? { get }
    var creativeModel: CreativeModel { get }
    var eventManager: EventManager { get }
    var skOverlayManager: SKOverlayManager? { get set }
    var view: UIView? { get set }
    var clickthroughVisible: Bool { get set }
    var modalManager: ModalManager? { get set }
    var dispatchQueue: DispatchQueue { get set }
    var viewabilityTracker: PBMCreativeViewabilityTracker? { get set }
    var dismissInterstitialModalState: VoidBlock { get }
    var isDownloaded: Bool { get set }
    
    // Indicates whether creative is opened with user action (expanded, clickthrough showed ...) or not
    // Note that subclasses provide specific implementation.
    var isOpened: Bool { get }
    
    // The time that that the ad is displayed (i.e. before its refreshed).
    // Note that subclasses provide specific implementation.
    var displayInterval: NSNumber? { get }
    
    weak var creativeResolutionDelegate: PBMCreativeResolutionDelegate? { get set }
    weak var creativeViewDelegate: CreativeViewDelegate? { get set }
    weak var viewControllerForPresentingModals: UIViewController? { get set }
    
    var isMuted: Bool { get }
    
    init(creativeModel: CreativeModel,
         transaction: Transaction)
    
    func setupView()
    func display(rootViewController: UIViewController)
    func showAsInterstitial(fromRootViewController: UIViewController,
                            displayProperties: InterstitialDisplayProperties)
    func handleClickthrough(_ url: URL)
    
    //Resolution
    func onResolutionCompleted()
    func onResolutionFailed(_ error: Error)
    
    //Open Measurement
    func createOpenMeasurementSession()
    
    func pause()
    func resume()
    func mute()
    func unmute()
    
    //Modal Manager Events
    func modalManagerDidFinishPop(_ state: ModalState)
    func modalManagerDidLeaveApp(_ state: ModalState)
    
    func onViewabilityChanged(_ viewable: Bool, viewExposure: ViewExposure)
}
