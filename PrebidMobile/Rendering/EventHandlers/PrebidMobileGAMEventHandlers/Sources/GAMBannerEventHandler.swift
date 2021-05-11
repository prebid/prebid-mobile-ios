//
//  GAMBannerEventHandler.swift
//  PrebidMobileGAMEventHandlers
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import GoogleMobileAds
import PrebidMobileRendering

public class GAMBannerEventHandler :
    NSObject,
    PBMBannerEventHandler,
    GADBannerViewDelegate,
    GADAppEventDelegate,
    GADAdSizeDelegate
{
    // MARK: - Internal Properties
    
    var requestBanner   : GAMBannerViewWrapper?
    var proxyBanner     : GAMBannerViewWrapper?
    var embeddedBanner  : GAMBannerViewWrapper?
    
    var validAdSizes: [NSValue]
    
    var isExpectingAppEvent = false;
    var appEventTimer: Timer?
    
    var lastGADSize: CGSize?
    
    let adUnitID: String
    
    // MARK: - Public Methods
    
    public init(adUnitID: String, validGADAdSizes: [NSValue]) {
        self.adUnitID = adUnitID
        self.adSizes = GAMBannerEventHandler.convertGADSizes(validGADAdSizes)
        
        validAdSizes = validGADAdSizes
    }
    
    // MARK: - PBMBannerEventHandler
    
    public var loadingDelegate: PBMBannerEventLoadingDelegate?
    
    public var interactionDelegate: PBMBannerEventInteractionDelegate?
    
    public var adSizes: [NSValue]
    
    public var isCreativeRequiredForNativeAds: Bool {
        false
    }
    
    public func requestAd(with bidResponse: PBMBidResponse?) {
       
        guard let bannerViewWrapper = GAMBannerViewWrapper(),
              let request = GAMRequestWrapper() else {
            
            let error = GAMEventHandlerError.gamClassesNotFound
            GAMUtils.log(error: error)
            loadingDelegate?.failedWithError(error)
            return
        }
        
        if let _ = requestBanner {
            // request to primaryAdServer in progress
            return;
        }
        
        requestBanner = bannerViewWrapper
        requestBanner?.adUnitID = adUnitID
        requestBanner?.validAdSizes = validAdSizes
        requestBanner?.rootViewController = interactionDelegate?.viewControllerForPresentingModal
        
        if let bidResponse = bidResponse {
            isExpectingAppEvent = bidResponse.winningBid != nil
            
            var targeting = [String : String]()
              
            if let requestTargeting = request.customTargeting {
                targeting.merge(requestTargeting) { $1 }
            }
            
            if let responseTargeting = bidResponse.targetingInfo {
                targeting.merge(responseTargeting) { $1 }
            }
            
            if !targeting.isEmpty {
                request.customTargeting = targeting
            }
        }
        
        requestBanner?.delegate = self
        requestBanner?.appEventDelegate = self
        requestBanner?.adSizeDelegate = self
        requestBanner?.enableManualImpressions = true
        
        lastGADSize = nil;
        
        requestBanner?.load(request)
    }
    
    // MARK: - GADBannerViewDelegate
    
    public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        if requestBanner?.banner == bannerView {
            primaryAdReceived()
        }
    }
    
    public func bannerView(_ bannerView: GADBannerView,
                    didFailToReceiveAdWithError error: Error) {
        if requestBanner?.banner == bannerView {
            requestBanner = nil
            recycleCurrentBanner()
            loadingDelegate?.failedWithError(error)
        }
    }
    
    public func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        // TODO
    }
    
    public func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        interactionDelegate?.willPresentModal()
    }
    
    public func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        // TODO
    }
    
    public func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        interactionDelegate?.didDismissModal()
    }
    
    // MARK: - GADAppEventDelegate
    
    public func adView(_ banner: GADBannerView,
                didReceiveAppEvent name: String, withInfo info: String?) {
        if requestBanner?.banner == banner && name == Constants.appEventValue {
            appEventDetected()
        }
    }
    
    public func interstitialAd(_ interstitialAd: GADInterstitialAd,
                               didReceiveAppEvent name: String,
                               withInfo info: String?) {
        // TODO
    }
    
    // MARK: - GADAdSizeDelegate
    
    public func adView(_ bannerView: GADBannerView,
                       willChangeAdSizeTo size: GADAdSize) {
        lastGADSize = size.size
    }
    
    // MARK: - Private Helpers
    
    var dfpAdSize: CGSize? {
        if let lastSize = lastGADSize {
            return lastSize
        } else if let banner = requestBanner {
            return banner.adSize.size
        }
        
        return nil
    }

    func primaryAdReceived() {
        if isExpectingAppEvent {
            if let _ = appEventTimer {
                return
            }
            
            appEventTimer = Timer.scheduledTimer(timeInterval: Constants.appEventTimeout,
                                                 target: self,
                                                 selector: #selector(appEventTimedOut),
                                                 userInfo: nil,
                                                 repeats: false)
        } else {
            let banner = requestBanner
            requestBanner = nil
            
            recycleCurrentBanner()
            embeddedBanner = banner
            
            if  let banner = banner,
                let adSize = dfpAdSize {
                loadingDelegate?.adServerDidWin(banner.banner, adSize: adSize)
            }
        }
    }
    
    func appEventDetected() {
        let banner = requestBanner
        requestBanner = nil
        if isExpectingAppEvent {
            if let _ = appEventTimer {
                appEventTimer?.invalidate()
                appEventTimer = nil
            }
            
            isExpectingAppEvent = false
            recycleCurrentBanner()
            
            proxyBanner = banner
            
            loadingDelegate?.prebidDidWin()
        }
    }
    
    @objc func appEventTimedOut() {
        let banner = requestBanner
        requestBanner = nil
        
        recycleCurrentBanner()
        
        embeddedBanner = banner
        
        isExpectingAppEvent = false
        appEventTimer = nil
        
        if  let banner = banner,
            let adSize = dfpAdSize {
            loadingDelegate?.adServerDidWin(banner.banner, adSize: adSize)
        }
    }
    
    func recycleCurrentBanner() {
        embeddedBanner = nil
        proxyBanner = nil
    }
    
    class func convertGADSizes(_ inSizes: [NSValue]) -> [NSValue] {
        inSizes.map {
            CGSizeFromGADAdSize(GADAdSizeFromNSValue( $0 )) as NSValue
        }
    }
    
}


