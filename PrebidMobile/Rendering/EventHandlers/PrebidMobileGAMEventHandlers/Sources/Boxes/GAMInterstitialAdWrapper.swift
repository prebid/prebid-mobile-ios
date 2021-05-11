//
//  GAMInterstitialAdWrapper.swift
//  PrebidMobileGAMEventHandlers
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import GoogleMobileAds

class GAMInterstitialAdWrapper {
    
    // MARK: - Internal properties
    
    private static var classesFound = GAMInterstitialAdWrapper.findClasses()

    private let adUnitID: String
    
    // MARK: Public Properties
    
    var interstitialAd: GAMInterstitialAd?

    // MARK: Public Methods
    
    init?(adUnitID: String) {
        if !Self.classesFound {
            GAMUtils.log(error: GAMEventHandlerError.gamClassesNotFound)
            return nil
        }
        
        self.adUnitID = adUnitID
    }
    
    // MARK: - Public Wrappers (Properties)
    
    public var fullScreenContentDelegate: GADFullScreenContentDelegate? {
        get { interstitialAd?.fullScreenContentDelegate }
        set { interstitialAd?.fullScreenContentDelegate = newValue }
    }
    
    public var appEventDelegate: GADAppEventDelegate? {
        get { interstitialAd?.appEventDelegate }
        set { interstitialAd?.appEventDelegate = newValue }
    }
    
    // MARK: - Public Wrappers (Methods)

    public func load(request: GAMRequestWrapper,
                     completion: @escaping (GAMInterstitialAdWrapper, Error?) -> Void) {
        
        GAMInterstitialAd.load(withAdManagerAdUnitID: adUnitID,
                               request: request.request,
                               completionHandler: { [weak self] ad, error in
            guard let self = self else {
                return
            }
            
            if let error = error {
                completion(self, error)
                return
            }
            
            self.interstitialAd = ad
            completion(self, nil)
        })
    }
    
    public func present(from rootViewController: UIViewController) {
        interstitialAd?.present(fromRootViewController: rootViewController)
    }
    
    // MARK: - Private Methods
    
    static func findClasses() -> Bool {
        
        guard let _ = NSClassFromString("GAMInterstitialAd"),
              let _ = NSProtocolFromString("GADAppEventDelegate") else {
            return false;
        }
        
        let selector = NSSelectorFromString("loadWithAdManagerAdUnitID:request:completionHandler:")
        if GAMInterstitialAd.responds(to: selector) == false {
            return false
        }
        
        let testClass = GAMInterstitialAd.self
        
        let selectors = [
            #selector(getter: GAMInterstitialAd.fullScreenContentDelegate),
            #selector(setter: GAMInterstitialAd.fullScreenContentDelegate),
            #selector(getter: GAMInterstitialAd.appEventDelegate),
            #selector(setter: GAMInterstitialAd.appEventDelegate),

            #selector(GAMInterstitialAd.present(fromRootViewController:)),
        ]
        
        for selector in selectors {
            if testClass.instancesRespond(to: selector) == false {
                return false
            }
        }
        
        return true
    }
    
}
