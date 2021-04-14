//
//  FeedGAMAdTableViewCell.swift
//  OpenXInternalTestApp
//
//  Copyright © 2021 OpenX. All rights reserved.
//

import UIKit

import GoogleMobileAds
import PrebidMobileGAMEventHandlers

class FeedGAMAdTableViewCell: UITableViewCell {
    @IBOutlet weak var bannerView: UIView!
    
    var gamCustomTemplateIDs: [String] = []
    
    private var adUnit: OXANativeAdUnit?
    private var theNativeAd: OXANativeAd?
    
    private let nativeAdViewBox = NativeAdViewBox()
    
    private var adLoader: GADAdLoader?
    
    private var customTemplateAd: GADNativeCustomTemplateAd?
    
    private weak var rootController: UIViewController?
    
    func loadAd(configID: String,
                nativeAdConfig: OXANativeAdConfiguration,
                GAMAdUnitID: String,
                rootViewController: UIViewController,
                adTypes: [GADAdLoaderAdType]) {
        
        self.rootController = rootViewController
        self.adUnit = OXANativeAdUnit(configID: configID, nativeAdConfiguration: nativeAdConfig)
        
        if let adUnitContext = AppConfiguration.shared.adUnitContext {
            for dataPair in adUnitContext {
                adUnit?.addContextData(dataPair.value, forKey: dataPair.key)
            }
        }
        adUnit?.fetchDemand { [weak self] demandResponseInfo in
            guard let self = self else {
                return
            }
            
            guard demandResponseInfo.fetchDemandResult == .ok else {
                return
            }
            
            let dfpRequest = DFPRequest()
            OXAGAMUtils.shared().prepare(dfpRequest, demandResponseInfo: demandResponseInfo)
            self.adLoader = GADAdLoader(adUnitID: GAMAdUnitID,
                                        rootViewController: rootViewController,
                                        adTypes: adTypes,
                                        options: [])
            self.adLoader?.delegate = self
            self.adLoader?.load(dfpRequest)
        }
    }
}

extension FeedGAMAdTableViewCell: GADNativeCustomTemplateAdLoaderDelegate {
    func nativeCustomTemplateIDs(for adLoader: GADAdLoader) -> [String] {
        return gamCustomTemplateIDs
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeCustomTemplateAd: GADNativeCustomTemplateAd) {
        customTemplateAd = nil
        
        let nativeAdDetectionListener = OXANativeAdDetectionListener { [weak self] nativeAd in
            guard let self = self else {
                return
            }
            self.setupBanner()
            
            self.nativeAdViewBox.renderNativeAd(nativeAd)
            self.nativeAdViewBox.registerViews(nativeAd)
            self.theNativeAd = nativeAd // Note: RETAIN! or the tracking will not occur!
            nativeAd.uiDelegate = self
            self.customTemplateAd = nativeCustomTemplateAd
            nativeCustomTemplateAd.customClickHandler = { assetID in }
            nativeCustomTemplateAd.recordImpression()
        } onPrimaryAdWin: { [weak self] in
            guard let self = self else {
                return
            }
            self.nativeAdViewBox.renderCustomTemplateAd(nativeCustomTemplateAd)
            self.customTemplateAd = nativeCustomTemplateAd
            nativeCustomTemplateAd.recordImpression()
        } onNativeAdInvalid: { _ in

        }

        OXAGAMUtils.shared().findNativeAd(in: nativeCustomTemplateAd,
                                          nativeAdDetectionListener: nativeAdDetectionListener)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
    }
    
    private func setupBanner() {
        guard let bannerView = self.bannerView else {
            return
        }
        
        self.nativeAdViewBox.embedIntoView(self.bannerView)
        let bannerConstraints = bannerView.constraints
        bannerView.removeConstraint(bannerConstraints.first { $0.firstAttribute == .width }!)
        bannerView.removeConstraint(bannerConstraints.first { $0.firstAttribute == .height }!)
        if let bannerParent = bannerView.superview {
            bannerParent.addConstraints([
                NSLayoutConstraint(item: bannerView,
                                   attribute: .width,
                                   relatedBy: .lessThanOrEqual,
                                   toItem: bannerParent,
                                   attribute: .width,
                                   multiplier: 1,
                                   constant: -10),
            ])
        }
    }
}

extension FeedGAMAdTableViewCell: OXANativeAdUIDelegate {
    func viewPresentationController(for nativeAd: OXANativeAd) -> UIViewController? {
        return rootController
    }
}
