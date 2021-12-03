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
import UIKit

@objc protocol NativeAdUIDelegate where Self: NSObject {
    
    /*!
     @abstract Asks the delegate for a view controller instance to use for presenting modal views
     as a result of user interaction on an ad. Usual implementation may simply return self,
     if it is view controller class.
     */
    func viewPresentationControllerForNativeAd(_ nativeAd: PBRNativeAd) -> UIViewController?

    /*!
     @abstract Notifies the delegate whenever current app goes in the background due to user click.
     @param nativeAd The PBMNativeAd instance sending the message.
     */
    @objc optional func nativeAdWillLeaveApplication(_ nativeAd: PBRNativeAd)

    /*!
     @abstract Notifies delegate that the native ad will launch a modal
     on top of the current view controller, as a result of user interaction.
     @param nativeAd The PBMNativeAd instance sending the message.
     */
    @objc optional func nativeAdWillPresentModal(_ nativeAd: PBRNativeAd);

    /*!
     @abstract Notifies delegate that the native ad has dismissed the modal on top of
     the current view controller.
     @param nativeAd The PBMNativeAd instance sending the message.
     */
    @objc optional func nativeAdDidDismissModal(_ nativeAd: PBRNativeAd)
}
