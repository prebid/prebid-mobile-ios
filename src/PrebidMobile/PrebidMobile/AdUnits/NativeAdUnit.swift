//
//  NativeAdUnit.swift
//  PrebidMobile
//
//  Created by Wei Zhang on 9/20/19.
//  Copyright © 2019 AppNexus. All rights reserved.
//

import Foundation

@objcMembers public class NativeAdUnit: AdUnit {
    public init(configId: String) {
        super.init(configId: configId, size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    }
    
}
