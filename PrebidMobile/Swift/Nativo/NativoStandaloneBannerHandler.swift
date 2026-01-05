
import Foundation
import UIKit

public class NativoStandaloneBannerHandler: NSObject, BannerEventHandler {
    
    public weak var loadingDelegate: BannerEventLoadingDelegate?
    public weak var interactionDelegate: BannerEventInteractionDelegate?
    
    public var adSizes: [CGSize] = []
    
    public func requestAd(with bidResponse: BidResponse?) {
        loadingDelegate?.prebidDidWin()
    }
    
    // Compare Prebid vs Nativo and pick the higher price winning bid
    @objc(requestAdWithPrebidResponse:nativoResponse:)
    public func requestAd(withPrebidResponse prebidResponse: BidResponse?, nativoResponse: BidResponse?) {
        let prebidPrice = prebidResponse?.winningBid?.price ?? 0.0
        let nativoPrice = nativoResponse?.winningBid?.price ?? 0.0
        if nativoPrice >= prebidPrice {
            loadingDelegate?.nativoDidWin()
        } else {
            loadingDelegate?.prebidDidWin()
        }
    }
    
    public func trackImpression() {
        
    }
}
