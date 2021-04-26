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
    func renderNativeAd(_ nativeAd: PBMNativeAd)
    func registerViews(_ nativeAd: PBMNativeAd)
    
    var showOnlyMediaView: Bool {get set}
    var autoPlayOnVisible: Bool {get set}
    var mediaViewDelegate: PBMMediaViewDelegate? {get set}
}
