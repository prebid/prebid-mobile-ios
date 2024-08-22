//
//  PBMAdViewDelegate.swift
//  PrebidMobile
//
//  Created by Paul NICOLAS on 28/09/2023.
//  Copyright © 2023 AppNexus. All rights reserved.
//

import UIKit

@objc public protocol PBMThirdPartyAdViewLoader: NSObjectProtocol {
}

public typealias PBMAdViewDelegate = PBMThirdPartyAdViewLoader & PBMAdViewManagerDelegate & PBMModalManagerDelegate
