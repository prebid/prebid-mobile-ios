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

@testable @_spi(PBMInternal) import PrebidMobile

// Because the PBMAbstractCreative_Objc's conformance to PBMAbstractCreative is declared in
// objc with a forward declaration, the compiler doesn't let us call PBMAbstractCreative methods
// on instances of PBMAbstractCreative_Objc without an explicit cast.
// As a workaround, we explicitly redeclare all of the protocol's methods here -- except for those
// that are declared in PBMAbstractCreative+PbmTestExtension.h to allow for subclass overrides.
extension PBMAbstractCreative_Objc {
    private var p: AbstractCreative { self as AbstractCreative }
    
    weak var transaction: Transaction? { p.transaction }
    var creativeModel: CreativeModel { p.creativeModel }
    var eventManager: EventManager { p.eventManager }
    var skOverlayManager: SKOverlayManager? {
        get { p.skOverlayManager }
        set { p.skOverlayManager = newValue }
    }
    var view: UIView? {
        get { p.view }
        set { p.view = newValue }
    }
    var clickthroughVisible: Bool {
        get { p.clickthroughVisible }
        set { p.clickthroughVisible = newValue }
    }
    var modalManager: ModalManager? {
        get { p.modalManager }
        set { p.modalManager = newValue }
    }
    var dispatchQueue: DispatchQueue {
        get { p.dispatchQueue }
        set { p.dispatchQueue = newValue }
    }
    var viewabilityTracker: CreativeViewabilityTracker? {
        get { p.viewabilityTracker }
        set { p.viewabilityTracker = newValue }
    }
    var dismissInterstitialModalState: PBMVoidBlock { p.dismissInterstitialModalState }
    var isDownloaded: Bool {
        get { p.isDownloaded }
        set { p.isDownloaded = newValue }
    }
    
    var isOpened: Bool { p.isOpened }
    
    var displayInterval: NSNumber? { p.displayInterval }
    
    weak var creativeResolutionDelegate: CreativeResolutionDelegate? {
        get { p.creativeResolutionDelegate }
        set { p.creativeResolutionDelegate = newValue }
    }
    weak var creativeViewDelegate: CreativeViewDelegate? {
        get { p.creativeViewDelegate }
        set { p.creativeViewDelegate = newValue }
    }
    weak var viewControllerForPresentingModals: UIViewController? {
        get { p.viewControllerForPresentingModals }
        set { p.viewControllerForPresentingModals = newValue }
    }
    
    var isMuted: Bool { p.isMuted }
    
    func setupView() {
        p.setupView()
    }
    func display(rootViewController: UIViewController) {
        p.display(rootViewController: rootViewController)
    }
    func showAsInterstitial(fromRootViewController: UIViewController,
                            displayProperties: InterstitialDisplayProperties) {
        p.showAsInterstitial(fromRootViewController: fromRootViewController, displayProperties: displayProperties)
    }
    func handleClickthrough(_ url: URL) {
        p.handleClickthrough(url)
    }
    
    func onResolutionCompleted() {
        p.onResolutionCompleted()
    }
    func onResolutionFailed(_ error: Error) {
        p.onResolutionFailed(error)
    }
    
    func createOpenMeasurementSession() {
        p.createOpenMeasurementSession()
    }
    
    func mute() {
        p.mute()
    }
    func unmute() {
        p.unmute()
    }
    
    func onViewabilityChanged(_ viewable: Bool, viewExposure: ViewExposure) {
        p.onViewabilityChanged(viewable, viewExposure: viewExposure)
    }
}
