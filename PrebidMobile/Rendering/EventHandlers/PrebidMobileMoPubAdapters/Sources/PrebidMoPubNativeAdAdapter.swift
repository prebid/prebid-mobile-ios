//
//  PrebidMoPubNativeAdAdapter.swift
//  PrebidMobileMoPubAdapters
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

import MoPubSDK

import PrebidMobileRendering

@objc(PrebidMoPubNativeAdAdapter)
class PrebidMoPubNativeAdAdapter:
    NSObject,
    MPNativeAdAdapter,
    PBMNativeAdUIDelegate,
    PBMNativeAdTrackingDelegate
{
    
    // MARK: - Public Properties
    
    weak var delegate: MPNativeAdAdapterDelegate?
    var nativeAd: PBMNativeAd
    
    // MARK: - Internal Properties
    
    var mediaView: MediaView?
    
    // MARK: - Public Methods
    
    init(nativeAd: PBMNativeAd) {
        self.nativeAd = nativeAd
        
        super.init()
        
        self.nativeAd.uiDelegate = self
        self.nativeAd.trackingDelegate = self
        
        properties[kAdTitleKey] = nativeAd.title
        properties[kAdTextKey] = nativeAd.text
       
        let sponsored = nativeAd.dataObjects(of: .sponsored).first?.value
       
        properties[kAdSponsoredByCompanyKey] = sponsored;
        properties[kAdCTATextKey] = nativeAd.callToAction;
        
        if !nativeAd.iconURL.isEmpty {
            properties[kAdIconImageKey] = nativeAd.iconURL.isEmpty;
        }
        
        if !nativeAd.imageURL.isEmpty {
            properties[kAdMainImageKey] = nativeAd.imageURL;

        }
        
        if let ratingString = nativeAd.dataObjects(of: .rating).first?.value {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let ratingNum = formatter.number(from: ratingString)
            properties[kAdStarRatingKey] = ratingNum
        }
        
        if let mediaData = nativeAd.videoAd?.mediaData {
            mediaView = MediaView()
            properties[kAdMainMediaViewKey] = mediaView
            mediaView?.load(mediaData)
        }
    }
    
    // MARK: - MPNativeAdAdapter
    
    var properties = [AnyHashable : Any]()
    
    var defaultActionURL: URL? {
        nil
    }
    
    func enableThirdPartyClickTracking() -> Bool {
        true
    }
    
    func mainMediaView() -> UIView? {
        self.mediaView
    }
    
    // MARK: - PBMNativeAdUIDelegate
    
    func viewPresentationController(for nativeAd: PBMNativeAd) -> UIViewController? {
        delegate?.viewControllerForPresentingModalView()
    }
    
    func nativeAdWillLeaveApplication(_ nativeAd: PBMNativeAd) {
        MPLogging.logEvent(MPLogEvent.adWillLeaveApplication(forAdapter: Self.className()), source: nil, from: nil)
        delegate?.nativeAdWillLeaveApplication(from: self)
    }
    
    func nativeAdWillPresentModal(_ nativeAd: PBMNativeAd) {
        MPLogging.logEvent(MPLogEvent.adWillPresentModal(forAdapter: Self.className()), source: nil, from: nil)
        delegate?.nativeAdWillPresentModal(for: self)
    }
    
    func nativeAdDidDismissModal(_ nativeAd: PBMNativeAd) {
        MPLogging.logEvent(MPLogEvent.adDidDismissModal(forAdapter: Self.className()), source: nil, from: nil)
        delegate?.nativeAdDidDismissModal(for: self)
    }
    
    // MARK: - PBMNativeAdTrackingDelegate
    
    func nativeAdDidLogClick(_ nativeAd: PBMNativeAd) {
        guard let delegate = delegate,
           delegate.responds(to: #selector(MPNativeAdAdapterDelegate.nativeAdDidClick)) else {
            return
        }
        
        MPLogging.logEvent(MPLogEvent.adTapped(forAdapter: Self.className()), source: nil, from: nil)
        delegate.nativeAdDidClick?(self)
    }
    
    func nativeAd(_ nativeAd: PBMNativeAd, didLogEvent nativeEvent: PBMNativeEventType) {
        guard nativeEvent == .impression,
              let delegate = delegate,
              delegate.responds(to: #selector(MPNativeAdAdapterDelegate.nativeAdWillLogImpression)) else {
            return
        }
        
        MPLogging.logEvent(MPLogEvent.adShowSuccess(forAdapter: Self.className()), source: nil, from: nil)
        MPLogging.logEvent(MPLogEvent.adWillAppear(forAdapter: Self.className()), source: nil, from: nil)
        
        delegate.nativeAdWillLogImpression?(self)
    }
}
