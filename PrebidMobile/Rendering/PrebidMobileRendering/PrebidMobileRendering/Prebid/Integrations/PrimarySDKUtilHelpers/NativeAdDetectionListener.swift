//
//  NativeAdDetectionListener.swift
//  PrebidMobileRendering
//
//  Copyright © 2021 Prebid. All rights reserved.
//

import Foundation

public typealias NativeAdLoadedHandler = (NativeAd) -> Void
public typealias PrimaryAdServerWinHandler = () -> Void
public typealias InvalidNativeAdHandler = (Error) -> Void

/// Immutable container for 3 mutually exclusive outcomes of an asynchronous native ad detection attempt.
public class NativeAdDetectionListener: NSObject, NSCopying {
    
    @objc public private(set) var onNativeAdLoaded: NativeAdLoadedHandler?
    @objc public private(set) var onPrimaryAdWin: PrimaryAdServerWinHandler?
    @objc public private(set) var onNativeAdInvalid: InvalidNativeAdHandler?

    @objc public required init(nativeAdLoadedHandler onNativeAdLoaded: NativeAdLoadedHandler?,
                               onPrimaryAdWin: PrimaryAdServerWinHandler?,
                               onNativeAdInvalid: InvalidNativeAdHandler?) {
        self.onNativeAdLoaded = onNativeAdLoaded
        self.onPrimaryAdWin = onPrimaryAdWin
        self.onNativeAdInvalid = onNativeAdInvalid
    }

    // MARK: - NSCopying
    
    @objc public func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
    
    // MARK: - Private
    @available(*, unavailable)
    private override init() {
        fatalError("Init is unavailable.")
    }

}
