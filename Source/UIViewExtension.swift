//
//  UIViewExtension.swift
//  PrebidMobile
//
//  Created by Akash.Verma on 05/11/20.
//  Copyright © 2020 AppNexus. All rights reserved.
//

import Foundation

extension UIView {
    
    func an_isAtLeastHalfViewable() -> Bool{
        if isHidden {
            return false
        }
        if (window == nil) {
            return false
        }
        var isInHiddenSuperview = false
        var currentView = self
        while let ancestorView = currentView.superview {
            if ancestorView.isHidden {
                isInHiddenSuperview = true
                break
            }
            currentView = ancestorView
        }
        
        if isInHiddenSuperview {
            return false
        }
        
        let screenRect = UIScreen.main.bounds
        let normalizedSelfRect = convert(screenRect, to: nil)
        let intersection = screenRect.intersection(normalizedSelfRect)
        if intersection.equalTo(.null) {
            return false
        }
        
        let intersectionArea = intersection.width * intersection.height
        let selfArea = normalizedSelfRect.width * normalizedSelfRect.height
        return intersectionArea >= 0.5 * selfArea
        
    }
    
}
