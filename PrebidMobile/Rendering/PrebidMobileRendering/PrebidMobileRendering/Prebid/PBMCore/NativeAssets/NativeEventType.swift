//
//  NativeEventType.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

@objc public enum NativeEventType : Int {
    case impression         = 1     /// Impression
    case mrc50              = 2     /// Visible impression using MRC definition at 50% in view for 1 second
    case mrc100             = 3     /// 100% in view for 1 second (ie GroupM standard)
    case video50            = 4     /// Visible impression for video using MRC definition at 50% in view for 2 seconds
    
    case exchangeSpecific   = 500   /// Reserved for Exchange specific usage numbered above 500
    case omid               = 555   /// Open Measurement event
}
