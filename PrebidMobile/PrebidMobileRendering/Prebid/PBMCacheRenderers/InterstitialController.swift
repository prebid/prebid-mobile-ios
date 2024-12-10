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
public class InterstitialController:
    NSObject,
    PrebidMobileInterstitialControllerProtocol,
    PBMAdViewManagerDelegate {
    
    public var adFormats: Set<AdFormat> {
        get { adConfiguration.adFormats }
        set { adConfiguration.adFormats = newValue }
    }
    
    /// Sets an ad unit as a rewarded
    @objc public var isRewarded: Bool {
        get { adConfiguration.adConfiguration.isRewarded }
        set { adConfiguration.adConfiguration.isRewarded = newValue }
    }
    
    public var videoControlsConfig: VideoControlsConfiguration {
        get { adConfiguration.adConfiguration.videoControlsConfig }
        set { adConfiguration.adConfiguration.videoControlsConfig = newValue }
    }
    
    public var videoParameters: VideoParameters {
        get { adConfiguration.adConfiguration.videoParameters }
        set { adConfiguration.adConfiguration.videoParameters = newValue }
    }
    
    public weak var loadingDelegate: InterstitialControllerLoadingDelegate?
    public weak var interactionDelegate: InterstitialControllerInteractionDelegate?
    
    var bid: Bid
    var adConfiguration: AdUnitConfig
    var displayProperties: PBMInterstitialDisplayProperties
    
    var transactionFactory: PBMTransactionFactory?
    var adViewManager: PBMAdViewManager?
    
    // MARK: - Life cycle
    
    public init(bid: Bid, adConfiguration: AdUnitConfig) {
        self.bid = bid
        self.adConfiguration = adConfiguration
        displayProperties = PBMInterstitialDisplayProperties()
    }
    
    public convenience init(bid: Bid, configId: String) {
        let adConfig = AdUnitConfig(configId: configId)
        adConfig.adConfiguration.isInterstitialAd = true
        adConfig.adConfiguration.isRewarded = bid.rewardedConfig != nil
        self.init(bid: bid, adConfiguration: adConfig)
    }
    
    public func loadAd() {
        guard transactionFactory == nil else {
            return
        }
        
        adConfiguration.adConfiguration.winningBidAdFormat = bid.adFormat
        adConfiguration.adConfiguration.rewardedConfig = RewardedConfig(ortbRewarded: bid.rewardedConfig)
        videoControlsConfig.initialize(with: bid.videoAdConfiguration)
        
        // This part is dedicating to test server-side ad configurations.
        // Need to be removed when ext.prebid.passthrough will be available.
        #if DEBUG
        adConfiguration.adConfiguration.videoControlsConfig.initialize(with: bid.testVideoAdConfiguration)
        #endif
        
        transactionFactory = PBMTransactionFactory(
            bid: bid,
            adConfiguration: adConfiguration,
            connection: PrebidServerConnection.shared,
            callback: { [weak self] transaction, error in
                
                if let transaction = transaction {
                    self?.display(transaction: transaction)
                } else {
                    self?.reportFailureWithError(error)
                }
            })
        
        PBMWinNotifier.notifyThroughConnection(
            PrebidServerConnection.shared,
            winning: bid,
            callback: { [weak self] adMarkup in
                if let adMarkup = adMarkup {
                    self?.transactionFactory?.load(withAdMarkup: adMarkup)
                } else {
                    Log.error("No ad markup received from server.")
                }
            })
    }
    
    public func show() {
        if let adViewManager = adViewManager {
            adViewManager.show()
        }
    }
    
    // MARK: - PBMAdViewManagerDelegate protocol
    
    public func viewControllerForModalPresentation() -> UIViewController? {
        interactionDelegate?.viewControllerForModalPresentation(fromInterstitialController: self)
    }
    
    public func adLoaded(_ pbmAdDetails: PBMAdDetails) {
        reportSuccess()
    }
    
    public func failed(toLoad error: Error) {
        reportFailureWithError(error)
    }
    
    public func adDidComplete() {
        if let delegate = interactionDelegate {
            delegate.interstitialControllerDidComplete(self)
        }
    }
    
    public func adDidDisplay() {
        if let delegate = interactionDelegate {
            delegate.interstitialControllerDidDisplay(self)
        }
    }
    
    public func adWasClicked() {
        if let delegate = interactionDelegate {
            delegate.interstitialControllerDidClickAd(self)
        }
    }
    
    public func adViewWasClicked() {
        if let delegate = interactionDelegate {
            delegate.interstitialControllerDidClickAd(self)
        }
    }
    
    public func adDidLeaveApp() {
        if let delegate = interactionDelegate {
            delegate.interstitialControllerDidLeaveApp(self)
        }
    }
    
    public func adDidClose() {
        adViewManager = nil
        if let delegate = interactionDelegate {
            delegate.interstitialControllerDidCloseAd(self)
        }
    }
    
    @objc public func adDidSendRewardedEvent() {
        if let delegate = interactionDelegate {
            delegate.trackUserReward?(self, PrebidReward(with: bid.rewardedConfig?.reward))
        }
    }
    
    @objc public func interstitialDisplayProperties() -> PBMInterstitialDisplayProperties {
        displayProperties
    }
    
    public func adClickthroughDidClose() {}
    public func adDidExpand() {}
    public func adDidCollapse() {}
    
    // MARK: - Private Helpers
    
    @available(*, unavailable)
    private override init() {
        fatalError("Init is unavailable.")
    }
    
    public func reportFailureWithError(_ error: Error?) {
        if let error = error,
           let loadingDelegate = loadingDelegate {
            loadingDelegate.interstitialController(self, didFailWithError: error)
        }
    }
    
    func reportSuccess() {
        if let loadingDelegate = loadingDelegate {
            loadingDelegate.interstitialControllerDidLoadAd(self)
        }
    }
    
    private func display(transaction: PBMTransaction) {
        adViewManager = PBMAdViewManager(
            connection: PrebidServerConnection.shared,
            modalManagerDelegate: nil
        )
        adViewManager?.adViewManagerDelegate = self
        adViewManager?.adConfiguration.isInterstitialAd = true
        adViewManager?.adConfiguration.isRewarded = adConfiguration.adConfiguration.isRewarded
        adViewManager?.handleExternalTransaction(transaction)
    }
}
