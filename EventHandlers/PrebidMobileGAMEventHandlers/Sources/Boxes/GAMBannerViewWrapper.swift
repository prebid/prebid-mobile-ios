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

class GAMBannerViewWrapper {
    
    // MARK: - Private Properties
    
    private static var classesValidated: Bool?
    
    private static var classesFound = GAMBannerViewWrapper.findClasses()
    
    // MARK: - Public Properties
    
    let banner = AdManagerBannerView()
    
    // MARK: - Public Methods
        
    public init?() {
        if !Self.classesFound {
            GAMUtils.log(error: GAMEventHandlerError.gamClassesNotFound)
            return nil
        }
    }
    
    // MARK: - Public Wrappers (Properties)

    public var adUnitID: String? {
        get { banner.adUnitID }
        set { banner.adUnitID = newValue  }
    }
    
    public var validAdSizes: [NSValue]? {
        get { banner.validAdSizes }
        set { banner.validAdSizes = newValue }
    }
    
    public var rootViewController: UIViewController? {
        get { banner.rootViewController }
        set { banner.rootViewController = newValue }
    }
    
    public var delegate: GoogleMobileAds.BannerViewDelegate? {
        get { banner.delegate }
        set { banner.delegate = newValue }
    }
    
    public var appEventDelegate: GoogleMobileAds.AppEventDelegate? {
        get { banner.appEventDelegate }
        set { banner.appEventDelegate = newValue }
    }
    
    public var adSizeDelegate: GoogleMobileAds.AdSizeDelegate? {
        get { banner.adSizeDelegate }
        set { banner.adSizeDelegate = newValue }
    }
    
    public var enableManualImpressions: Bool {
        get { banner.enableManualImpressions }
        set { banner.enableManualImpressions = newValue }
    }
    
    public var adSize: GoogleMobileAds.AdSize {
        get { banner.adSize }
        set { banner.adSize = newValue }
    }
        
    // MARK: - Public Wrappers (Properties)

    public func load(_ request: GAMRequestWrapper) {
        banner.load(request.request)
    }

    public func recordImpression() {
        banner.recordImpression()
    }
    
    // MARK: - Private Methods
    
    static func findClasses() -> Bool {
        guard let _ = NSClassFromString("GAMBannerView"),
              let _ = NSProtocolFromString("GADBannerViewDelegate"),
              let _ = NSProtocolFromString("GADAppEventDelegate"),
              let _ = NSProtocolFromString("GADAdSizeDelegate") else {
            return false
        }
        
        let testClass = AdManagerBannerView.self
        
        let selectors = [
            #selector(getter: AdManagerBannerView.adUnitID),
            #selector(setter: AdManagerBannerView.adUnitID),
            
            #selector(getter: AdManagerBannerView.validAdSizes),
            #selector(setter: AdManagerBannerView.validAdSizes),
            
            #selector(getter: AdManagerBannerView.rootViewController),
            #selector(setter: AdManagerBannerView.rootViewController),
            
            #selector(getter: AdManagerBannerView.delegate),
            #selector(setter: AdManagerBannerView.delegate),
            
            #selector(getter: AdManagerBannerView.appEventDelegate),
            #selector(setter: AdManagerBannerView.appEventDelegate),
            
            #selector(getter: AdManagerBannerView.adSizeDelegate),
            #selector(setter: AdManagerBannerView.adSizeDelegate),
            
            #selector(getter: AdManagerBannerView.enableManualImpressions),
            #selector(setter: AdManagerBannerView.enableManualImpressions),
            
            #selector(getter: AdManagerBannerView.adSize),
            #selector(setter: AdManagerBannerView.adSize),
            
            #selector(AdManagerBannerView.load(_:)),
            #selector(AdManagerBannerView.recordImpression),
        ]
        
        for selector in selectors {
            if testClass.instancesRespond(to: selector) == false {
                return false
            }
        }
        
        return true
    }
}
