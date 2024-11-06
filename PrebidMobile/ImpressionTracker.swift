//
//  ImpressionTracker.swift
//  PrebidMobile
//
//  Created by Olena Stepaniuk on 05.11.2024.
//  Copyright © 2024 AppNexus. All rights reserved.
//

import UIKit

class ImpressionTracker {
    
    private var adViewReloadTracker: AdViewReloadTracker?
    private var viewabilityTracker: PBMCreativeViewabilityTracker?
    
    private weak var view: UIView?
    
    private var isImpressionTracked = false
    
    private var defaultPollingTimeInterval: TimeInterval {
        0.2
    }
    
    init(view: UIView? = nil) {
        self.view = view
    }
    
    func start() {
        initAdViewReloadTracker()
    }
    
    private func initAdViewReloadTracker() {
        guard let view else { return }
        
        adViewReloadTracker = AdViewReloadTracker(in: view) { [weak self] in
            self?.isImpressionTracked = false
            self?.initViewabilityTracker()
        }
        
        adViewReloadTracker?.start()
    }
    
    private func initViewabilityTracker() {
        guard let view else { return }
        
        viewabilityTracker = PBMCreativeViewabilityTracker(
            view: view,
            pollingTimeInterval: defaultPollingTimeInterval,
            onExposureChange: { [weak self] tracker, viewExposure in
                
                if self?.isImpressionTracked == false {
                    print("LOG: \(viewExposure), exposedPercentage: \(viewExposure.exposedPercentage)")
                }
                
                self?.isImpressionTracked = true
                
                // Stop tracker
                self?.viewabilityTracker?.stop()
                
//                if viewExposure.exposedPercentage > 0 {
//                    // TODO: Track burl
//
//                }
            }
        )
        
        viewabilityTracker?.start()
    }
}
