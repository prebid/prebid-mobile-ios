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

public class BaseInterstitialAdUnit :
    NSObject,
    PBMInterstitialAdLoaderDelegate,
    AdLoadFlowControllerDelegate,
    InterstitialControllerInteractionDelegate,
    InterstitialEventInteractionDelegate,
    BaseInterstitialAdUnitProtocol {
    
    // MARK: - Public Properties
    
    public var configID: String {
        adUnitConfig.configID
    }
    
    public var adFormat: AdFormat {
        get { adUnitConfig.adFormat }
        set { adUnitConfig.adFormat = newValue }
    }
        
    public var isReady: Bool {
        objc_sync_enter(blocksLockToken)
        if let block = isReadyBlock {
            let res = block()
            objc_sync_exit(blocksLockToken)
            return res
        }
        
        objc_sync_exit(blocksLockToken)
        return false
    }

    public weak var delegate: AnyObject?
    
    public let adUnitConfig: AdUnitConfig
    
    // MARK: - Private Properties
    
    private var adLoadFlowController: PBMAdLoadFlowController!
    
    private let blocksLockToken: NSObject
        
    private var showBlock: ((UIViewController?) -> Void)?
    private var currentAdBlock: ((UIViewController?) -> Void)?
    private var isReadyBlock: (() -> Bool)?

    private weak var targetController: UIViewController?
    
    // MARK: - Public Methods
    
    required public init(configID: String,
                minSizePerc: NSValue?,
                eventHandler: AnyObject?) {
        
        adUnitConfig = AdUnitConfig(configID: configID)
        adUnitConfig.isInterstitial = true
        adUnitConfig.minSizePerc = minSizePerc
        adUnitConfig.adPosition = .fullScreen
        adUnitConfig.videoPlacementType = .sliderOrFloating
        blocksLockToken = NSObject()

        self.eventHandler = eventHandler

        super.init()
        
        let adLoader = PBMInterstitialAdLoader(delegate: self)
        callEventHandler_setLoadingDelegate(adLoader)
        
        adLoadFlowController =  PBMAdLoadFlowController(bidRequesterFactory: { adUnitConfig in
            return PBMBidRequester(connection: PBMServerConnection.shared,
                                   sdkConfiguration: PrebidRenderingConfig.shared,
                                   targeting: PrebidRenderingTargeting.shared,
                                   adUnitConfiguration: adUnitConfig)
        },
        adLoader: adLoader,
        delegate: self,
        configValidationBlock: { _,_ in true } )
    }
    
    public convenience init(configID: String,
                            minSizePercentage: CGSize,
                            eventHandler:AnyObject?)
    {
        self.init(configID: configID,
                  minSizePerc:NSValue(cgSize: minSizePercentage),
                  eventHandler: eventHandler)
    }

    public convenience init(configID: String,
                            eventHandler:AnyObject?) {
        self.init(configID: configID,
                  minSizePerc:nil,
                  eventHandler: eventHandler)
        
    }

    public convenience init(configID: String,
                            minSizePercentage:CGSize) {
        
        self.init(configID: configID,
                  minSizePerc:NSValue(cgSize: minSizePercentage),
                  eventHandler: nil)
    }

    public convenience init(configID: String)  {
        self.init(configID: configID,
                  minSizePerc:nil,
                  eventHandler: nil)    }
    
    // MARK: - Public Methods
    
    public func loadAd() {
        adLoadFlowController.refresh()
    }
    
    public func show(from controller: UIViewController) {
        // It is expected from the user to call this method on main thread
        assert(Thread.isMainThread, "Expected to only be called on the main thread");
       
        objc_sync_enter(blocksLockToken)

            guard self.showBlock != nil,
                  self.currentAdBlock == nil else {
                objc_sync_exit(blocksLockToken)
                return;
            }
            isReadyBlock = nil;
            currentAdBlock = showBlock;
            showBlock = nil;
        
            callDelegate_willPresentAd()
            targetController = controller;
            currentAdBlock?(controller);
            objc_sync_exit(blocksLockToken)

    }

    // MARK: - Context Data

    @objc public func addContextData(_ data: String, forKey key: String) {
        adUnitConfig.addContextData(data, forKey: key)
    }
    
    @objc public func updateContextData(_ data: Set<String>, forKey key: String) {
        adUnitConfig.updateContextData(data, forKey: key)
    }
    
    @objc public func removeContextDate(forKey key: String) {
        adUnitConfig.removeContextData(forKey: key)
    }
    
    @objc public func clearContextData() {
        adUnitConfig.clearContextData()
    }
    
    // MARK: - PBMInterstitialAdLoaderDelegate
    
    public func interstitialAdLoader(_ interstitialAdLoader: PBMInterstitialAdLoader,
                                     loadedAd showBlock: @escaping (UIViewController?) -> Void,
                                     isReadyBlock: @escaping () -> Bool) {
        objc_sync_enter(blocksLockToken)
        self.showBlock = showBlock
        self.isReadyBlock = isReadyBlock
        objc_sync_exit(blocksLockToken)
        
        reportLoadingSuccess()
    }
    
    public func interstitialAdLoader(_ interstitialAdLoader: PBMInterstitialAdLoader,
                                     createdInterstitialController interstitialController: InterstitialController) {
        interstitialController.interactionDelegate = self
    }
   
    public var eventHandler: Any?
    
    
    // MARK: - AdLoadFlowControllerDelegate
    
    public func adLoadFlowControllerWillSendBidRequest(_ adLoadFlowController: PBMAdLoadFlowController) {
        // nop
    }
    
    public func adLoadFlowControllerWillRequestPrimaryAd(_ adLoadFlowController: PBMAdLoadFlowController) {
        callEventHandler_setInteractionDelegate()
    }
    
    public func adLoadFlowControllerShouldContinue(_ adLoadFlowController: PBMAdLoadFlowController) -> Bool {
        true
    }
    
    public func adLoadFlowController(_ adLoadFlowController: PBMAdLoadFlowController, failedWithError error: Error?) {
        reportLoadingFailed(with: error)
    }
    
    // MARK: - InterstitialControllerInteractionDelegate
    
    public func trackImpression(for interstitialController: InterstitialController) {
        DispatchQueue.main.async {
            self.callEventHandler_trackImpression()
        }
    }
    
    public func interstitialControllerDidClickAd(_ interstitialController: InterstitialController) {
        assert(Thread.isMainThread, "Expected to only be called on the main thread")
        callDelegate_didClickAd()
    }
    
    public func interstitialControllerDidCloseAd(_ interstitialController: InterstitialController) {
        assert(Thread.isMainThread, "Expected to only be called on the main thread")
        callDelegate_didDismissAd()
    }
    
    public func interstitialControllerDidLeaveApp(_ interstitialController: InterstitialController) {
        assert(Thread.isMainThread, "Expected to only be called on the main thread")
        callDelegate_willLeaveApplication()
    }
    
    public func interstitialControllerDidDisplay(_ interstitialController: InterstitialController) {
        
    }
    
    public func interstitialControllerDidComplete(_ interstitialController: InterstitialController) {
        
    }
    
    public func viewControllerForModalPresentation(from interstitialController: InterstitialController) -> UIViewController? {
        return targetController
    }
    
    // MARK: - Private methods

    private func reportLoadingSuccess() {
        DispatchQueue.main.async {
            self.callDelegate_didReceiveAd()
        }
    }

    private func reportLoadingFailed(with error: Error?) {
        DispatchQueue.main.async {
            self.callDelegate_didFailToReceiveAd(with: error)
        }
    }
    
    // MARK: - InterstitialEventInteractionDelegate
    
    public func willPresentAd() {
        DispatchQueue.main.async {
            self.callDelegate_willPresentAd()
        }
    }
    
    public func didDismissAd() {
        objc_sync_enter(blocksLockToken)
        currentAdBlock = nil
        objc_sync_exit(blocksLockToken)
        
        DispatchQueue.main.async {
            self.callDelegate_didDismissAd()
        }
    }
    
    public func willLeaveApp() {
        DispatchQueue.main.async {
            self.callDelegate_willLeaveApplication()
        }
    }
    
    public func didClickAd() {
        DispatchQueue.main.async {
            self.callDelegate_didClickAd()
        }
    }

    // MARK: - BaseInterstitialAdUnitProtocol
    
    public func callEventHandler_requestAd(with bidResponse: PBRBidResponse?) {
        
    }
    
    public func callEventHandler_show(from controller: UIViewController?) {
        
    }

    // MARK: - Abstract Methods
    
    public func callEventHandler_isReady() -> Bool {
        return false // to be overridden in subclass
    }

    public func callDelegate_didReceiveAd() {
        // to be overridden in subclass
    }

    public func callDelegate_didFailToReceiveAd(with: Error?) {
        // to be overridden in subclass
    }

    public func callDelegate_willPresentAd() {
        // to be overridden in subclass
    }

    public func callDelegate_didDismissAd() {
        // to be overridden in subclass
    }

    public func callDelegate_willLeaveApplication() {
        // to be overridden in subclass
    }

    public func callDelegate_didClickAd() {
        // to be overridden in subclass
    }

    public func callEventHandler_setLoadingDelegate(_ loadingDelegate: NSObject?) {
        // to be overridden in subclass
    }

    public func callEventHandler_setInteractionDelegate() {
        // to be overridden in subclass
    }

    public func callEventHandler_showFromViewController(controller: UIViewController?) {
        // to be overridden in subclass
    }

    public func callEventHandler_trackImpression() {
        // to be overridden in subclass
    }
}
