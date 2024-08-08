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

/// A protocol for handling events related to banner ads in the PBM SDK.
///
/// This protocol defines methods and properties for managing events associated with banner ads, including loading events, user interactions, and ad sizes. Implementing this protocol allows for custom handling of these events within the PBM SDK.
@objc public protocol BannerEventHandler : PBMPrimaryAdRequesterProtocol {

    /// Delegate for custom event handler to inform the PBM SDK about the events related to the ad server communication.
    weak var loadingDelegate: BannerEventLoadingDelegate? { get set }

    /// Delegate for custom event handler to inform the PBM SDK about the events related to the user's interaction with the ad.
    weak var interactionDelegate: BannerEventInteractionDelegate? { get set }

    /// The array of the CGRect entries for each valid ad sizes.
    /// The first size is treated as a frame for related ad unit.
    var adSizes: [CGSize] { get }

    func trackImpression()
}
