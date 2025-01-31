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

import UIKit

@objcMembers
class BaseInterstitialAdUnit:
    NSObject,
    PBMInterstitialAdLoaderDelegate,
    AdLoadFlowControllerDelegate,
    InterstitialControllerInteractionDelegate,
    InterstitialEventInteractionDelegate {
    
    // MARK: - Internal Properties
    
    let adUnitConfig: AdUnitConfig
    let eventHandler: PBMPrimaryAdRequesterProtocol
    
    weak var delegate: BaseInterstitialAdUnitProtocol? {
        didSet {
            if let adLoader {
                delegate?.callEventHandler_setLoadingDelegate(adLoader)
            }
        }
    }
    
    var bannerParameters: BannerParameters {
        get { adUnitConfig.adConfiguration.bannerParameters }
    }
    
    var videoParameters: VideoParameters {
        get { adUnitConfig.adConfiguration.videoParameters }
    }
    
    var lastBidResponse: BidResponse? {
        adLoadFlowController?.bidResponse
    }
    
    var isReady: Bool {
        objc_sync_enter(blocksLockToken)
        if let block = isReadyBlock {
            let res = block()
            objc_sync_exit(blocksLockToken)
            return res
        }
        
        objc_sync_exit(blocksLockToken)
        return false
    }
    
    // MARK: - Private Properties
    
    private var adLoadFlowController: PBMAdLoadFlowController!
    
    private let blocksLockToken: NSObject
    private var showBlock: ((UIViewController?) -> Void)?
    private var currentAdBlock: ((UIViewController?) -> Void)?
    private var isReadyBlock: (() -> Bool)?
    private var adLoader: PBMInterstitialAdLoader?
    
    private weak var targetController: UIViewController?
    
    init(
        configID: String,
        minSizePerc: NSValue?,
        eventHandler: PBMPrimaryAdRequesterProtocol
    ) {
        adUnitConfig = AdUnitConfig(configId: configID)
        blocksLockToken = NSObject()
        
        self.eventHandler = eventHandler
        
        super.init()
        
        let adLoader = PBMInterstitialAdLoader(
            delegate: self,
            eventHandler: eventHandler
        )
        
        self.adLoader = adLoader
        
        adLoadFlowController = PBMAdLoadFlowController(
            bidRequesterFactory: { adUnitConfig in
                return PBMBidRequester(
                    connection: PrebidServerConnection.shared,
                    sdkConfiguration: Prebid.shared,
                    targeting: Targeting.shared,
                    adUnitConfiguration: adUnitConfig
                )
            },
            adLoader: adLoader,
            adUnitConfig: adUnitConfig,
            delegate: self,
            configValidationBlock: { _, _ in true }
        )
        
        // Set default values
        adUnitConfig.adConfiguration.isInterstitialAd = true
        adUnitConfig.minSizePerc = minSizePerc
        adUnitConfig.adPosition = .fullScreen
        adUnitConfig.adConfiguration.adFormats = [.banner, .video]
        adUnitConfig.adConfiguration.bannerParameters.api = PrebidConstants.supportedRenderingBannerAPISignals
        videoParameters.placement = .Interstitial
        videoParameters.plcmnt = .Interstitial
    }
    
    // MARK: - Public Methods
    
    func loadAd() {
        adLoadFlowController.refresh()
    }
    
    func show(from controller: UIViewController) {
        // It is expected from the user to call this method on main thread
        assert(Thread.isMainThread, "Expected to only be called on the main thread");
        
        objc_sync_enter(blocksLockToken)
        
        guard self.showBlock != nil,
              self.currentAdBlock == nil else {
            objc_sync_exit(blocksLockToken)
            return;
        }
        
        isReadyBlock = nil
        currentAdBlock = showBlock
        showBlock = nil
        
        delegate?.callDelegate_willPresentAd()
        targetController = controller
        currentAdBlock?(controller)
        objc_sync_exit(blocksLockToken)
    }
    
    // MARK: - PBMInterstitialAdLoaderDelegate
    
    public func interstitialAdLoader(
        _ interstitialAdLoader: PBMInterstitialAdLoader,
        loadedAd showBlock: @escaping (UIViewController?) -> Void,
        isReadyBlock: @escaping () -> Bool
    ) {
        objc_sync_enter(blocksLockToken)
        self.showBlock = showBlock
        self.isReadyBlock = isReadyBlock
        objc_sync_exit(blocksLockToken)
        
        reportLoadingSuccess()
    }
    
    public func interstitialAdLoader(
        _ interstitialAdLoader: PBMInterstitialAdLoader,
        createdInterstitialController interstitialController: InterstitialController
    ) {
        interstitialController.interactionDelegate = self
    }
    
    // MARK: - AdLoadFlowControllerDelegate
    
    public func adLoadFlowControllerWillSendBidRequest(_ adLoadFlowController: PBMAdLoadFlowController) {}
    
    /// Called when the ad load flow controller is about to request the primary ad.
    public func adLoadFlowControllerWillRequestPrimaryAd(_ adLoadFlowController: PBMAdLoadFlowController) {
        delegate?.callEventHandler_setInteractionDelegate()
    }
    
    /// Called to determine if the ad load flow controller should continue with the current flow.
    public func adLoadFlowControllerShouldContinue(_ adLoadFlowController: PBMAdLoadFlowController) -> Bool {
        true
    }
    
    public func adLoadFlowController(
        _ adLoadFlowController: PBMAdLoadFlowController,
        failedWithError error: Error?
    ) {
        reportLoadingFailed(with: error)
    }
    
    // MARK: - InterstitialControllerInteractionDelegate
    
    /// Tracks an impression for the given interstitial controller.
    public func trackImpression(forInterstitialController: PrebidMobileInterstitialControllerProtocol) {
        DispatchQueue.main.async {
            self.delegate?.callEventHandler_trackImpression()
        }
    }
    
    /// Called when the ad in the interstitial controller is clicked.
    public func interstitialControllerDidClickAd(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {
        assert(Thread.isMainThread, "Expected to only be called on the main thread")
        delegate?.callDelegate_didClickAd()
    }
    
    /// Called when the ad in the interstitial controller is closed.
    public func interstitialControllerDidCloseAd(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {
        assert(Thread.isMainThread, "Expected to only be called on the main thread")
        delegate?.callDelegate_didDismissAd()
    }
    
    /// Called when the ad in the interstitial controller causes the app to leave.
    public func interstitialControllerDidLeaveApp(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {
        assert(Thread.isMainThread, "Expected to only be called on the main thread")
        delegate?.callDelegate_willLeaveApplication()
    }
    
    public func interstitialControllerDidDisplay(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {}
    public func interstitialControllerDidComplete(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {}
    public func trackUserReward(_ interstitialController: PrebidMobileInterstitialControllerProtocol, _ reward: PrebidReward) {}
    
    public func viewControllerForModalPresentation(
        fromInterstitialController: PrebidMobileInterstitialControllerProtocol
    ) -> UIViewController? {
        return targetController
    }
    
    // MARK: - InterstitialEventInteractionDelegate
    
    /// Called when an ad is about to be presented.
    public func willPresentAd() {
        DispatchQueue.main.async {
            self.delegate?.callDelegate_willPresentAd()
        }
    }
    
    /// Called when an ad has been dismissed.
    public func didDismissAd() {
        objc_sync_enter(blocksLockToken)
        currentAdBlock = nil
        objc_sync_exit(blocksLockToken)
        
        DispatchQueue.main.async {
            self.delegate?.callDelegate_didDismissAd()
        }
    }
    
    /// Called when the ad causes the app to leave.
    public func willLeaveApp() {
        DispatchQueue.main.async {
            self.delegate?.callDelegate_willLeaveApplication()
        }
    }
    
    /// Called when an ad is clicked.
    public func didClickAd() {
        DispatchQueue.main.async {
            self.delegate?.callDelegate_didClickAd()
        }
    }
    
    // MARK: - Private methods
    
    private func reportLoadingSuccess() {
        DispatchQueue.main.async {
            self.delegate?.callDelegate_didReceiveAd()
        }
    }
    
    private func reportLoadingFailed(with error: Error?) {
        DispatchQueue.main.async {
            self.delegate?.callDelegate_didFailToReceiveAd(with: error)
        }
    }
}
