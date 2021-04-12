//
//  OXANativeAdConfiguration+Testing.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation

extension Array where Self.Element == OXANativeAsset {
    static let defaultNativeRequestAssets: [OXANativeAsset] = [
        {
            let title = OXANativeAssetTitle(length: 90)
            title.required = true
            return title
        }(),
        {
            let icon = OXANativeAssetImage()
            icon.widthMin = 50
            icon.heightMin = 50
            icon.required = true
            icon.imageType = NSNumber(value: OXAImageAssetType.icon.rawValue)
            return icon
        }(),
        {
            let image = OXANativeAssetImage()
            image.widthMin = 150
            image.heightMin = 50
            image.required = true
            image.imageType = NSNumber(value: OXAImageAssetType.main.rawValue)
            return image
        }(),
        {
            let desc = OXANativeAssetData(dataType: .desc)
            desc.required = true
            return desc
        }(),
        {
            let cta = OXANativeAssetData(dataType: .ctaText)
            cta.required = true
            return cta
        }(),
        {
            let sponsored = OXANativeAssetData(dataType: .sponsored)
            sponsored.required = true
            return sponsored
        }(),
    ]
}

// TODO: additional parameters for trackers, context, etc. (?)
extension OXANativeAdConfiguration {
    convenience init(testConfigWithAssets assets: [OXANativeAsset]) {
        self.init(assets: assets)
        
        self.eventtrackers = [
            OXANativeEventTracker(event: .impression,
                                  methods: [
                                    OXANativeEventTrackingMethod.img,
                                    .JS,
                                  ].map { NSNumber(value: $0.rawValue) }),
        ]
        
        self.context = .socialCentric
        self.contextsubtype = .social
        self.plcmttype = .feedGridListing
    }
}
