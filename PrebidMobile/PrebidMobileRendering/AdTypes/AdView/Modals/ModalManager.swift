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

@objc(PBMModalManager) @_spi(PBMInternal) public
class ModalManager: NSObject, ModalViewControllerDelegate {
    weak var delegate: ModalManagerDelegate?
    
    @objc public var modalViewController: ModalViewController?
    
    //The VC class to use to display modals. Defaults is nil.
    var modalViewControllerClass: ModalViewController.Type?
    
    var modalStateStack = [ModalState]()
    var deferredModalState: DeferredModalState?
    
    var isModalDismissing: Bool = false
    
    @objc public init(delegate: ModalManagerDelegate? = nil) {
        self.delegate = delegate
    }
    
    deinit {
        if let modalViewController {
            let delegate = delegate
            modalViewController.dismiss(animated: true) { [weak delegate] in
                delegate?.modalManagerDidDismissModal()
            }
        }
    }
    
    @objc public func forceOrientation(_ orientation: UIInterfaceOrientation) {
        //DISCLAIMER: Forcing orientation does not work for iPads
        DispatchQueue.main.async {
            Log.info("Forcing orientation to \(orientation.description)")
            UIDevice.current.setValue(NSNumber(integerLiteral: orientation.rawValue), forKey: "orientation")
        }
    }
    
    @objc public func pushModal(_ state: ModalState,
                                fromRootViewController: UIViewController,
                                animated: Bool,
                                shouldReplace: Bool,
                                completionHandler: VoidBlock?) -> VoidBlock? {
        
        if let deferredModalState {
            guard state === deferredModalState.modalState else {
                Log.error("Attempting to push modal state while another deferred state is being prepared")
                return nil
            }
            
            // Previously deferred modalState has been resolved and is being pushed
            self.deferredModalState = nil // no longer deffered
        }
        
        if shouldReplace, !modalStateStack.isEmpty {
            modalStateStack.removeLast()
        }
        
        //Add the content to the stack
        modalStateStack.append(state)
        display(state: state,
                fromRootViewController: fromRootViewController,
                animated: animated,
                completionHandler: completionHandler)
        
        return { [weak self, weak state] in
            guard let self, let state else {
                return
            }
            
            self.removeModal(state)
        }
    }
    
    func pushDeferredModal(_ deferredModalState: any DeferredModalState) {
        if self.deferredModalState == nil, !isModalDismissing {
            self.deferredModalState = deferredModalState
            deferredModalState.prepareAndPush(modalManager: self) { [weak self, weak deferredModalState] in
                if let self, let deferredModalState, deferredModalState === self.deferredModalState {
                    self.deferredModalState = nil
                }
            }
        }
    }
    
    func removeModal(_ modalState: any ModalState) {
        if modalState === modalStateStack.last {
            popModal()
        } else {
            modalStateStack.removeAll { $0 === modalState }
        }
    }
    
    func popModal() {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            
            //Is the stack empty?
            guard !self.modalStateStack.isEmpty else {
                Log.error("popModal called on empty modalStateStack!")
                return
            }
            
            let poppedModalState = self.modalStateStack.removeLast()

            //Was that the last modal in the stack?
            if let state = self.modalStateStack.last {
                //There's still at least one left.
                //We need force orientation once again
                if let displayProperties = state.displayProperties {
                    if displayProperties.interstitialLayout == .landscape {
                        forceOrientation(.landscapeLeft)
                    } else if displayProperties.interstitialLayout == .portrait {
                        forceOrientation(.portrait)
                    }
                }
                
                self.display(state: state, fromRootViewController: nil, animated: false, completionHandler: nil)
                
                poppedModalState.onStatePopFinished?(poppedModalState)
            } else {
                //Stack is empty, dismiss the VC.
                self.dismissModalViewController(lastModalState: poppedModalState)
            }
        }
    }
    
    func dismissModalViewController(lastModalState: ModalState) {
        dismissModalOnce(animated: true) { [weak self] in
            guard let self else {
                return
            }
            
            self.modalViewController = nil
            lastModalState.onStatePopFinished?(lastModalState)
        }
    }
    
    @objc public func creativeDisplayCompleted(_ creative: PBMAbstractCreative) {
        modalViewController?.creativeDisplayCompleted(creative)
    }
    
    func dismissModalOnce(animated: Bool, completionHandler: VoidBlock?) {
        guard !isModalDismissing, let modalViewController else {
            return
        }
        isModalDismissing = true
        
        let isLastState = modalStateStack.isEmpty
        modalViewController.dismiss(animated: animated) { [weak self] in
            guard let self else {
                return
            }
            
            self.isModalDismissing = false
            if (isLastState) {
                self.delegate?.modalManagerDidDismissModal()
            }
            completionHandler?()
        }
    }
    
    func display(state: ModalState,
                 fromRootViewController: UIViewController?,
                 animated: Bool, completionHandler: VoidBlock?) {
        
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            
            let modalViewController: ModalViewController
            
            if let modalVC = self.modalViewController {
                modalViewController = modalVC
                // Verifying type of modalViewController
                if state.mraidState == .resized,
                   !modalViewController.isKind(of: NonModalViewController.self) {
                    let rootVC = modalViewController.presentingViewController
                    self.dismissModalOnce(animated: true) { [weak self] in
                        guard let self else {
                            return
                        }
                        self.modalViewController = nil
                        self.display(state: state,
                                     fromRootViewController: rootVC,
                                     animated: false, completionHandler:
                                        completionHandler)
                    }
                    return
                } else if state.mraidState != .resized,
                          modalViewController.isKind(of: NonModalViewController.self) {
                    let rootVC = modalViewController.presentingViewController
                    self.dismissModalOnce(animated: true) { [weak self] in
                        guard let self else {
                            return
                        }
                        
                        self.modalViewController = nil
                        display(state: state,
                                fromRootViewController: rootVC,
                                animated: animated,
                                completionHandler: completionHandler)
                    }
                    return
                } else if state.mraidState == .resized,
                          modalViewController.isKind(of: NonModalViewController.self) {
                    if let modalPresenter = modalViewController.presentationController as? ModalPresentationController {
                        modalPresenter.frameOfPresentedView = state.displayProperties?.contentFrame
                        modalPresenter.containerViewWillLayoutSubviews()
                    }
                }
            } else {
                // If modalViewController doesn't exist, create one and show it
                
                if let modalViewControllerClass = self.modalViewControllerClass {
                    modalViewController = ModalViewController()
                } else if state.mraidState == .resized {
                    modalViewController = NonModalViewController(
                        frameOfPresentedView: state.displayProperties?.contentFrame ?? .zero)
                } else {
                    modalViewController = ModalViewController()
                    modalViewController.modalPresentationStyle = .overFullScreen
                }
                
                modalViewController.isRotationEnabled = state.isRotationEnabled
                modalViewController.modalManager = self
                modalViewController.modalViewControllerDelegate = self
                self.modalViewController = modalViewController
                
                guard let fromRootViewController else {
                    Log.error("No root VC to present from")
                    return
                }
                
                self.delegate?.modalManagerWillPresentModal()
                fromRootViewController.present(modalViewController, animated: animated)
            }
            
            // Step 2: setup the current modal state
            modalViewController.setupState(state)
            
            // Step 3: run completion if any
            completionHandler?()
        }
    }
    
    func dismissAllInterstitialsIfAny() {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            
            if let poppedModalState = self.modalStateStack.last {
                self.modalStateStack.removeAll()
                self.dismissModalViewController(lastModalState: poppedModalState)
            }
                
        }
    }
    
    func hideModal(animated: Bool, completionHandler: VoidBlock?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            
            if self.modalViewController != nil {
                self.dismissModalOnce(animated: animated, completionHandler: completionHandler)
            } else  {
                completionHandler?()
            }
        }
    }
    
    func backModal(animated: Bool,
                   fromRootViewController: UIViewController?,
                   completionHandler: VoidBlock?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            
            if let modalViewController = self.modalViewController, let fromRootViewController {
                fromRootViewController.present(modalViewController, animated: animated, completion: completionHandler)
            } else {
                completionHandler?()
            }
        }
    }
    
    //TODO: Consider moving to PBMAbstractCreative
    // MARK: PBMModalViewControllerDelegate
    
    public func modalViewControllerCloseButtonTapped(_ modalViewController: ModalViewController) {
        if let modalState = modalViewController.modalState {
            removeModal(modalState)
        }
    }
    
    public func modalViewControllerDidLeaveApp() {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            
            for state in self.modalStateStack.reversed() {
                state.onStateHasLeftApp?(state)
            }
            
            // close the interstitial *after* all the interstitials have been notified above.
            if let modalViewController = self.modalViewController {
                modalViewControllerCloseButtonTapped(modalViewController)
            }
        }
    }
}
