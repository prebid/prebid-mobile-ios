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

class GADRewardedAdWrapper {
    
    // MARK: Private Properties
        
    private let adUnitID: String
    
    private static var classesFound = GADRewardedAdWrapper.findClasses()

    // MARK: Public Properties
    
    var rewardedAd: GoogleMobileAds.RewardedAd?
    
    // MARK: Public Methods
    
    init?(adUnitID: String) {
        if !Self.classesFound {
            GAMUtils.log(error: GAMEventHandlerError.gamClassesNotFound)
            return nil
        }
        
        self.adUnitID = adUnitID
    }
    
    // MARK: - Public Wrappers (Properties)

    public var adMetadata: [GADAdMetadataKey : Any]? {
        rewardedAd?.adMetadata
    }
    
    public var adMetadataDelegate: GoogleMobileAds.AdMetadataDelegate? {
        get { rewardedAd?.adMetadataDelegate }
        set { rewardedAd?.adMetadataDelegate = newValue }
    }
    
    public var reward: GoogleMobileAds.AdReward? {
        rewardedAd?.adReward
    }
    
    // MARK: - Public Wrappers (Methods)

    public func load(
        request: GAMRequestWrapper,
        completion: @escaping (GADRewardedAdWrapper?, Error?) -> Void
    ) {
        GoogleMobileAds.RewardedAd.load(
            with: adUnitID,
            request: request.request,
            completionHandler: { [weak self] (ad, error)  in
                guard let self = self else { return }
                
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                self.rewardedAd = ad
                completion(self, nil)
            })
    }
    
    public func present(
        from rootViewController: UIViewController,
        userDidEarnRewardHandler: @escaping () -> Void
    ) {
        rewardedAd?.present(
            from: rootViewController,
            userDidEarnRewardHandler: userDidEarnRewardHandler
        )
    }
    
    // MARK: - Private methods
    
    private static func findClasses() -> Bool {
        guard let _ = NSClassFromString("GADRewardedAd"),
              let _ = NSClassFromString("GADAdReward"),
              let _ = NSProtocolFromString("GADAdMetadataDelegate") else {
            return false
        }
        
        let selector = NSSelectorFromString("loadWithAdUnitID:request:completionHandler:")
        if GoogleMobileAds.RewardedAd.responds(to: selector) == false {
            return false
        }
        
        let testClass = GoogleMobileAds.RewardedAd.self
        
        let selectors = [
            #selector(getter: GoogleMobileAds.RewardedAd.adMetadataDelegate),
            #selector(setter: GoogleMobileAds.RewardedAd.adMetadataDelegate),
            #selector(getter: GoogleMobileAds.RewardedAd.adMetadata),
            #selector(getter: GoogleMobileAds.RewardedAd.adReward),
            #selector(GoogleMobileAds.RewardedAd.present(from:userDidEarnRewardHandler:)),
        ]
        
        for selector in selectors {
            if testClass.instancesRespond(to: selector) == false {
                return false
            }
        }
        
        return true
    }
}
