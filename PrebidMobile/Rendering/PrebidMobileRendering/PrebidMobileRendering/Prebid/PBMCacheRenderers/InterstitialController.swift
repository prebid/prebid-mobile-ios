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

public class InterstitialController: NSObject, PBMAdViewManagerDelegate {
    
    @objc public var adFormat: AdFormat {
        get { adConfiguration.adFormat }
        set { adConfiguration.adFormat = newValue }
    }
    
    /// Sets a video interstitial ad unit as an opt-in video
    @objc public var isOptIn: Bool {
        get { adConfiguration.isOptIn }
        set { adConfiguration.isOptIn = newValue }
    }
    
    @objc public weak var loadingDelegate: InterstitialControllerLoadingDelegate?
    @objc public weak var interactionDelegate: InterstitialControllerInteractionDelegate?
    
    var bid: Bid
    var adConfiguration: AdUnitConfig
    var displayProperties: PBMInterstitialDisplayProperties
    
    var transactionFactory: PBMTransactionFactory?
    var adViewManager: PBMAdViewManager?
    
    // MARK: - Life cycle
    
    @objc public init(bid: Bid, adConfiguration: AdUnitConfig) {
        self.bid = bid
        self.adConfiguration = adConfiguration
        displayProperties = PBMInterstitialDisplayProperties()
    }
    
    @objc public convenience init(bid: Bid, configId: String) {
        let adConfig = AdUnitConfig(configID: configId)
        adConfig.isInterstitial = true
        self.init(bid: bid, adConfiguration: adConfig)
    }
    
    @objc public func loadAd() {
        guard transactionFactory == nil else {
            return
        }

        transactionFactory = PBMTransactionFactory(bid: bid,
                                                   adConfiguration: adConfiguration,
                                                   connection: PBMServerConnection.singleton(),
                                                   callback: { [weak self] transaction, error in
                
            if let transaction = transaction {
                self?.display(transaction: transaction)
            } else {
                self?.reportFailureWithError(error)
            }
        })
        
        PBMWinNotifier.notifyThroughConnection(PBMServerConnection.singleton(),
                                               winning: bid,
                                               callback: { [weak self] adMarkup in
            if let adMarkup = adMarkup {
                self?.transactionFactory?.load(withAdMarkup: adMarkup)
            } else {
                //TODO: inform failure
            }
        })
    }

    @objc public func show() {
        if let adViewManager = adViewManager {
            adViewManager.show()
        }
    }
    
    // MARK: - PBMAdViewManagerDelegate protocol
    
    @objc public func viewControllerForModalPresentation() -> UIViewController? {
        if let interactionDelegate = interactionDelegate {
            return interactionDelegate.viewControllerForModalPresentation(from: self)
        } else {
            return nil
        }
    }

    @objc public func adLoaded(_ pbmAdDetails: PBMAdDetails) {
        reportSuccess()
    }

    @objc public func failed(toLoad error: Error) {
        reportFailureWithError(error)
    }

    @objc public func adDidComplete() {
        if let delegate = interactionDelegate {
            delegate.interstitialControllerDidComplete(self)
        }
    }
    
    @objc public func adDidDisplay() {
        if let delegate = interactionDelegate {
            delegate.interstitialControllerDidDisplay(self)
        }
    }
    
    @objc public func adWasClicked() {
        if let delegate = interactionDelegate {
            delegate.interstitialControllerDidClickAd(self)
        }
    }
    
    @objc public func adViewWasClicked() {
        if let delegate = interactionDelegate {
            delegate.interstitialControllerDidClickAd(self)
        }
    }
    
    @objc public func adDidExpand() {
    }
    
    @objc public func adDidCollapse() {
    }
    
    @objc public func adDidLeaveApp() {
        if let delegate = interactionDelegate {
            delegate.interstitialControllerDidLeaveApp(self)
        }
    }
    
    @objc public func adClickthroughDidClose() {
    }
    
    @objc public func adDidClose() {
        adViewManager = nil
        if let delegate = interactionDelegate {
            delegate.interstitialControllerDidCloseAd(self)
        }
    }
    
    @objc public func interstitialDisplayProperties() -> PBMInterstitialDisplayProperties {
        displayProperties
    }
    
    // MARK: - Private Helpers
    
    @available(*, unavailable)
    private override init() {
        fatalError("Init is unavailable.")
    }
    
    func reportFailureWithError(_ error: Error?) {
        transactionFactory = nil
        if let error = error,
           let loadingDelegate = loadingDelegate {
            loadingDelegate.interstitialController(self, didFailWithError: error)
        }
    }

    func reportSuccess() {
        transactionFactory = nil
        if let loadingDelegate = loadingDelegate {
            loadingDelegate.interstitialControllerDidLoadAd(self)
        }
    }

    func display(transaction: PBMTransaction) {
        adViewManager = PBMAdViewManager(connection: PBMServerConnection.singleton(),
                                         modalManagerDelegate: nil)
        adViewManager?.adViewManagerDelegate = self
        adViewManager?.adConfiguration.isInterstitialAd = true
        adViewManager?.adConfiguration.isOptIn = adConfiguration.isOptIn
        adViewManager?.handleExternalTransaction(transaction)
    }
}
