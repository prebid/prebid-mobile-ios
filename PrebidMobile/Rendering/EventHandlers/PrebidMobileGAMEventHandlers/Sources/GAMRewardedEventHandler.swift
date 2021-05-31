//
//  GAMRewardedEventHandler.swift
//  PrebidMobileGAMEventHandlers
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import GoogleMobileAds
import PrebidMobileRendering

public class GAMRewardedAdEventHandler :
    NSObject,
    PBMRewardedEventHandler,
    GADFullScreenContentDelegate,
    GADAdMetadataDelegate {
    
    // MARK: - Internal Properties
    
    var requestRewarded : GADRewardedAdWrapper?
    var proxyRewarded   : GADRewardedAdWrapper?
    var embeddedRewarded: GADRewardedAdWrapper?
    
    var isExpectingAppEvent = false
    
    var appEventTimer: Timer?
    
    // MARK: - Public Properties
    
    public let adUnitID: String

    // MARK: - Public Methods
    
    public init(adUnitID: String) {
        self.adUnitID = adUnitID
    }
    
    // MARK: - GADAdMetadataDelegate
    
    public func adMetadataDidChange(_ ad: GADAdMetadataProvider) {
        let metadata = ad.adMetadata?[GADAdMetadataKey(rawValue: "AdTitle")] as? String
        if requestRewarded?.rewardedAd === ad && metadata == Constants.appEventValue {
            appEventDetected()
        }
    }
    
    // MARK: - PBMRewardedEventHandler
    
    public var loadingDelegate: PBMRewardedEventLoadingDelegate?
    
    public var interactionDelegate: PBMRewardedEventInteractionDelegate?
    
    // MARK: - Public Methods
    
    public var isReady: Bool {
        if requestRewarded != nil {
            return false
        }
        
        if let _ = embeddedRewarded ?? proxyRewarded {
            return true
        }
        
        return false
    }
    
    public func show(from controller: UIViewController?) {
        if let ad = embeddedRewarded,
           let controller = controller {
            ad.present(from: controller, userDidEarnRewardHandler: {
                // Do nothing
            } )
        }
    }
    
    public func requestAd(with bidResponse: BidResponse?) {
        guard let currentRequestRewarded = GADRewardedAdWrapper(adUnitID: adUnitID),
              let request = GAMRequestWrapper() else {
            let error = GAMEventHandlerError.gamClassesNotFound
            GAMUtils.log(error: error)
            loadingDelegate?.failedWithError(error)
            return
        }

        if let _ = requestRewarded {
            // request to primaryAdServer in progress
            return;
        }
        
        if proxyRewarded != nil || embeddedRewarded != nil {
            // rewarded already loaded
            return;
        }
        
        requestRewarded = currentRequestRewarded
        
        if let bidResponse = bidResponse {
            isExpectingAppEvent = (bidResponse.winningBid != nil)
            
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
                        
            currentRequestRewarded.load(request: request) { [weak self] (prebidGADRewardedAd, error) in
                if let error = error {
                    self?.rewardedAdDidFail(currentRequestRewarded, error: error)
                }
                
                if let ad = prebidGADRewardedAd {
                    self?.requestRewarded?.adMetadataDelegate = self
                    self?.rewardedAd(didReceive: ad)
                }
            }
        }
    }
    
    // MARK: - PBMGADRewardedAd loading callbacks

    func rewardedAd(didReceive ad: GADRewardedAdWrapper) {
        if requestRewarded === ad {
            primaryAdReceived()
        }
    }
    
    func rewardedAdDidFail(_ ad: GADRewardedAdWrapper, error: Error) {
        if requestRewarded === ad {
            requestRewarded = nil
            forgetCurrentRewarded()
            loadingDelegate?.failedWithError(error)
        }
    }
    
    func primaryAdReceived() {
        if isExpectingAppEvent {
            if appEventTimer != nil {
                return
            }
            
            appEventTimer = Timer.scheduledTimer(timeInterval: Constants.appEventTimeout,
                                                 target: self,
                                                 selector: #selector(appEventTimedOut),
                                                 userInfo: nil,
                                                 repeats: false)
        } else {
            let rewarded = requestRewarded
            requestRewarded = nil
            forgetCurrentRewarded()
            
            embeddedRewarded = rewarded
            loadingDelegate?.reward = rewarded?.reward
            loadingDelegate?.adServerDidWin()
        }
    }
    
    func forgetCurrentRewarded() {
        if embeddedRewarded != nil {
            embeddedRewarded = nil;
        } else if proxyRewarded != nil {
            proxyRewarded = nil;
        }
    }
    
    @objc func appEventTimedOut() {
        let rewarded = requestRewarded
        requestRewarded = nil
        forgetCurrentRewarded()
        
        embeddedRewarded = rewarded
        isExpectingAppEvent = false
        appEventTimer?.invalidate()
        appEventTimer = nil;
        
        loadingDelegate?.reward = rewarded?.reward
        loadingDelegate?.adServerDidWin()
    }
    
    func appEventDetected() {
        let rewarded = requestRewarded
        requestRewarded = nil
        
        if isExpectingAppEvent {
            if let _ = appEventTimer {
                appEventTimer?.invalidate()
                appEventTimer = nil
            }
            
            isExpectingAppEvent = false
            
            forgetCurrentRewarded()
            proxyRewarded = rewarded
            
            loadingDelegate?.reward = rewarded?.reward
            loadingDelegate?.prebidDidWin()
        }
    }
}
