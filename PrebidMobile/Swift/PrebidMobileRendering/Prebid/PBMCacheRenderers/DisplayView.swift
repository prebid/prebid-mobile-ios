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

import UIKit

@objc(PBMDisplayView)
@objcMembers public
class DisplayView: UIView, PrebidMobileDisplayViewProtocol, AdViewManagerDelegate, ModalManagerDelegate {

    // MARK: - Public Properties

    public weak var loadingDelegate: DisplayViewLoadingDelegate?
    public weak var interactionDelegate: DisplayViewInteractionDelegate?

    public var isCreativeOpened: Bool {
        adViewManager?.isCreativeOpened ?? false
    }

    // MARK: - Internal Properties

    let bid: Bid
    let adConfiguration: AdUnitConfig
    public var interstitialDisplayProperties = InterstitialDisplayProperties()
    private(set) var connection: PrebidServerConnectionProtocol? = nil
    var transactionFactory: TransactionFactory?
    var adViewManager: AdViewManager?
    
    weak var videoPlaybackDelegate: DisplayViewVideoPlaybackDelegate?

    // MARK: - Initializers

    public convenience init(frame: CGRect, bid: Bid, configId: String) {
        let config = AdUnitConfig(configId: configId, size: bid.size)
        self.init(frame: frame, bid: bid, adConfiguration: config)
    }

    public init(frame: CGRect, bid: Bid, adConfiguration: AdUnitConfig) {
        self.bid = bid
        self.adConfiguration = adConfiguration
        super.init(frame: frame)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func loadAd() {
        guard transactionFactory == nil else { return }

        adConfiguration.adConfiguration.winningBidAdFormat = bid.adFormat
        adConfiguration.adConfiguration.rewardedConfig = RewardedConfig(ortbRewarded: bid.rewardedConfig)

        transactionFactory = Factory.createTransactionFactory(
            bid: bid,
            adConfiguration: adConfiguration,
            connection: connection ?? PrebidServerConnection.shared
        ) { [weak self] transaction, error in
            guard let self else { return }

            if let error = error {
                self.reportFailure(with: error)
            } else if let transaction = transaction {
                self.display(transaction: transaction)
            }
        }
        
        Factory.WinNotifierType.notifyThroughConnection(
            PrebidServerConnection.shared,
            winningBid: bid) { [weak self] adMarkup in
                guard let adMarkup else { return }
                self?.transactionFactory?.load(adMarkup: adMarkup)
            }
    }

    // MARK: - AdViewManagerDelegate

    public func viewControllerForModalPresentation() -> UIViewController? {
        interactionDelegate?.viewControllerForModalPresentation(fromDisplayView: self)
    }

    public func adLoaded(_ adDetails: AdDetails) {
        reportSuccess()
    }

    public func failedToLoad(_ error: Error) {
        reportFailure(with: error)
    }

    public func adDidComplete() {
        // nop?
        // Note: modal handled in `displayViewDidDismissModal`
    }

    public func adDidDisplay() {
        interactionDelegate?.trackImpression(forDisplayView: self)
    }

    public func adWasClicked() {
        interactionDelegateWillPresentModal()
    }

    public func adViewWasClicked() {
        // nop?
        // Note: modal handled in `modalManagerWillPresentModal`
    }

    public func adDidExpand() {
        // nop?
        // Note: modal handled in `modalManagerWillPresentModal`
    }

    public func adDidCollapse() {
        // nop?
        // Note: modal handled in `displayViewDidDismissModal`
    }

    public func adDidLeaveApp() {
        interactionDelegate?.didLeaveApp(from: self)
    }

    public func adClickthroughDidClose() {
        interactionDelegateDidDismissModal()
    }

    public func adDidClose() {}

    public var displayView: UIView {
        return self
    }

    // MARK: - ModalManagerDelegate

    public func modalManagerWillPresentModal() {
        interactionDelegateWillPresentModal()
    }

    public func modalManagerDidDismissModal() {
        interactionDelegateDidDismissModal()
    }

    // MARK: - Private Helpers

    private func reportFailure(with error: Error) {
        loadingDelegate?.displayView(self, didFailWithError: error)
    }

    private func reportSuccess() {
        loadingDelegate?.displayViewDidLoadAd(self)
    }

    private func display(transaction: Transaction) {
        let activeConnection = connection ?? PrebidServerConnection.shared

        let manager = Factory.createAdViewManager(
            connection: activeConnection,
            modalManagerDelegate: self
        )

        manager.adViewManagerDelegate = self
        manager.adConfiguration = adConfiguration.adConfiguration

        if adConfiguration.adConfiguration.winningBidAdFormat == .video {
            adConfiguration.adConfiguration.isBuiltInVideo = true
        }

        self.adViewManager = manager
        manager.handleExternalTransaction(transaction)
    }

    private func interactionDelegateWillPresentModal() {
        guard let delegate = interactionDelegate,
              delegate.responds(to: #selector(DisplayViewInteractionDelegate.willPresentModal(from:))) else {
            return
        }
        delegate.willPresentModal(from: self)
    }

    private func interactionDelegateDidDismissModal() {
        guard let delegate = interactionDelegate,
              delegate.responds(to: #selector(DisplayViewInteractionDelegate.didDismissModal(from:))) else {
            return
        }
        delegate.didDismissModal(from: self)
    }
    
    public func videoAdWasMuted() {
        videoPlaybackDelegate?.videoPlaybackWasMuted()
    }
    
    public func videoAdWasUnmuted() {
        videoPlaybackDelegate?.videoPlaybackWasUnmuted()
    }
    
    public func videoAdDidFinish() {
        videoPlaybackDelegate?.videoPlaybackDidComplete()
    }
    
    public func videoAdDidPause() {
        videoPlaybackDelegate?.videoPlaybackDidPause()
    }
    
    public func videoAdDidResume() {
        videoPlaybackDelegate?.videoPlaybackDidResume()
    }
}
