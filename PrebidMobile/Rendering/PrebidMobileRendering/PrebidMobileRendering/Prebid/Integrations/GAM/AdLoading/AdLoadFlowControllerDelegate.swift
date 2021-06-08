//
//  AdLoadFlowControllerDelegate.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

@objc public protocol AdLoadFlowControllerDelegate where Self: NSObject {

    var adUnitConfig:AdUnitConfig { get }

    // Loading callbacks
    @objc func adLoadFlowController(_ adLoadFlowController: PBMAdLoadFlowController,
                                    failedWithError error: Error?)

    // Refresh controls hooks
    @objc func adLoadFlowControllerWillSendBidRequest(_ adLoadFlowController: PBMAdLoadFlowController)
    @objc func adLoadFlowControllerWillRequestPrimaryAd(_ adLoadFlowController: PBMAdLoadFlowController)

    // Hook to pause the flow between 'loading' states
    @objc func adLoadFlowControllerShouldContinue(_ adLoadFlowController: PBMAdLoadFlowController) -> Bool
}
