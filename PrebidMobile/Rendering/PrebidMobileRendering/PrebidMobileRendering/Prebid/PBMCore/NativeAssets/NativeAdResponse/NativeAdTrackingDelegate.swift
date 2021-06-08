//
//  NativeAdTrackingDelegate.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

@objc public protocol NativeAdTrackingDelegate where Self: NSObject {
    
    @objc optional func nativeAdDidLogClick(_ nativeAd: NativeAd)
    @objc optional func nativeAd(_ nativeAd: NativeAd,
                                 didLogEvent event: NativeEventType)

}
