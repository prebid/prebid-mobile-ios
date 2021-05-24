//
//  NativeAdConfiguration+Testing.swift
//  OpenXInternalTestApp
//
//  Copyright © 2020 OpenX. All rights reserved.
//

import Foundation

extension Array where Self.Element == NativeAsset {
    static let defaultNativeRequestAssets: [NativeAsset] = [
        {
            let title = NativeAssetTitle(length: 90)
            title.required = true
            return title
        }(),
        {
            let icon = NativeAssetImage()
            icon.widthMin = 50
            icon.heightMin = 50
            icon.required = 1
            icon.imageType = NSNumber(value: PBMImageAssetType.icon.rawValue)
            return icon
        }(),
        {
            let image = NativeAssetImage()
            image.widthMin = 150
            image.heightMin = 50
            image.required = 1
            image.imageType = NSNumber(value: PBMImageAssetType.main.rawValue)
            return image
        }(),
        {
            let desc = NativeAssetData(dataType: .desc)
            desc.required = 1
            return desc
        }(),
        {
            let cta = NativeAssetData(dataType: .ctaText)
            cta.required = 1
            return cta
        }(),
        {
            let sponsored = NativeAssetData(dataType: .sponsored)
            sponsored.required = 1
            return sponsored
        }(),
    ]
}

// TODO: additional parameters for trackers, context, etc. (?)
extension NativeAdConfiguration {
    convenience init(testConfigWithAssets assets: [NativeAsset]) {
        self.init(assets: assets)
        
        self.eventtrackers = [
            PBMNativeEventTracker(event: .impression,
                                  methods: [
                                    PBMNativeEventTrackingMethod.img,
                                    .JS,
                                  ].map { NSNumber(value: $0.rawValue) }),
        ]
        
        self.context = .socialCentric
        self.contextsubtype = .social
        self.plcmttype = .feedGridListing
    }
}
