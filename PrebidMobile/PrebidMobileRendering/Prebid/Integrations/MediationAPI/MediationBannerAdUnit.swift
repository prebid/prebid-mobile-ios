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
import UIKit

@objcMembers
public class MediationBannerAdUnit : NSObject {
    
    var bidRequester: PBMBidRequester?
    // The view in which ad is displayed
    weak var adView: UIView?
    var completion: ((ResultCode) -> Void)?
    
    weak var lastAdView: UIView?
    var lastCompletion: ((ResultCode) -> Void)?
    
    var isRefreshStopped = false
    var autoRefreshManager: PBMAutoRefreshManager?
    
    var adRequestError: Error?
    
    var adUnitConfig: AdUnitConfig
    
    public let mediationDelegate: PrebidMediationDelegate
    
    // MARK: - Computed properties
    
    public var configID: String {
        adUnitConfig.configId
    }
    
    public var adFormat: AdFormat {
        get { adUnitConfig.adFormats.first ?? .display }
        set { adUnitConfig.adFormats = [newValue] }
    }
    
    public var adPosition: AdPosition {
        get { adUnitConfig.adPosition }
        set { adUnitConfig.adPosition = newValue }
    }
    
    public var bannerParameters: BannerParameters {
        get { adUnitConfig.adConfiguration.bannerParameters }
    }
    
    public var videoParameters: VideoParameters {
        get { adUnitConfig.adConfiguration.videoParameters }
    }
    
    public var refreshInterval: TimeInterval {
        get { adUnitConfig.refreshInterval }
        set { adUnitConfig.refreshInterval = newValue }
    }
    
    public var additionalSizes: [CGSize]? {
        get { adUnitConfig.additionalSizes }
        set { adUnitConfig.additionalSizes = newValue }
    }
    
    // MARK: - Context Data
    
    public func addContextData(_ data: String, forKey key: String) {
        adUnitConfig.addContextData(key: key, value: data)
    }
    
    public func updateContextData(_ data: Set<String>, forKey key: String) {
        adUnitConfig.updateContextData(key: key, value: data)
    }
    
    public func removeContextDate(forKey key: String) {
        adUnitConfig.removeContextData(for: key)
    }
    
    public func clearContextData() {
        adUnitConfig.clearContextData()
    }
    
    // MARK: - App Content
    
    public func setAppContent(_ appContent: PBMORTBAppContent) {
        adUnitConfig.setAppContent(appContent)
    }
    
    public func clearAppContent() {
        adUnitConfig.clearAppContent()
    }
    
    public func addAppContentData(_ dataObjects: [PBMORTBContentData]) {
        adUnitConfig.addAppContentData(dataObjects)
    }
    
    public func removeAppContentDataObject(_ dataObject: PBMORTBContentData) {
        adUnitConfig.removeAppContentData(dataObject)
    }
    
    public func clearAppContentDataObjects() {
        adUnitConfig.clearAppContentData()
    }
    
    // MARK: - User Data
    
    public func addUserData(_ userDataObjects: [PBMORTBContentData]) {
        adUnitConfig.addUserData(userDataObjects)
    }
    
    public func removeUserData(_ userDataObject: PBMORTBContentData) {
        adUnitConfig.removeUserData(userDataObject)
    }
    
    public func clearUserData() {
        adUnitConfig.clearUserData()
    }
    
    // MARK: - Public Methods
    
    public init(configID: String, size: CGSize, mediationDelegate: PrebidMediationDelegate) {
        adUnitConfig = AdUnitConfig(configId: configID, size: size)
        adUnitConfig.adConfiguration.bannerParameters.api = PrebidConstants.supportedRenderingBannerAPISignals
        
        self.mediationDelegate = mediationDelegate
        super.init()
        
        autoRefreshManager = PBMAutoRefreshManager(prefetchTime: PBMAdPrefetchTime,
                                                   locking: nil,
                                                   lockProvider: nil,
                                                   refreshDelay: { [weak self] in
            (self?.adUnitConfig.refreshInterval ?? 0) as NSNumber
        },
                                                   mayRefreshNowBlock: { [weak self] in
            guard let self = self else { return false }
            return self.isAdObjectVisible() || self.adRequestError != nil
        }, refreshBlock: { [weak self] in
            guard let self = self,
                  self.lastAdView != nil,
                  let completion = self.lastCompletion else {
                return
            }
            
            self.fetchDemand(connection: ServerConnection.shared,
                             sdkConfiguration: Prebid.shared,
                             targeting: Targeting.shared,
                             completion: completion)
        })
    }
    
    public func fetchDemand(completion: ((ResultCode)->Void)?) {
        
        fetchDemand(connection: ServerConnection.shared,
                    sdkConfiguration: Prebid.shared,
                    targeting: Targeting.shared,
                    completion: completion)
    }
    
    public func stopRefresh() {
        isRefreshStopped = true
    }
    
    public func adObjectDidFailToLoadAd(adObject: UIView,
                                        with error: Error) {
        if adObject === self.adView || adObject === self.lastAdView {
            self.adRequestError = error
        }
    }
    
    // MARK: Private functions
    
    // NOTE: do not use `private` to expose this method to unit tests
    func fetchDemand(connection: ServerConnectionProtocol,
                     sdkConfiguration: Prebid,
                     targeting: Targeting,
                     completion: ((ResultCode)->Void)?) {
        guard bidRequester == nil else {
            // Request in progress
            return
        }
        
        autoRefreshManager?.cancelRefreshTimer()
        
        if isRefreshStopped {
            return
        }
        
        self.adView = mediationDelegate.getAdView()
        self.completion = completion
        
        lastAdView = nil
        lastCompletion = nil
        adRequestError = nil
        
        mediationDelegate.cleanUpAdObject()
        
        bidRequester = PBMBidRequester(connection: connection,
                                       sdkConfiguration: sdkConfiguration,
                                       targeting: targeting,
                                       adUnitConfiguration: adUnitConfig)
        
        bidRequester?.requestBids(completion: { bidResponse, error in
            // Note: we have to run the completion on the main thread since
            // the handlePrebidResponse changes the Primary SDK Object which is UIView
            // This point to switch the context to the main thread looks the most accurate.
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                if self.isRefreshStopped {
                    self.markLoadingFinished()
                    return
                }
                
                if let response = bidResponse {
                    self.handlePrebidResponse(response: response)
                } else {
                    self.handlePrebidError(error: error)
                }
            }
        })
    }
    
    private func isAdObjectVisible() -> Bool {
        guard let adObject = adView else {
            return false
        }
        
        return adObject.pbmIsVisible()
    }
    
    private func markLoadingFinished() {
        adView = nil
        completion = nil
        bidRequester = nil
    }
    
    private func handlePrebidResponse(response: BidResponse) {
        var demandResult = ResultCode.prebidDemandNoBids
        
        if self.adView != nil, let winningBid = response.winningBid, let targetingInfo = response.targetingInfo {
            
            let adObjectSetupDictionary: [String: Any] = [
                PBMMediationConfigIdKey: configID,
                PBMMediationTargetingInfoKey: targetingInfo,
                PBMMediationAdUnitBidKey: winningBid
            ]
            
            if mediationDelegate.setUpAdObject(with: adObjectSetupDictionary) {
                demandResult = .prebidDemandFetchSuccess
            } else {
                demandResult = .prebidWrongArguments
            }    
        } else {
            Log.error("The winning bid is absent in response!")
        }
        
        completeWithResult(demandResult)
    }
    
    private func handlePrebidError(error: Error?) {
        completeWithResult(PBMError.demandResult(from: error))
    }
    
    private func completeWithResult(_ fetchDemandResult: ResultCode) {
        defer {
            markLoadingFinished()
        }
        
        guard let adObject = self .adView,
              let completion = self.completion else {
            return
        }
        
        lastAdView = adObject
        lastCompletion = completion
        
        autoRefreshManager?.setupRefreshTimer()
        
        DispatchQueue.main.async {
            completion(fetchDemandResult)
        }
    }
}
