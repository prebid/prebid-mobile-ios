//
//  PBMAdViewDelegate.swift
//  PrebidMobile
//
//  Created by Paul NICOLAS on 28/09/2023.
//  Copyright © 2023 AppNexus. All rights reserved.
//

import UIKit

@objc public protocol PBMThirdPartyAdViewLoader: NSObjectProtocol {
    func adViewLoaded(_ adView: UIView, adSize: CGSize) // PBMDisplayView
}

public typealias PBMAdViewDelegate = PBMThirdPartyAdViewLoader & PBMAdViewManagerDelegate & PBMModalManagerDelegate
