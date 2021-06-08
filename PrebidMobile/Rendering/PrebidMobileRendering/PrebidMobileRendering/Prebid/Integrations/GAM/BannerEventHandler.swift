//
//  BannerEventHandler.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol BannerEventHandler : PBMPrimaryAdRequesterProtocol {

    /// Delegate for custom event handler to inform the PBM SDK about the events related to the ad server communication.
    weak var loadingDelegate: BannerEventLoadingDelegate? { get set }

    /// Delegate for custom event handler to inform the PBM SDK about the events related to the user's interaction with the ad.
    weak var interactionDelegate: BannerEventInteractionDelegate? { get set }

    /// The array of the CGRect entries for each valid ad sizes.
    /// The first size is treated as a frame for related ad unit.
    var adSizes: [CGSize] { get }

    var isCreativeRequiredForNativeAds: Bool { get }

    func trackImpression()
}
