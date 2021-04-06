//
//  UnifiedNativeAdView.swift
//  OpenXInternalTestApp
//
//  Copyright © 2021 OpenX. All rights reserved.
//

import GoogleMobileAds

class UnifiedNativeAdView: GADUnifiedNativeAdView {
    /// The height constraint applied to the ad view, where necessary.
    private var heightConstraint: NSLayoutConstraint?
    
    func renderUnifiedNativeAd(_ unifiedNativeAd: GADUnifiedNativeAd) {
        // Deactivate the height constraint that was set when the previous video ad loaded.
        heightConstraint?.isActive = false
        
        // Populate the native ad view with the native ad assets.
        // The headline and mediaContent are guaranteed to be present in every native ad.
        (headlineView as? UILabel)?.text = unifiedNativeAd.headline
        mediaView?.mediaContent = unifiedNativeAd.mediaContent
        
//        // Some native ads will include a video asset, while others do not. Apps can use the
//        // GADVideoController's hasVideoContent property to determine if one is present, and adjust their
//        // UI accordingly.
//        let mediaContent = unifiedNativeAd.mediaContent
//        if mediaContent.hasVideoContent {
//            // By acting as the delegate to the GADVideoController, this ViewController receives messages
//            // about events in the video lifecycle.
//            mediaContent.videoController.delegate = self
//            videoStatusLabel.text = "Ad contains a video asset."
//        } else {
//            videoStatusLabel.text = "Ad does not contain a video."
//        }
        
        // This app uses a fixed width for the GADMediaView and changes its height to match the aspect
        // ratio of the media it displays.
        if let mediaView = mediaView, unifiedNativeAd.mediaContent.aspectRatio > 0 {
            heightConstraint = NSLayoutConstraint(
                item: mediaView,
                attribute: .height,
                relatedBy: .equal,
                toItem: mediaView,
                attribute: .width,
                multiplier: CGFloat(1 / unifiedNativeAd.mediaContent.aspectRatio),
                constant: 0)
            heightConstraint?.isActive = true
        }
        
        // These assets are not guaranteed to be present. Check that they are before
        // showing or hiding them.
        (bodyView as? UILabel)?.text = unifiedNativeAd.body
        bodyView?.isHidden = unifiedNativeAd.body == nil
        
        (callToActionView as? UIButton)?.setTitle(unifiedNativeAd.callToAction, for: .normal)
        callToActionView?.isHidden = unifiedNativeAd.callToAction == nil
        
        (iconView as? UIImageView)?.image = unifiedNativeAd.icon?.image
        iconView?.isHidden = unifiedNativeAd.icon == nil
        
        (starRatingView as? UIImageView)?.image = imageOfStars(from: unifiedNativeAd.starRating)
        starRatingView?.isHidden = unifiedNativeAd.starRating == nil
        
        (storeView as? UILabel)?.text = unifiedNativeAd.store
        storeView?.isHidden = unifiedNativeAd.store == nil
        
        (priceView as? UILabel)?.text = unifiedNativeAd.price
        priceView?.isHidden = unifiedNativeAd.price == nil
        
        (advertiserView as? UILabel)?.text = unifiedNativeAd.advertiser
        advertiserView?.isHidden = unifiedNativeAd.advertiser == nil
        
        // In order for the SDK to process touch events properly, user interaction should be disabled.
        callToActionView?.isUserInteractionEnabled = false
        
        // Associate the native ad view with the native ad object. This is
        // required to make the ad clickable.
        // Note: this should always be done after populating the ad views.
        nativeAd = unifiedNativeAd
    }
    
    /// Returns a `UIImage` representing the number of stars from the given star rating; returns `nil`
    /// if the star rating is less than 3.5 stars.
    private func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
        guard let rating = starRating?.doubleValue else {
            return nil
        }
        if rating >= 5 {
            return UIImage(named: "stars_5")
        } else if rating >= 4.5 {
            return UIImage(named: "stars_4_5")
        } else if rating >= 4 {
            return UIImage(named: "stars_4")
        } else if rating >= 3.5 {
            return UIImage(named: "stars_3_5")
        } else {
            return nil
        }
    }
}
