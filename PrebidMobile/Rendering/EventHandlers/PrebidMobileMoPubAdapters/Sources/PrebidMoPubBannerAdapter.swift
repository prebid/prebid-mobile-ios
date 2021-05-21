//
//  PrebidMoPubBannerAdapter.swift
//  PrebidMobileMoPubAdapters
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

import MoPubSDK

import PrebidMobileRendering

/**
 Note: Prebid SDK passes to the localExtras two objects: Bid, configId
 */

@objc(PrebidMoPubBannerAdapter)
public class PrebidMoPubBannerAdapter :
    MPInlineAdAdapter,
    PBMDisplayViewLoadingDelegate,
    PBMDisplayViewInteractionDelegate {
   
    // MARK: - Internal Properties
    
    var configID: String?
    var displayView: PBMDisplayView?
    
    // MARK: - MPInlineAdAdapter
    
    public override func requestAd(with size: CGSize,
                                   adapterInfo info: [AnyHashable : Any],
                                   adMarkup: String?) {
        guard !localExtras.isEmpty else {
            let error = MoPubAdaptersError.emptyLocalExtras
            MPLogging.logEvent(MPLogEvent.adLoadFailed(forAdapter: Self.className(), error: error), source: adUnitId, from: nil)
            delegate?.inlineAdAdapter(self, didFailToLoadAdWithError: error)
            return
        }
        
        guard let bid = localExtras[PBMMoPubAdUnitBidKey] as? PBMBid else {
            let error = MoPubAdaptersError.noBidInLocalExtras
            MPLogging.logEvent(MPLogEvent.adLoadFailed(forAdapter: Self.className(), error: error), source: adUnitId, from: nil)
            delegate?.inlineAdAdapter(self, didFailToLoadAdWithError: error)
            return
        }
        
        guard let configID = localExtras[PBMMoPubConfigIdKey] as? String else {
            let error = MoPubAdaptersError.noConfigIDInLocalExtras
            MPLogging.logEvent(MPLogEvent.adLoadFailed(forAdapter: Self.className(), error: error), source: adUnitId, from: nil)
            delegate?.inlineAdAdapter(self, didFailToLoadAdWithError: error)
            return
        }
        
        let frame = CGRect(origin: .zero, size: bid.size)
        displayView = PBMDisplayView(frame: frame,
                                     bid: bid,
                                     configId: configID)
        
        displayView?.loadingDelegate = self
        displayView?.interactionDelegate = self
        
        displayView?.displayAd()
        
        MPLogging.logEvent(MPLogEvent.adLoadAttempt(forAdapter: Self.className(), dspCreativeId: nil, dspName: nil), source: adUnitId, from: nil)
    }
    
    // MARK: - PBMDisplayViewLoadingDelegate
    
    public func displayViewDidLoadAd(_ displayView: PBMDisplayView) {
        MPLogging.logEvent(MPLogEvent.adLoadSuccess(forAdapter: Self.className()), source: adUnitId, from: nil)
        delegate?.inlineAdAdapter(self, didLoadAdWithAdView: self.displayView)
    }
    
    // MARK: - PBMDisplayViewInteractionDelegate
    
    public func displayView(_ displayView: PBMDisplayView, didFailWithError error: Error) {
        MPLogging.logEvent(MPLogEvent.adLoadFailed(forAdapter: Self.className(), error: error), source: adUnitId, from: nil)
        delegate?.inlineAdAdapter(self, didFailToLoadAdWithError: error)
    }
    
    public func trackImpression(for displayView: PBMDisplayView) {
        //Impressions will be tracked automatically
        //unless enableAutomaticImpressionAndClickTracking = NO
        //In this case you have to override the didDisplayAd method
        //and manually call inlineAdAdapterDidTrackImpression
        //in this method to ensure correct metrics
    }
    
    public func viewControllerForModalPresentation(from displayView: PBMDisplayView) -> UIViewController {
        if let controller = delegate?.inlineAdAdapterViewController(forPresentingModalView: self) {
            return controller
        }
        
        // FIXME
        return UIViewController()
    }
    
    public func didLeaveApp(from displayView: PBMDisplayView) {
        // There is no appropriate methods
    }
    
    public func displayViewWillPresentModal(_ displayView: PBMDisplayView) {
        MPLogging.logEvent(MPLogEvent.adTapped(forAdapter: Self.className()), source: adUnitId, from: nil)
        delegate?.inlineAdAdapterWillBeginUserAction(self)
    }
    
    public func displayViewDidDismissModal(_ displayView: PBMDisplayView) {
        MPLogging.logEvent(MPLogEvent.adDidDismissModal(forAdapter: Self.className()), source: adUnitId, from: nil)
        delegate?.inlineAdAdapterDidEndUserAction(self)
    }
}
