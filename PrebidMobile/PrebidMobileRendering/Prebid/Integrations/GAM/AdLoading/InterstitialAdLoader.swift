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

@objc(PBMInterstitialAdLoader)
@objcMembers
final class InterstitialAdLoader: NSObject, AdLoaderProtocol, InterstitialControllerLoadingDelegate, InterstitialEventLoadingDelegate {
    
    weak var delegate: (InterstitialAdLoaderDelegate & InterstitialControllerInteractionDelegate)?
    let eventHandler: PrimaryAdRequesterProtocol
    
    weak var flowDelegate: AdLoaderFlowDelegate?
    
    // MARK: - Initializer
    
    init(delegate: (InterstitialAdLoaderDelegate & InterstitialControllerInteractionDelegate),
         eventHandler: PrimaryAdRequesterProtocol) {
        self.delegate = delegate
        self.eventHandler = eventHandler
        super.init()
    }
    
    var primaryAdRequester: PrimaryAdRequesterProtocol {
        eventHandler
    }
    
    func createPrebidAd(with bid: Bid,
                        adUnitConfig: AdUnitConfig,
                        adObjectSaver: @escaping (Any) -> Void,
                        loadMethodInvoker: @escaping (@escaping () -> Void) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            guard let controller = self.createController(with: bid, adUnitConfig: adUnitConfig) else {
                return
            }
            adObjectSaver(controller)
            
            loadMethodInvoker {
                controller.loadAd()
            }
        }
    }
    
    func reportSuccess(with adObject: Any, adSize: NSValue?) {
        if let controller = adObject as? PrebidMobileInterstitialControllerProtocol {
            delegate?.interstitialAdLoader(self,
                                           loadedAd: { _ in controller.show() },
                                           isReadyBlock: { true })
        } else if let eventHandler = adObject as? InterstitialAd {
            delegate?.interstitialAdLoader(self,
                                           loadedAd: { vc in eventHandler.show(from: vc) },
                                           isReadyBlock: { eventHandler.isReady })
        } else {
            delegate?.interstitialAdLoader(self,
                                           loadedAd: { _ in },
                                           isReadyBlock: { false })
        }
    }
    
    // MARK: - InterstitialControllerLoadingDelegate
    
    func interstitialControllerDidLoadAd(_ interstitialController: PrebidMobileInterstitialControllerProtocol) {
        flowDelegate?.adLoaderLoadedPrebidAd(self)
    }
    
    func interstitialController(_ interstitialController: PrebidMobileInterstitialControllerProtocol,
                                didFailWithError error: Error) {
        flowDelegate?.adLoader(self, failedWithPrebidError: error as NSError)
    }
    
    // MARK: - InterstitialEventLoadingDelegate
    
    func prebidDidWin() {
        flowDelegate?.adLoaderDidWinPrebid(self)
    }
    
    func adServerDidWin() {
        flowDelegate?.adLoader(self, loadedPrimaryAd: eventHandler, adSize: nil)
    }
    
    func failed(with error: Error?) {
        flowDelegate?.adLoader(self, failedWithPrimarySDKError: error as NSError?)
    }
    
    // MARK: - Helpers
    
    private func createController(with bid: Bid, adUnitConfig: AdUnitConfig) -> PrebidMobileInterstitialControllerProtocol? {
        guard let delegate else { return nil }

        
        let renderer = PrebidMobilePluginRegister.shared.getPluginForPreferredRenderer(bid: bid)
        Log.info("Renderer: \(renderer)")
        
        if let controller = renderer.createInterstitialController(bid: bid,
                                                                  adConfiguration: adUnitConfig,
                                                                  loadingDelegate: self,
                                                                  interactionDelegate: delegate) {
            return controller
        }
                
        Log.warn("SDK couldn't retrieve an implementation of PrebidMobileInterstitialControllerProtocol. SDK will use the PrebidMobile SDK renderer.")
        
        let sdkRenderer = PrebidMobilePluginRegister.shared.sdkRenderer
        return sdkRenderer.createInterstitialController(bid: bid,
                                                        adConfiguration: adUnitConfig,
                                                        loadingDelegate: self,
                                                        interactionDelegate: delegate)
    }
}
