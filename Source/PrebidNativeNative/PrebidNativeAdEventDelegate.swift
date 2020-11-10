//
//  PrebidNativeAdEventDelegate.swift
//  PrebidMobile
//
//  Created by Akash.Verma on 05/11/20.
//  Copyright © 2020 AppNexus. All rights reserved.
//

import Foundation

@objc public protocol PrebidNativeAdEventDelegate : AnyObject {
    /**
     * Sent when the native ad is expired.
     */
    @objc optional func adDidExpire(ad: PrebidNativeAd)
    /**
     * Sent when the native view is clicked by the user.
     */
    @objc optional func adWasClicked(ad: PrebidNativeAd)
    /**
     * Sent when  an impression is recorded for an native ad
     */
    @objc optional func adDidLogImpression(ad: PrebidNativeAd)
}
