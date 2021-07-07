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
    
    let banner = GAMBannerView()
    
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
    
    public var delegate: GADBannerViewDelegate? {
        get { banner.delegate }
        set { banner.delegate = newValue }
    }
    
    public var appEventDelegate: GADAppEventDelegate? {
        get { banner.appEventDelegate }
        set { banner.appEventDelegate = newValue }
    }
    
    public var adSizeDelegate: GADAdSizeDelegate? {
        get { banner.adSizeDelegate }
        set { banner.adSizeDelegate = newValue }
    }
    
    public var enableManualImpressions: Bool {
        get { banner.enableManualImpressions }
        set { banner.enableManualImpressions = newValue }
    }
    
    public var adSize : GADAdSize {
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
            return false;
        }
        
        let testClass = GAMBannerView.self
        
        let selectors = [
            #selector(getter: GAMBannerView.adUnitID),
            #selector(setter: GAMBannerView.adUnitID),
            
            #selector(getter: GAMBannerView.validAdSizes),
            #selector(setter: GAMBannerView.validAdSizes),
            
            #selector(getter: GAMBannerView.rootViewController),
            #selector(setter: GAMBannerView.rootViewController),
            
            #selector(getter: GAMBannerView.delegate),
            #selector(setter: GAMBannerView.delegate),
            
            #selector(getter: GAMBannerView.appEventDelegate),
            #selector(setter: GAMBannerView.appEventDelegate),
            
            #selector(getter: GAMBannerView.adSizeDelegate),
            #selector(setter: GAMBannerView.adSizeDelegate),
            
            #selector(getter: GAMBannerView.enableManualImpressions),
            #selector(setter: GAMBannerView.enableManualImpressions),
            
            #selector(getter: GAMBannerView.adSize),
            #selector(setter: GAMBannerView.adSize),
            
            #selector(GAMBannerView.load(_:)),
            #selector(GAMBannerView.recordImpression),
        ]
        
        for selector in selectors {
            if testClass.instancesRespond(to: selector) == false {
                return false
            }
        }
        
        return true
    }

}
