
import UIKit

/**
 Nativo's custom Prebid renderer
 
 Ideally we want one single NativoPrebidRenderer that both NativoPrebidSDK and PrebidMobile can use.
 However since SPM doesn't allow overlapping source targets or conditional dependencies,
 we are forced to have two separate implementations in NativoPrebidRenderer and NativoPrebidRendererInternal.
 One internal to NativoPrebidSDK, and another external that depends on PrebidMobile.
 */
public class NativoPrebidRendererInternal: NSObject, PrebidMobilePluginRenderer, DisplayViewLoadingDelegate {

    public static let NAME = "NativoRenderer"
    public static let VERSION = "1.0.0"
    public let name = NativoPrebidRendererInternal.NAME
    public let version = NativoPrebidRendererInternal.VERSION
    public var data: [String: Any]?
    var bannerLoadingDelegate: DisplayViewLoadingDelegate?
    
    public func createBannerView(
        with frame: CGRect,
        bid: Bid,
        adConfiguration: AdUnitConfig,
        loadingDelegate: DisplayViewLoadingDelegate,
        interactionDelegate: DisplayViewInteractionDelegate
    ) -> (UIView & PrebidMobileDisplayViewProtocol)? {
        
        let displayView = DisplayView(
            frame: frame,
            bid: bid,
            adConfiguration: adConfiguration
        )
        
        self.bannerLoadingDelegate = loadingDelegate
        displayView.interactionDelegate = interactionDelegate
        displayView.loadingDelegate = self
        
        // Cache debug mraid.js
//        let jsLibManager = PrebidJSLibraryManager.shared
//        PrebidJSLibraryManager.shared.saveLibrary(with: jsLibManager.mraidLibrary.name, contents: mraidDebugScript)
        
        return displayView
    }
    
    public func createInterstitialController(
        bid: Bid,
        adConfiguration: AdUnitConfig,
        loadingDelegate: InterstitialControllerLoadingDelegate,
        interactionDelegate: InterstitialControllerInteractionDelegate
    ) -> PrebidMobileInterstitialControllerProtocol? {
        let interstitialController = InterstitialController(
            bid: bid,
            adConfiguration: adConfiguration
        )
        
        interstitialController.loadingDelegate = loadingDelegate
        interstitialController.interactionDelegate = interactionDelegate
        
        return interstitialController
    }
    
    
    // MARK: - DisplayViewLoadingDelegate
    
    public func displayViewDidLoadAd(_ displayView: UIView) {
        self.bannerLoadingDelegate?.displayViewDidLoadAd(displayView)
        
        // Cast to DisplayView to extract the bid
        guard let prebidDisplayView = displayView as? DisplayView else {
            Log.debug("displayView is not of type DisplayView", filename: #file, line: #line, function: #function)
            return
        }
        
        // Differenciate between Nativo ad rendering or a standard banner ad
        let bid = prebidDisplayView.bid
        let adm = bid.adm ?? ""
        let isNativoRendering = adm.range(of: "load.js", options: .caseInsensitive) != nil
        
        if (isNativoRendering) {
            expandFullWidth(displayView)
        }
    }
    
    public func displayView(_ displayView: UIView, didFailWithError error: any Error) {
        self.bannerLoadingDelegate?.displayView(displayView, didFailWithError: error)
    }
    
    // MARK: - Private functions
    
    private func expandFullWidth(_ view: UIView) {
        // TODO: PR to Prebid for new delegate callback to PluginRenderer for after view gets injected
        // Forced to briefly wait for Prebid's AdViewManager to finish before PBMWebView gets injected
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.milliseconds(200)) {
            if let parentView = view.superview {
                // Remove any constraints we don't need
                let parentContraints = parentView.constraints
                let widthConstraints = parentContraints.filter({ constraint in
                    (constraint.firstItem as? UIView) === parentView && constraint.firstAttribute == .width
                    || (constraint.secondItem as? UIView) === parentView && constraint.secondAttribute == .width
                })
                let heightConstraints = parentContraints.filter({ constraint in
                    (constraint.firstItem as? UIView) === parentView && constraint.firstAttribute == .height
                    || (constraint.secondItem as? UIView) === parentView && constraint.secondAttribute == .height
                })
                NSLayoutConstraint.deactivate(widthConstraints + heightConstraints)
                
                // Allow displayView to expand to the full width of its parent
                if let grandParentView = parentView.superview {
                    parentView.widthAnchor.constraint(equalTo: grandParentView.widthAnchor).isActive = true
                    parentView.heightAnchor.constraint(equalTo: grandParentView.heightAnchor).isActive = true
                }
                let displayWidth = view.widthAnchor.constraint(equalTo: parentView.widthAnchor)
                let displayHeight = view.heightAnchor.constraint(equalTo: parentView.heightAnchor)
                let displayCenterX = view.centerXAnchor.constraint(equalTo:parentView.centerXAnchor)
                let displayCenterY = view.centerYAnchor.constraint(equalTo: parentView.centerYAnchor)
                displayCenterX.priority = .defaultHigh
                displayCenterY.priority = .defaultHigh
                NSLayoutConstraint.activate([
                    displayWidth,
                    displayHeight,
                    displayCenterX,
                    displayCenterY
                ])
            }
            
            // Allow the inner web view to expand to the full width of its parent
            if let pbmWebView = view.subviews.first {
                NSLayoutConstraint.activate([
                    pbmWebView.widthAnchor.constraint(equalTo: view.widthAnchor),
                    pbmWebView.heightAnchor.constraint(equalTo: view.heightAnchor)
                ])
            } else {
                let error = NSError(
                    domain: "NativoPrebidRenderer",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Nativo renderer expected a subview on DisplayView, but none was found."]
                )
                print("\(error)")
            }
        }
    }
}
