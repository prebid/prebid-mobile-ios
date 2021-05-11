//
//  GAMInterstitialEventHandler.swift
//  PrebidMobileGAMEventHandlers
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import GoogleMobileAds
import PrebidMobileRendering

public class GAMInterstitialEventHandler :
    NSObject,
    PBMInterstitialEventHandler,
    GADFullScreenContentDelegate,
    GADAppEventDelegate {
    
    // MARK: - Internal Properties
    
    var requestInterstitial:    GAMInterstitialAdWrapper?
    var proxyInterstitial:      GAMInterstitialAdWrapper?
    var embeddedInterstitial:   GAMInterstitialAdWrapper?
   
    var adSizes = [CGSize]()
    var isExpectingAppEvent = false
    
    var appEventTimer: Timer?
    
    // MARK: - Public Properties
    
    public let adUnitID: String
    
    // MARK: - Public Methods

    public init(adUnitID: String) {
        self.adUnitID = adUnitID
    }
    
    // MARK: - PBMInterstitialAd
    
    public var loadingDelegate: PBMInterstitialEventLoadingDelegate?
    
    public var interactionDelegate: PBMInterstitialEventInteractionDelegate?
    
    public var isReady: Bool {
        if let _ = requestInterstitial {
            return false
        }
        
        guard let _ = embeddedInterstitial ?? proxyInterstitial else {
            return false
        }
        
        return true
    }
            
    public func show(from controller: UIViewController?) {
        if let controller = controller,
           let interstitial = embeddedInterstitial {
            interstitial.present(from: controller)
        }
    }
    
    public func requestAd(with bidResponse: PBMBidResponse?) {
        guard let currentInterstitialAd = GAMInterstitialAdWrapper(adUnitID: adUnitID),
              let request = GAMRequestWrapper() else {
            let error = GAMEventHandlerError.gamClassesNotFound
            GAMUtils.log(error: error)
            loadingDelegate?.failedWithError(error)
            return
        }
        
        guard let _ = requestInterstitial,
              let _ = proxyInterstitial else {
            return;
        }

        requestInterstitial = currentInterstitialAd
            
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
        
        currentInterstitialAd.fullScreenContentDelegate = self
        currentInterstitialAd.appEventDelegate = self
        
        currentInterstitialAd.load(request: request, completion:{ [weak self] ad, error in
            if let error = error {
                self?.interstitial(didFailToReceive: ad, error: error)
                return
            }
            
            self?.interstitial(didReceive: ad)
        })
    }
    
    // MARK: - GADAppEventDelegate
    
    func interstitial(didReceive ad: GAMInterstitialAdWrapper) {
        if requestInterstitial === ad {
            primaryAdReceived()
        }
    }

    func interstitial(didFailToReceive ad:GAMInterstitialAdWrapper,
                                error: Error)
    {
        if requestInterstitial === ad {
            requestInterstitial = nil
            forgetCurrentInterstitial()
            loadingDelegate?.failedWithError(error)
        }
    }

    
    public func interstitialAd(_ interstitialAd: GADInterstitialAd,
                               didReceiveAppEvent name: String,
                               withInfo info: String?) {
        if requestInterstitial?.interstitialAd === interstitialAd &&
            name == Constants.appEventValue {
            appEventDetected()
        }
    }
    
    func appEventDetected() {
        if let interstitial = requestInterstitial, isExpectingAppEvent {
            if let _ = appEventTimer {
                appEventTimer?.invalidate()
                appEventTimer = nil
            }
            
            isExpectingAppEvent = false
            forgetCurrentInterstitial()
            
            proxyInterstitial = interstitial
            
            loadingDelegate?.prebidDidWin()
        }
        
        requestInterstitial = nil
    }
    
    func forgetCurrentInterstitial() {
        embeddedInterstitial = nil
        proxyInterstitial = nil
    }
    
    func primaryAdReceived() {
        if isExpectingAppEvent {
            if let _ = appEventTimer {
                return
            }
            
            requestInterstitial?.appEventDelegate = self
            
            appEventTimer = Timer.scheduledTimer(timeInterval: Constants.appEventTimeout,
                                                 target: self,
                                                 selector: #selector(appEventTimedOut),
                                                 userInfo: nil,
                                                 repeats: false)
        } else {
            let interstitial = requestInterstitial
            requestInterstitial = nil
            
            forgetCurrentInterstitial()
            embeddedInterstitial = interstitial
            
            loadingDelegate?.adServerDidWin()
        }
    }
    
    @objc func appEventTimedOut() {
        let interstitial = requestInterstitial
        requestInterstitial = nil
        
        forgetCurrentInterstitial()
        embeddedInterstitial = interstitial
        
        isExpectingAppEvent = false
        
        appEventTimer = nil
        
        loadingDelegate?.adServerDidWin()
    }
}
