//
//  InterstitialEventHandlerStandalone.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation
import UIKit

public class InterstitialEventHandlerStandalone: NSObject, InterstitialEventHandlerProtocol {
    
    // MARK: Public Methods
    
    public weak var loadingDelegate: InterstitialEventLoadingDelegate?
    
    public weak var interactionDelegate: InterstitialEventInteractionDelegate?
    
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
