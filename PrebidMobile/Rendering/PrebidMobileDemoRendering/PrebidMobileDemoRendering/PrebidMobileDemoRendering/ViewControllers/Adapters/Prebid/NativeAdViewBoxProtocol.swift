//
//  NativeAdViewBoxProtocol.swift
//  OpenXInternalTestApp
//
//  Copyright © 2021 OpenX. All rights reserved.
//

import UIKit

protocol NativeAdViewBoxProtocol: AnyObject {
    func setUpDummyValues()
    func embedIntoView(_ view: UIView)
    func renderNativeAd(_ nativeAd: NativeAd)
    func registerViews(_ nativeAd: NativeAd)
    
    var showOnlyMediaView: Bool {get set}
    var autoPlayOnVisible: Bool {get set}
    var mediaViewDelegate: MediaViewDelegate? {get set}
}
