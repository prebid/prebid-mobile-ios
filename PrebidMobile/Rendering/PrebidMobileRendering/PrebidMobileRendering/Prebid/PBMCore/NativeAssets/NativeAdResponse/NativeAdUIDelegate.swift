//
//  NativeAdUIDelegate.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol NativeAdUIDelegate where Self: NSObject {
    
    /*!
     @abstract Asks the delegate for a view controller instance to use for presenting modal views
     as a result of user interaction on an ad. Usual implementation may simply return self,
     if it is view controller class.
     */
    func viewPresentationControllerForNativeAd(_ nativeAd: NativeAd) -> UIViewController?

    /*!
     @abstract Notifies the delegate whenever current app goes in the background due to user click.
     @param nativeAd The PBMNativeAd instance sending the message.
     */
    @objc optional func nativeAdWillLeaveApplication(_ nativeAd: NativeAd)

    /*!
     @abstract Notifies delegate that the native ad will launch a modal
     on top of the current view controller, as a result of user interaction.
     @param nativeAd The PBMNativeAd instance sending the message.
     */
    @objc optional func nativeAdWillPresentModal(_ nativeAd: NativeAd);

    /*!
     @abstract Notifies delegate that the native ad has dismissed the modal on top of
     the current view controller.
     @param nativeAd The PBMNativeAd instance sending the message.
     */
    @objc optional func nativeAdDidDismissModal(_ nativeAd: NativeAd)
}
