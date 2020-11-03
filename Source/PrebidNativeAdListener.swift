//
//  PrebidNativeAdListener.swift
//  iOSTestNativeNative
//
//  Created by Wei Zhang on 11/6/19.
//  Copyright © 2019 AppNexus. All rights reserved.
//

import Foundation

public protocol PrebidNativeAdListener {
    
    func onPrebidNativeLoaded(ad:PrebidNativeAd)
    func onPrebidNativeNotValid()
    func onPrebidNativeNotFound()
}
