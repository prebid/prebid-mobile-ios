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

@objc public protocol BannerViewDelegate where Self: NSObject {

    /** @name Methods */
    /*!
     @abstract Asks the delegate for a view controller instance to use for presenting modal views
     as a result of user interaction on an ad. Usual implementation may simply return self,
     if it is view controller class.
     */
    func bannerViewPresentationController() -> UIViewController?

    /*!
     @abstract Notifies the delegate that an ad has been successfully loaded and rendered.
     @param bannerView The BannerView instance sending the message.
     */
    @objc optional func bannerView(_ bannerView: BannerView, didReceiveAdWithAdSize adSize: CGSize)

    /*!
     @abstract Notifies the delegate of an error encountered while loading or rendering an ad.
     @param bannerView The BannerView instance sending the message.
     @param error The error encountered while attempting to receive or render the
     ad.
     */
    @objc optional func bannerView(_ bannerView: BannerView,
                                   didFailToReceiveAdWith error: Error)

    /*!
     @abstract Notifies the delegate whenever current app goes in the background due to user click.
     @param bannerView The BannerView instance sending the message.
     */
    @objc optional func bannerViewWillLeaveApplication(_ bannerView: BannerView)

    /*!
     @abstract Notifies delegate that the banner view will launch a modal
     on top of the current view controller, as a result of user interaction.
     @param bannerView The BannerView instance sending the message.
     */
    @objc optional func bannerViewWillPresentModal(_ bannerView: BannerView)

    /*!
     @abstract Notifies delegate that the banner view has dismissed the modal on top of
     the current view controller.
     @param bannerView The BannerView instance sending the message.
     */
    @objc optional func bannerViewDidDismissModal(_ bannerView: BannerView)
}
