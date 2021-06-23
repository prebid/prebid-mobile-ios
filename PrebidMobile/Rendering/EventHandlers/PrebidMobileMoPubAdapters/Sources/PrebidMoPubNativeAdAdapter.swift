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

import MoPubSDK

//import PrebidMobile
import PrebidMobile

@objc(PrebidMoPubNativeAdAdapter)
class PrebidMoPubNativeAdAdapter:
    NSObject,
    MPNativeAdAdapter,
    NativeAdUIDelegate,
    NativeAdTrackingDelegate
{
    
    // MARK: - Public Properties
    
    weak var delegate: MPNativeAdAdapterDelegate?
    var nativeAd: NativeAd
    
    // MARK: - Internal Properties
    
    var mediaView: MediaView?
    
    // MARK: - Public Methods
    
    init(nativeAd: NativeAd) {
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
    
    // MARK: - NativeAdUIDelegate
    
    func viewPresentationControllerForNativeAd(_ nativeAd: NativeAd) -> UIViewController? {
        delegate?.viewControllerForPresentingModalView()
    }
    
    func nativeAdWillLeaveApplication(_ nativeAd: NativeAd) {
        MPLogging.logEvent(MPLogEvent.adWillLeaveApplication(forAdapter: Self.className()), source: nil, from: nil)
        delegate?.nativeAdWillLeaveApplication(from: self)
    }
    
    func nativeAdWillPresentModal(_ nativeAd: NativeAd) {
        MPLogging.logEvent(MPLogEvent.adWillPresentModal(forAdapter: Self.className()), source: nil, from: nil)
        delegate?.nativeAdWillPresentModal(for: self)
    }
    
    func nativeAdDidDismissModal(_ nativeAd: NativeAd) {
        MPLogging.logEvent(MPLogEvent.adDidDismissModal(forAdapter: Self.className()), source: nil, from: nil)
        delegate?.nativeAdDidDismissModal(for: self)
    }
    
    // MARK: - NativeAdTrackingDelegate
    
    func nativeAdDidLogClick(_ nativeAd: NativeAd) {
        guard let delegate = delegate,
           delegate.responds(to: #selector(MPNativeAdAdapterDelegate.nativeAdDidClick)) else {
            return
        }
        
        MPLogging.logEvent(MPLogEvent.adTapped(forAdapter: Self.className()), source: nil, from: nil)
        delegate.nativeAdDidClick?(self)
    }
    
    func nativeAd(_ nativeAd: NativeAd, didLogEvent nativeEvent: NativeEventType) {
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
