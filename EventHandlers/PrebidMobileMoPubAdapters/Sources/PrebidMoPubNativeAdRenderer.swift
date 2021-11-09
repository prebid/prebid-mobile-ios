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

import PrebidMobile

// The feature is not available. Use original Prebid Native API
// TODO: Merge Native engine from original SDK and rendering codebase

@objc(PrebidMoPubNativeAdRenderer)
public class PrebidMoPubNativeAdRenderer : NSObject, MPNativeAdRenderer, MPNativeAdRendererImageHandlerDelegate {
 
    // MARK: - Public Properties
    
    public let viewSizeHandler: MPNativeViewSizeHandler?

    // MARK: - Internal Properties
    
    var adView: UIView?
    var adapter: PrebidMoPubNativeAdAdapter?
    var renderingViewClass: UIView.Type?
    var rendererImageHandler: MPNativeAdRendererImageHandler?
    var adViewInViewHierarchy = false
    
    // MARK: - MPNativeAdRenderer
    
    public static func rendererConfiguration(with rendererSettings: MPNativeAdRendererSettings!) -> MPNativeAdRendererConfiguration! {
        let config = MPNativeAdRendererConfiguration()
        
        config.rendererClass = Self.self
        config.rendererSettings = rendererSettings;
        config.supportedCustomEvents = [String(describing: PrebidMoPubNativeCustomEvent.self)]
            
        return config;
    }
    
    public required init!(rendererSettings: MPNativeAdRendererSettings!) {
        guard let settings = rendererSettings as?  MPStaticNativeAdRendererSettings else  {
            viewSizeHandler = { size in
                CGSize.init()
            }
            
            super.init()

            return
        }
        
        renderingViewClass = settings.renderingViewClass as? UIView.Type
        viewSizeHandler = settings.viewSizeHandler
        rendererImageHandler = MPNativeAdRendererImageHandler()
        
        super.init()
        
        rendererImageHandler?.delegate = self
    }
    
    public func retrieveView(with adapter: MPNativeAdAdapter) throws -> UIView {
        guard let adapter               = adapter as? PrebidMoPubNativeAdAdapter,
              let renderingViewClass    = renderingViewClass,
              let mopubAdRenderingClass = renderingViewClass as? MPNativeAdRendering.Type else {
            throw MPNativeAdNSErrorForRenderValueTypeError()
        }
        
        self.adapter = adapter
       
        if (renderingViewClass.responds(to: NSSelectorFromString("nibForAd"))) {
            if let nib = mopubAdRenderingClass.nibForAd?() {
                adView = nib.instantiate(withOwner: nil, options: nil).first as? UIView
            }
        } else {
            adView = renderingViewClass.init()
        }
        
        guard let adView = self.adView,
              let moPubAdView = adView as? MPNativeAdRendering else {
            throw MPNativeAdNSErrorForRenderValueTypeError()
        }
        
        adView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        adapter.nativeAd.registerView(adView, clickableViews: nil)
        
        if (moPubAdView.responds(to: #selector(MPNativeAdRendering.nativeMainTextLabel))) {
            moPubAdView.nativeMainTextLabel?()?.text = adapter.properties[kAdTextKey] as? String;
        }
        
        if (moPubAdView.responds(to: #selector(MPNativeAdRendering.nativeTitleTextLabel))) {
            moPubAdView.nativeTitleTextLabel?()?.text = adapter.properties[kAdTitleKey] as? String;
        }
        
        if (moPubAdView.responds(to: #selector(MPNativeAdRendering.nativeCallToActionTextLabel))) {
            if let ctaLabel = moPubAdView.nativeCallToActionTextLabel?() {
                ctaLabel.text = adapter.properties[kAdCTATextKey] as? String;
                adapter.nativeAd.registerClickView(ctaLabel, nativeAdElementType: .callToAction)
            }
        }
        
        if  let  sponsoredText = adapter.properties[kAdSponsoredByCompanyKey] as? String,
            moPubAdView.responds(to: #selector(MPNativeAdRendering.nativeSponsoredByCompanyTextLabel)),
            let sponsoredLabel =  moPubAdView.nativeSponsoredByCompanyTextLabel?() {
            
            sponsoredLabel.text = sponsoredText
            
            if let brandAsset = adapter.nativeAd.dataObjects(of: .sponsored).first {
                adapter.nativeAd.registerClickView(sponsoredLabel, nativeAdAsset: brandAsset)
            }
        }
        
        if let _ = adapter.properties[kAdIconImageKey],
           moPubAdView.responds(to: #selector(MPNativeAdRendering.nativeIconImageView)),
           let iconView =  moPubAdView.nativeIconImageView?() {
            adapter.nativeAd.registerClickView(iconView, nativeAdElementType: .icon)
        }
        
        if shouldLoadMediaView(),
           moPubAdView.responds(to: #selector(MPNativeAdRendering.nativeMainImageView)),
           let mainImageView =  moPubAdView.nativeMainImageView?(),
           let mediaView = adapter.mainMediaView() {
            
            mediaView.frame = mainImageView.bounds
            mediaView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            mainImageView.isUserInteractionEnabled = true
            
            mainImageView.addSubview(mediaView)
        }
        
        return adView
    }
    
    public func adViewWillMove(toSuperview superview: UIView?) {
        guard
            let _ = superview,
            let adapter = adapter,
            let adView = adView,
            let moPubAdView = adView as? MPNativeAdRendering
        else {
            adViewInViewHierarchy = false
            return
        }
        
        adViewInViewHierarchy = true
                
        if let urlString = adapter.properties[kAdIconImageKey] as? String,
           let url = URL(string: urlString),
           adView.responds(to: #selector(MPNativeAdRendering.nativeIconImageView)),
           let iconView = moPubAdView.nativeIconImageView?() {
            rendererImageHandler?.loadImage(for: url, into: iconView)
        }
        
        var mainImageView: UIView?
        
        if adapter.responds(to: #selector(MPNativeAdAdapter.mainMediaView)) {
            mainImageView = adapter.mainMediaView()
        }
        
        if mainImageView == nil {
            if let urlString = adapter.properties[kAdMainImageKey] as? String,
               let url = URL(string: urlString),
               moPubAdView.responds(to: #selector(MPNativeAdRendering.nativeMainImageView)),
               let imageView = moPubAdView.nativeMainImageView?() {
                
                rendererImageHandler?.loadImage(for: url, into: imageView)
            }
        }
    }
    
    // MARK: - MPNativeAdRendererImageHandlerDelegate
    
    public func nativeAdViewInViewHierarchy() -> Bool {
        adViewInViewHierarchy
    }
    
    // MARK: - Private Methods

    func shouldLoadMediaView() -> Bool {
        if let adapter = adapter,
           let adView = adView,
           adapter.responds(to: #selector(MPNativeAdAdapter.mainMediaView)),
           let _ = adapter.mainMediaView(),
           adView.responds(to: #selector(MPNativeAdRendering.nativeMainImageView)) {
            return true
        }
        
        return false
    }
}
