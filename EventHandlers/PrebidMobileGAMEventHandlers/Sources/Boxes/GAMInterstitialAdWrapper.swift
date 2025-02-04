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

class GAMInterstitialAdWrapper {
    
    // MARK: - Internal properties
    
    private static var classesFound = GAMInterstitialAdWrapper.findClasses()

    private let adUnitID: String
    
    // MARK: Public Properties
    
    var interstitialAd: AdManagerInterstitialAd?

    // MARK: Public Methods
    
    init?(adUnitID: String) {
        if !Self.classesFound {
            GAMUtils.log(error: GAMEventHandlerError.gamClassesNotFound)
            return nil
        }
        
        self.adUnitID = adUnitID
    }
    
    // MARK: - Public Wrappers (Properties)
    
    public var fullScreenContentDelegate: GoogleMobileAds.FullScreenContentDelegate? {
        get { interstitialAd?.fullScreenContentDelegate }
        set { interstitialAd?.fullScreenContentDelegate = newValue }
    }
    
    public var appEventDelegate: GoogleMobileAds.AppEventDelegate? {
        get { interstitialAd?.appEventDelegate }
        set { interstitialAd?.appEventDelegate = newValue }
    }
    
    // MARK: - Public Wrappers (Methods)

    public func load(
        request: GAMRequestWrapper,
        completion: @escaping (GAMInterstitialAdWrapper, Error?) -> Void
    ) {
        AdManagerInterstitialAd.load(
            with: adUnitID,
            request: request.request,
            completionHandler: { [weak self] ad, error in
                guard let self = self else { return }
                
                if let error = error {
                    completion(self, error)
                    return
                }
                
                self.interstitialAd = ad
                completion(self, nil)
            })
    }
    
    public func present(from rootViewController: UIViewController) {
        interstitialAd?.present(from: rootViewController)
    }
    
    // MARK: - Private Methods
    
    static func findClasses() -> Bool {
        guard let _ = NSClassFromString("GAMInterstitialAd"),
              let _ = NSProtocolFromString("GADAppEventDelegate") else {
            return false
        }
        
        let selector = NSSelectorFromString("loadWithAdManagerAdUnitID:request:completionHandler:")
        if AdManagerInterstitialAd.responds(to: selector) == false {
            return false
        }
        
        let testClass = AdManagerInterstitialAd.self
        
        let selectors = [
            #selector(getter: AdManagerInterstitialAd.fullScreenContentDelegate),
            #selector(setter: AdManagerInterstitialAd.fullScreenContentDelegate),
            #selector(getter: AdManagerInterstitialAd.appEventDelegate),
            #selector(setter: AdManagerInterstitialAd.appEventDelegate),

            #selector(AdManagerInterstitialAd.present(from:)),
        ]
        
        for selector in selectors {
            if testClass.instancesRespond(to: selector) == false {
                return false
            }
        }
        
        return true
    }
    
}
