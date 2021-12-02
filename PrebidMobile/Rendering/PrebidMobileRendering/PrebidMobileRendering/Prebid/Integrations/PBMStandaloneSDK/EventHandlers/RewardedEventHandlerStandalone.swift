//
//  File.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import UIKit

public class RewardedEventHandlerStandalone: NSObject, RewardedEventHandlerProtocol {
    
    public weak var loadingDelegate: RewardedEventLoadingDelegate?
    public weak var interactionDelegate: RewardedEventInteractionDelegate?
    
    public var isReady: Bool {
        false
    }
    
    public func show(from controller: UIViewController?) {
        assertionFailure("should never be called, as PBM SDK always wins")
    }
    
    public func requestAd(with bidResponse: BidResponse?) {
        loadingDelegate?.prebidDidWin()
    }
    
    
}
