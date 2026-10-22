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

class InterstitialController:
    NSObject,
    PrebidMobileInterstitialControllerProtocol {
    
    var adFormats: Set<AdFormat> {
        get { adConfiguration.adFormats }
        set { adConfiguration.adFormats = newValue }
    }
    
    /// Sets an ad unit as a rewarded
    var isRewarded: Bool {
        get { adConfiguration.adConfiguration.isRewarded }
        set { adConfiguration.adConfiguration.isRewarded = newValue }
    }
    
    var videoControlsConfig: VideoControlsConfiguration {
        get { adConfiguration.adConfiguration.videoControlsConfig }
        set { adConfiguration.adConfiguration.videoControlsConfig = newValue }
    }
    
    var videoParameters: VideoParameters {
        get { adConfiguration.adConfiguration.videoParameters }
        set { adConfiguration.adConfiguration.videoParameters = newValue }
    }
    
    weak var loadingDelegate: InterstitialControllerLoadingDelegate?
    weak var interactionDelegate: InterstitialControllerInteractionDelegate?
    
    var bid: Bid
    var adConfiguration: AdUnitConfig
    var displayProperties: InterstitialDisplayProperties
    
    var transactionFactory: TransactionFactory?
    var adViewManager: AdViewManager?
    private var expirationWorkItem: DispatchWorkItem?
    private(set) var isExpired = false
    private var isDisplayed = false
    private var expirationInterval: NSNumber?
    
    // MARK: - Life cycle
    
    init(bid: Bid, adConfiguration: AdUnitConfig) {
        self.bid = bid
        self.adConfiguration = adConfiguration
        displayProperties = InterstitialDisplayProperties()
    }
    
    convenience init(bid: Bid, configId: String) {
        let adConfig = AdUnitConfig(configId: configId)
        adConfig.adConfiguration.isInterstitialAd = true
        adConfig.adConfiguration.isRewarded = bid.rewardedConfig != nil
        self.init(bid: bid, adConfiguration: adConfig)
    }
    
    deinit {
        expirationWorkItem?.cancel()
    }
    
    func loadAd() {
        guard transactionFactory == nil, !isExpired else {
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
        
        transactionFactory = Factory.createTransactionFactory(
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
        
        Factory.WinNotifierType.notifyThroughConnection(
            PrebidServerConnection.shared,
            winningBid: bid,
            callback: { [weak self] adMarkup in
                if let adMarkup = adMarkup {
                    self?.transactionFactory?.load(adMarkup: adMarkup)
                } else {
                    Log.error("No ad markup received from server.")
                }
            })
    }
    
    func show() {
        if let adViewManager = adViewManager {
            adViewManager.show()
        }
    }
    
    // MARK: - Private Helpers
    
    @available(*, unavailable)
    private override init() {
        fatalError("Init is unavailable.")
    }
    
    func reportFailureWithError(_ error: Error?) {
        if let error = error,
           let loadingDelegate = loadingDelegate {
            loadingDelegate.interstitialController(self, didFailWithError: error)
        }
    }
    
    func reportSuccess() {
        scheduleExpirationIfNeeded()
        if let loadingDelegate = loadingDelegate {
            loadingDelegate.interstitialControllerDidLoadAd(self)
        }
    }
    
    private func display(transaction: Transaction) {
        guard !isExpired else { return }
        
        expirationInterval = transaction.creativeModels.first?.expirationInterval ?? bid.exp
        
        adViewManager = Factory.createAdViewManager(
            connection: PrebidServerConnection.shared,
            modalManagerDelegate: nil
        )
        adViewManager?.adViewManagerDelegate = self
        adViewManager?.adConfiguration.isInterstitialAd = true
        adViewManager?.adConfiguration.isRewarded = adConfiguration.adConfiguration.isRewarded
        adViewManager?.handleExternalTransaction(transaction)
    }
    
    private func scheduleExpirationIfNeeded() {
        guard expirationWorkItem == nil,
              let exp = expirationInterval ?? bid.exp,
              exp.doubleValue > 0 else {
            return
        }
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.expireAd()
        }
        expirationWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + exp.doubleValue, execute: workItem)
    }
    
    private func expireAd() {
        guard !isExpired, !isDisplayed else { return }
        
        isExpired = true
        loadingDelegate?.interstitialControllerDidExpire?(self)
    }

    private func cancelExpiration() {
        expirationWorkItem?.cancel()
        expirationWorkItem = nil
    }
}

extension InterstitialController: AdViewManagerDelegate {
    // MARK: - AdViewManagerDelegate protocol
    
    func viewControllerForModalPresentation() -> UIViewController? {
        interactionDelegate?.viewControllerForModalPresentation(fromInterstitialController: self)
    }
    
    func adLoaded(_ pbmAdDetails: AdDetails) {
        reportSuccess()
    }
    
    func failedToLoad(_ error: Error) {
        reportFailureWithError(error)
    }
    
    func adDidComplete() {
        if let delegate = interactionDelegate {
            delegate.interstitialControllerDidComplete(self)
        }
    }
    
    func adDidDisplay() {
        isDisplayed = true
        cancelExpiration()
        if let delegate = interactionDelegate {
            delegate.interstitialControllerDidDisplay(self)
        }
    }
    
    func adWasClicked() {
        if let delegate = interactionDelegate {
            delegate.interstitialControllerDidClickAd(self)
        }
    }
    
    func adViewWasClicked() {
        if let delegate = interactionDelegate {
            delegate.interstitialControllerDidClickAd(self)
        }
    }
    
    func adDidLeaveApp() {
        if let delegate = interactionDelegate {
            delegate.interstitialControllerDidLeaveApp(self)
        }
    }
    
    func adDidClose() {
        adViewManager = nil
        if let delegate = interactionDelegate {
            delegate.interstitialControllerDidCloseAd(self)
        }
    }
    
    func adDidSendRewardedEvent() {
        if let delegate = interactionDelegate {
            delegate.trackUserReward?(self, PrebidReward(with: bid.rewardedConfig?.reward))
        }
    }
    
    var interstitialDisplayProperties: InterstitialDisplayProperties {
        displayProperties
    }
    
    func adClickthroughDidClose() {}
    func adDidExpand() {}
    func adDidCollapse() {}
}
