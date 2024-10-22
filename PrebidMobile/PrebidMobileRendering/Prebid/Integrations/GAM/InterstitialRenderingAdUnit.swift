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

/// Represents an interstitial ad unit. Built for rendering type of integration.
@objcMembers
public class InterstitialRenderingAdUnit: BaseInterstitialAdUnit {
    
    /// The area of the skip button in the video controls, specified as a percentage of the screen width.
    @objc public var skipButtonArea: Double {
        get { adUnitConfig.adConfiguration.videoControlsConfig.skipButtonArea }
        set { adUnitConfig.adConfiguration.videoControlsConfig.skipButtonArea = newValue }
    }
    
    /// The position of the skip button in the video controls.
    @objc public var skipButtonPosition: Position {
        get { adUnitConfig.adConfiguration.videoControlsConfig.skipButtonPosition }
        set { adUnitConfig.adConfiguration.videoControlsConfig.skipButtonPosition = newValue }
    }
    
    /// The delay before the skip button appears, in seconds.
    @objc public var skipDelay: Double {
        get { adUnitConfig.adConfiguration.videoControlsConfig.skipDelay }
        set { adUnitConfig.adConfiguration.videoControlsConfig.skipDelay = newValue }
    }

    /// Initializes a new interstitial rendering ad unit with the specified configuration ID.
    /// - Parameter configID: The unique identifier for the ad unit configuration.
    @objc public init(configID: String) {
        super.init(configID: configID,
                   minSizePerc: nil,
                   eventHandler: InterstitialEventHandlerStandalone())
    }

    /// Initializes a new interstitial rendering ad unit with the specified configuration ID and minimum size percentage.
    /// - Parameter configID: The unique identifier for the ad unit configuration.
    /// - Parameter minSizePercentage: The minimum size percentage of the ad.
    @objc public init(configID: String, minSizePercentage: CGSize) {
        super.init(
            configID: configID,
            minSizePerc: NSValue(cgSize: minSizePercentage),
            eventHandler: InterstitialEventHandlerStandalone())
    }

    /// Initializes a new interstitial rendering ad unit with the specified configuration ID, minimum size percentage, and event handler.
    /// - Parameter configID: The unique identifier for the ad unit configuration.
    /// - Parameter minSizePercentage: The minimum size percentage of the ad.
    /// - Parameter eventHandler: The event handler to manage ad events.
    @objc public init(configID: String, minSizePercentage: CGSize, eventHandler: AnyObject) {
        super.init(
            configID: configID,
            minSizePerc: NSValue(cgSize: minSizePercentage),
            eventHandler: eventHandler)
    }
    
    /// Initializes a new interstitial rendering ad unit with the specified configuration ID, minimum size percentage, and event handler.
    /// - Parameter configID: The unique identifier for the ad unit configuration.
    /// - Parameter minSizePerc: The minimum size percentage of the ad.
    /// - Parameter eventHandler: The event handler to manage ad events.
    @objc required init(configID: String, minSizePerc: NSValue?, eventHandler: AnyObject?) {
        super.init(
            configID: configID,
            minSizePerc: minSizePerc,
            eventHandler: eventHandler)
    }
    
    // MARK: - Protected overrides

    /// Called when an ad is successfully received.
    @objc public override func callDelegate_didReceiveAd() {
        if let delegate = self.delegate as? InterstitialAdUnitDelegate {
            delegate.interstitialDidReceiveAd?(self)
        }
    }
    
    /// Called when the ad fails to be received.
    @objc public override func callDelegate_didFailToReceiveAd(with error: Error?) {
        if let delegate = self.delegate as? InterstitialAdUnitDelegate {
            delegate.interstitial?(self, didFailToReceiveAdWithError: error)
        }
    }

    /// Called when the ad will be presented.
    @objc public override func callDelegate_willPresentAd() {
        if let delegate = self.delegate as? InterstitialAdUnitDelegate {
            delegate.interstitialWillPresentAd?(self)
        }
    }

    /// Called when the ad is dismissed.
    @objc public override func callDelegate_didDismissAd() {
        if let delegate = self.delegate as? InterstitialAdUnitDelegate {
            delegate.interstitialDidDismissAd?(self)
        }
    }

    /// Called when the user will leave the application.
    @objc public override func callDelegate_willLeaveApplication() {
        if let delegate = self.delegate as? InterstitialAdUnitDelegate {
            delegate.interstitialWillLeaveApplication?(self)
        }
    }

    /// Called when the ad is clicked.
    @objc public override func callDelegate_didClickAd() {
        if let delegate = self.delegate as? InterstitialAdUnitDelegate {
            delegate.interstitialDidClickAd?(self)
        }
    }
    
    /// Checks if the ad is ready to be displayed.
    @objc public override func callEventHandler_isReady() -> Bool {
        interstitialEventHandler?.isReady ?? false
    }
    
    /// Sets the loading delegate for the event handler.
    @objc public override func callEventHandler_setLoadingDelegate(_ loadingDelegate: NSObject?) {
        interstitialEventHandler?.loadingDelegate = loadingDelegate as? RewardedEventLoadingDelegate
    }

    /// Sets the interaction delegate for the event handler.
    @objc public override func callEventHandler_setInteractionDelegate() {
        interstitialEventHandler?.interactionDelegate = self
    }

    /// Requests an ad with the specified bid response
    @objc public override func callEventHandler_requestAd(with bidResponse: BidResponse?) {
        interstitialEventHandler?.requestAd(with: bidResponse)
    }

    /// Shows the ad from the specified view controller.
    @objc public override func callEventHandler_show(from controller: UIViewController?) {
        interstitialEventHandler?.show(from: controller)
    }

    /// Tracks an impression for the ad.
    @objc public override func callEventHandler_trackImpression() {
        interstitialEventHandler?.trackImpression?()
    }
    
    private var interstitialEventHandler: InterstitialEventHandlerProtocol?  {
        eventHandler as? InterstitialEventHandlerProtocol
    }
}
