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
import GoogleMobileAds
import PrebidMobile

@objcMembers
public class GAMBannerEventHandler :
    NSObject,
    BannerEventHandler,
    GoogleMobileAds.BannerViewDelegate,
    GoogleMobileAds.AppEventDelegate,
    GoogleMobileAds.AdSizeDelegate {
    
    // MARK: - Internal Properties
    
    var requestBanner   : GAMBannerViewWrapper?
    var proxyBanner     : GAMBannerViewWrapper?
    var embeddedBanner  : GAMBannerViewWrapper?
    
    var validAdSizes: [NSValue]
    
    var isExpectingAppEvent = false
    var appEventTimer: Timer?
    
    var lastGADSize: CGSize?
    
    let adUnitID: String
    
    // MARK: - Public Methods
    
    public init(adUnitID: String, validGADAdSizes: [NSValue]) {
        self.adUnitID = adUnitID
        self.adSizes = GAMBannerEventHandler.convertGADSizes(validGADAdSizes)
        
        validAdSizes = validGADAdSizes
    }
    
    // MARK: - BannerEventHandler
    
    public weak var loadingDelegate: BannerEventLoadingDelegate?
    
    public weak var interactionDelegate: BannerEventInteractionDelegate?
    
    public var adSizes: [CGSize]
    
    public func trackImpression() {
        proxyBanner?.recordImpression()
    }
    
    public func requestAd(with bidResponse: BidResponse?) {
        guard let bannerViewWrapper = GAMBannerViewWrapper(),
              let request = GAMRequestWrapper() else {
            let error = GAMEventHandlerError.gamClassesNotFound
            GAMUtils.log(error: error)
            loadingDelegate?.failedWithError(error)
            return
        }
        
        if let _ = requestBanner {
            // request to primaryAdServer in progress
            return
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
        
        lastGADSize = nil
        
        requestBanner?.load(request)
    }
    
    // MARK: - GADBannerViewDelegate
    
    public func bannerViewDidReceiveAd(_ bannerView: GoogleMobileAds.BannerView) {
        if requestBanner?.banner === bannerView {
            primaryAdReceived()
        }
    }
    
    public func bannerView(
        _ bannerView: GoogleMobileAds.BannerView,
        didFailToReceiveAdWithError error: Error
    ) {
        if requestBanner?.banner == bannerView {
            requestBanner = nil
            recycleCurrentBanner()
            loadingDelegate?.failedWithError(error)
        }
    }
    
    public func bannerViewDidRecordImpression(_ bannerView: GoogleMobileAds.BannerView) {
        // TODO
    }
    
    public func bannerViewWillPresentScreen(_ bannerView: GoogleMobileAds.BannerView) {
        interactionDelegate?.willPresentModal()
    }
    
    public func bannerViewWillDismissScreen(_ bannerView: GoogleMobileAds.BannerView) {
        // TODO
    }
    
    public func bannerViewDidDismissScreen(_ bannerView: GoogleMobileAds.BannerView) {
        interactionDelegate?.didDismissModal()
    }
    
    // MARK: - GADAppEventDelegate
    
    public func adView(
        _ banner: GoogleMobileAds.BannerView,
        didReceiveAppEvent name: String,
        with info: String?
    ) {
        if requestBanner?.banner == banner && name == Constants.appEventValue {
            appEventDetected()
        }
    }
    
    public func adView(
        _ interstitialAd: GoogleMobileAds.InterstitialAd,
        didReceiveAppEvent name: String,
        with info: String?
    ) {
        // TODO
    }
    
    // MARK: - GADAdSizeDelegate
    
    public func adView(
        _ bannerView: GoogleMobileAds.BannerView,
        willChangeAdSizeTo size: GoogleMobileAds.AdSize
    ) {
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
            
            appEventTimer = Timer.scheduledTimer(
                timeInterval: Constants.appEventTimeout,
                target: self,
                selector: #selector(appEventTimedOut),
                userInfo: nil,
                repeats: false
            )
        } else {
            let banner = requestBanner
            requestBanner = nil
            
            recycleCurrentBanner()
            embeddedBanner = banner
            
            if let banner = banner,
               let adSize = dfpAdSize {
                setSizeConstraints(banner.banner, forAdSize: adSize)
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
        
        if let banner = banner,
           let adSize = dfpAdSize {
            setSizeConstraints(banner.banner, forAdSize: adSize)
            loadingDelegate?.adServerDidWin(banner.banner, adSize: adSize)
        }
    }
    
    func setSizeConstraints(_ banner: GoogleMobileAds.BannerView, forAdSize adSize: CGSize) {
        // Ad will not render without correct constraints.
        banner.widthAnchor.constraint(equalToConstant: adSize.width).isActive = true
        banner.heightAnchor.constraint(equalToConstant: adSize.height).isActive = true
    }
    
    func recycleCurrentBanner() {
        embeddedBanner = nil
        proxyBanner = nil
    }
    
    class func convertGADSizes(_ inSizes: [NSValue]) -> [CGSize] {
        inSizes.map { cgSize(for: GoogleMobileAds.adSizeFor(nsValue: $0)) }
    }
    
}
