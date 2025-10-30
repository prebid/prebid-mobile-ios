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

@objc(PBMBannerAdLoader)
@_spi(PBMInternal) public
class BannerAdLoader: NSObject, AdLoaderProtocol, DisplayViewLoadingDelegate, BannerEventLoadingDelegate {

    
    // MARK: - Properties

    weak var delegate: (BannerAdLoaderDelegate & DisplayViewInteractionDelegate)?
    weak public var flowDelegate: AdLoaderFlowDelegate?

    // MARK: - Init

    init(delegate: (BannerAdLoaderDelegate & DisplayViewInteractionDelegate)) {
        self.delegate = delegate
        super.init()
    }
        

    // MARK: - PBMAdLoaderProtocol

    public var primaryAdRequester: PrimaryAdRequesterProtocol? {
        guard let eventHandler = delegate?.eventHandler else {
            return nil
        }
        eventHandler.loadingDelegate = self
        return eventHandler
    }
    
    public func createPrebidAd(with bid: Bid,
                        adUnitConfig: AdUnitConfig,
                        adObjectSaver: @escaping (AnyObject) -> Void,
                        loadMethodInvoker: @escaping (@escaping VoidBlock) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            guard let displayView = self.createBannerView(with: bid, adUnitConfig: adUnitConfig) else {
                return
            }
            adObjectSaver(displayView)

            loadMethodInvoker {
                displayView.loadAd()
            }
        }
    }
    
    public func reportSuccess(with adObject: AnyObject, adSize: NSValue?) {
        if let size = adSize?.cgSizeValue,
           let view = adObject as? UIView & PrebidMobileDisplayViewProtocol {
            delegate?.bannerAdLoader(self, loadedAdView: view, adSize: size)
        }
    }


    // MARK: - DisplayViewLoadingDelegate
    
    public func displayViewDidLoadAd(_ displayView: UIView) {
        flowDelegate?.adLoaderLoadedPrebidAd(self)
    }
    
    public func displayView(_ displayView: UIView, didFailWithError error: any Error) {
        flowDelegate?.adLoader(self, failedWithPrebidError: error)
    }

    // MARK: - BannerEventLoadingDelegate

    public func prebidDidWin() {
        flowDelegate?.adLoaderDidWinPrebid(self)
    }

    public func adServerDidWin(_ view: UIView, adSize: CGSize) {
        flowDelegate?.adLoader(self, loadedPrimaryAd: view, adSize: NSValue(cgSize: adSize))
    }

    public func failedWithError(_ error: Error?) {
        flowDelegate?.adLoader(self, failedWithPrimarySDKError: error as NSError?)
    }

    // MARK: - Private

    private func createBannerView(with bid: Bid, adUnitConfig: AdUnitConfig) -> (UIView & PrebidMobileDisplayViewProtocol)? {
        guard let delegate else { return nil }
        
        
        let renderer = PrebidMobilePluginRegister.shared.getPluginForPreferredRenderer(bid: bid)
        Log.info("Renderer: \(String(describing: renderer))")

        let displayFrame = CGRect(origin: .zero, size: bid.size)

        if let view = renderer.createBannerView(with: displayFrame,
                                                bid: bid,
                                                adConfiguration: adUnitConfig,
                                                loadingDelegate: self,
                                                interactionDelegate: delegate) {
            return view
        }

        Log.warn("SDK couldn't retrieve an implementation of PrebidMobileDisplayViewManagerProtocol. Using fallback renderer.")
        let fallbackRenderer = PrebidMobilePluginRegister.shared.sdkRenderer
        return fallbackRenderer.createBannerView(with: displayFrame,
                                                 bid: bid,
                                                 adConfiguration: adUnitConfig,
                                                 loadingDelegate: self,
                                                 interactionDelegate: delegate)
    }
}
