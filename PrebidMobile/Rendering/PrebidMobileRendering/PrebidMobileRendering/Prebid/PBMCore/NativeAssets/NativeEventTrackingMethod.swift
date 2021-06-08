//
//  NativeEventTrackingMethod.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

@objc public enum NativeEventTrackingMethod : Int {
    case img                = 1 /// Image-pixel tracking - URL provided will be inserted as a 1x1 pixel at the time of the event.
    case js                 = 2 /// Javascript-based tracking - URL provided will be inserted as a js tag at the time of the event.
    
    case exchangeSpecific   = 500 /// Could include custom measurement companies such as moat, doubleverify, IAS, etc - in this case additional elements will often be passed
}
