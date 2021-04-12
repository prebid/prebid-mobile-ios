//
//  NativeAdViewBoxProtocol.swift
//  OpenXInternalTestApp
//
//  Copyright © 2021 OpenX. All rights reserved.
//

import UIKit

protocol NativeAdViewBoxProtocol: class {
    func setUpDummyValues()
    func embedIntoView(_ view: UIView)
    func renderNativeAd(_ nativeAd: OXANativeAd)
    func registerViews(_ nativeAd: OXANativeAd)
    
    var showOnlyMediaView: Bool {get set}
    var autoPlayOnVisible: Bool {get set}
    var mediaViewDelegate: OXAMediaViewDelegate? {get set}
}
