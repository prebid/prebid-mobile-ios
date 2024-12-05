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
public class GAMRewardedAdEventHandler :
    NSObject,
    RewardedEventHandlerProtocol,
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
    
    // MARK: - RewardedEventHandlerProtocol
    
    // This is  a very dirty hack based on dynamic properties of Objc Object.
    // Need to rewrite Interstitial ad loader to swift and find out how to pass the reward
    public weak var loadingDelegate: InterstitialEventLoadingDelegate?
    public weak var interactionDelegate: RewardedEventInteractionDelegate?
    
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
            interactionDelegate?.userDidEarnReward(rewarded?.reward?.toPrebidReward())
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
        appEventTimer = nil
        
        interactionDelegate?.userDidEarnReward(rewarded?.reward?.toPrebidReward())
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
            
            loadingDelegate?.prebidDidWin()
        }
    }
}
